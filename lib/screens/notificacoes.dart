import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Notificações', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Marcar todas', style: TextStyle(color: Color(0xFF2E5B94))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem('Um novo Badge foi adicionado ao Learning Path Jornada Técnica. Consulta os requisitos e candidata-te para continuares o teu desenvolvimento profissional!', 'Não Lida - Enviada há 3 horas', true),
          const Divider(),
          _buildNotificationItem('Foi atualizada a data de expiração de um dos teus badges.', 'Não Lida - Enviada há 3 horas', true),
          const Divider(),
          _buildNotificationItem('O teu pedido foi aprovado. O badge está agora disponível para publicação e partilha.', 'Não Lida - Enviada há 3 horas', true),
          const Divider(),
          _buildNotificationItem('A tua candidatura foi reprovada devido a inconsistências nas evidências. Revê as indicações e atualiza o envio para continuar o processo.', 'Lida - Enviada há 5 horas', false),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String text, String time, bool unread) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF2E5B94),
                shape: BoxShape.circle,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
