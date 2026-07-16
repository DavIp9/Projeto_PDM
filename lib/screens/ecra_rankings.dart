import 'package:flutter/material.dart';
import '../repositories/firestore_repository.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final data = await FirestoreRepository.instance.obterRankings();
      setState(() {
        _rankings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar rankings: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Rankings Softinsa',
          style: TextStyle(
            color: Color(0xFF2E5B94),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _rankings.isEmpty
                  ? const Center(
                      child: Text('Nenhum dado de ranking disponível.'))
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildPodium(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildList()),
                      ],
                    ),
    );
  }

  Widget _buildPodium() {
    final top1 = _rankings.isNotEmpty ? _rankings[0] : null;
    final top2 = _rankings.length > 1 ? _rankings[1] : null;
    final top3 = _rankings.length > 2 ? _rankings[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top2 != null)
            _buildPodiumItem(
                top2, 2, 70, Colors.grey[300]!, const Color(0xFFC0C0C0)),
          if (top1 != null)
            _buildPodiumItem(
                top1, 1, 90, const Color(0xFFFFF9C4), const Color(0xFFFFD700)),
          if (top3 != null)
            _buildPodiumItem(
                top3, 3, 60, const Color(0xFFFFE0B2), const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, int place, double size,
      Color podiumColor, Color borderColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 4),
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.white,
                child:
                    const Icon(Icons.person, size: 36, color: Colors.blueGrey),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$place',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user['nome'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user['pontos']} pts',
          style: const TextStyle(
              color: Color(0xFF2E5B94),
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: place == 1 ? 70 : (place == 2 ? 50 : 35),
          decoration: BoxDecoration(
              color: podiumColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                )
              ]),
          child: const Center(
            child: Icon(Icons.emoji_events_outlined, color: Colors.black38),
          ),
        )
      ],
    );
  }

  Widget _buildList() {
    final otherUsers = _rankings.length > 3 ? _rankings.sublist(3) : [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: otherUsers.length,
        itemBuilder: (context, index) {
          final user = otherUsers[index];
          final rank = index + 4;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(
                  '#$rank',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 14),
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: 18,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nome'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        user['perfil'] ?? 'Consultor',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${user['pontos']} pts',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5B94),
                          fontSize: 14),
                    ),
                    Text(
                      '${user['badges']} badges',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
