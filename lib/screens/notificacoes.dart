import 'package:flutter/material.dart';
import '../repositories/firestore_repository.dart';
import '../models/utilizador_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = Session.utilizador;
      if (user == null) {
        setState(() {
          _error = 'Utilizador não autenticado.';
          _isLoading = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: FirestoreRepository.instance.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final data = snap.docs.map((doc) {
        final map = doc.data();
        String formattedDate = '';
        if (map['createdAt'] is Timestamp) {
          final date = (map['createdAt'] as Timestamp).toDate();
          formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
        return {
          'id': doc.id,
          'TITULO': map['title'] ?? 'Notificação',
          'MENSAGEM': map['message'] ?? '',
          'DATACRIACAO': formattedDate,
          'FASE': map['read'] == true ? 'Lida' : 'Nao Lida',
        };
      }).toList();

      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter notificações: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final user = Session.utilizador;
    if (user == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: FirestoreRepository.instance.uid)
          .where('read', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Todas as notificações foram marcadas como lidas.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao marcar como lidas: $e')),
      );
    }
  }

  Future<void> _deleteNotification(String idNotif) async {
    try {
      await FirestoreRepository.instance.deleteNotification(idNotif);
      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação eliminada.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao eliminar notificação: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Notificações',
            style: TextStyle(
                color: Color(0xFF2E5B94), fontWeight: FontWeight.bold)),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marcar todas',
                  style: TextStyle(
                      color: Color(0xFF2E5B94), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _notifications.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Não tens nenhuma notificação de momento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        final unread = notif['FASE'] != 'Lida';

                        return _buildNotificationItem(notif, unread);
                      },
                    ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif, bool unread) {
    final title = notif['TITULO'] ?? 'Notificação';
    final message = notif['MENSAGEM'] ?? '';
    final date = notif['DATACRIACAO'] ?? '';
    final idNotif = notif['id'] as String;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: unread
              ? const Color(0xFF2E5B94).withOpacity(0.1)
              : Colors.grey[200],
          child: Icon(
            unread
                ? Icons.notifications_active_outlined
                : Icons.notifications_none_outlined,
            color: unread ? const Color(0xFF2E5B94) : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'Recebida a: $date',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (unread)
          Container(
            margin: const EdgeInsets.only(left: 8, top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2E5B94),
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
          onPressed: () => _deleteNotification(idNotif),
        ),
      ],
    );
  }
}
