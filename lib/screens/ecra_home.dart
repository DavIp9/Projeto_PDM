import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/side_menu_drawer.dart';
import 'notificacoes.dart';
import '../repositories/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilizador_model.dart';
import 'detalhes_badge.dart';
import '../widgets/custom_badge_card.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasUnreadNotifications = false;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query.trim();
    });

    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final all = await FirestoreRepository.instance.obterBadgesCatalogo();
      final value = _searchQuery.toLowerCase();
      if (!mounted) return;
      setState(() {
        _searchResults = all.where((badge) {
          final name = (badge['name'] ?? '').toString().toLowerCase();
          final description =
              (badge['description'] ?? '').toString().toLowerCase();
          return name.contains(value) || description.contains(value);
        }).toList();
      });
    } catch (e) {
      print('Erro ao pesquisar: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final user = Session.utilizador;
      if (user == null) {
        setState(() {
          _errorMessage = 'Utilizador não autenticado.';
          _isLoading = false;
        });
        return;
      }
      await FirestoreRepository.instance.verificarExpiracaoBadges();

      final stats = await FirestoreRepository.instance
          .obterEstatisticasHome(user.idUtilizador);

      final unreadCountRes = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: FirestoreRepository.instance.uid)
          .where('read', isEqualTo: false)
          .get();
      final unreadCount = unreadCountRes.docs.length;

      setState(() {
        _stats = stats;
        _hasUnreadNotifications = unreadCount > 0;
        _isLoading = false;
      });

      final pontos = stats['pontos'] as int? ?? 0;
      final badgesCount = stats['badgesCount'] as int? ?? 0;
      _verificarMarcosCelebracao(pontos, badgesCount);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.utilizador;
    final username = user?.nomeUtilizador ?? 'Consultor';

    return Scaffold(
      drawer: SideMenuDrawer(
        username: username,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pesquisar...',
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : const Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: _hasUnreadNotifications
                ? const Badge(
                    child: Icon(Icons.notifications_none, size: 28),
                  )
                : const Icon(Icons.notifications_none, size: 28),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()));
              _loadStats();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : RefreshIndicator(
                      onRefresh: _loadStats,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()} $username',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E5B94),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildKPICard(
                                    'Pontos',
                                    '${_stats!['pontos']}',
                                    Icons.star_rounded,
                                    Colors.amber,
                                  ),
                                  _buildKPICard(
                                    'Badges',
                                    '${_stats!['badgesCount']}',
                                    Icons.emoji_events_rounded,
                                    Colors.blue,
                                  ),
                                  _buildKPICard(
                                    'Ranking',
                                    '${_stats!['rankingPosition'] ?? 0}º',
                                    Icons.leaderboard_rounded,
                                    Colors.orange,
                                  ),
                                  _buildKPICard(
                                    'Sucesso',
                                    '${_stats!['successRate'] ?? 0}%',
                                    Icons.pie_chart_rounded,
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Meta Definida Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Meta Definida',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Conseguiste alcançar ${_stats!['badgesCount']} badges!\nPontuação acumulada: ${_stats!['pontos']} pontos.',
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                  const SizedBox(height: 20),
                                  const Text('Badges conquistados',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children:
                                        (_stats!['badges'] as List).isEmpty
                                            ? [
                                                const Text(
                                                    'Ainda não tens badges conquistados.',
                                                    style: TextStyle(
                                                        color: Colors.black38))
                                              ]
                                            : (_stats!['badges'] as List)
                                                .map<Widget>((badge) {
                                                return _buildMiniBadge(
                                                    Colors.blueAccent,
                                                    Icons.workspace_premium,
                                                    badge['name'] ?? '');
                                              }).toList(),
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Candidaturas Submetidas',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Icon(Icons.arrow_forward, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16),
                            (_stats!['candidaturas'] as List).isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                        'Nenhuma candidatura submetida.',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.95,
                                    ),
                                    itemCount: (_stats!['candidaturas'] as List)
                                        .length,
                                    itemBuilder: (context, index) {
                                      final cand = (_stats!['candidaturas']
                                          as List)[index];
                                      Color statusColor = Colors.orange;
                                      if (cand['status'] == 'Aprovada')
                                        statusColor = Colors.green;
                                      if (cand['status'] == 'Rejeitada')
                                        statusColor = Colors.red;

                                      return _buildProgressCard(
                                        cand['badgeName'] ?? '',
                                        statusColor,
                                        cand['status'] == 'Aprovada'
                                            ? 1.0
                                            : 0.5,
                                        cand['status'] ?? '',
                                        Icons.badge_outlined,
                                      );
                                    },
                                  ),

                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Badges Recomendados',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Icon(Icons.arrow_forward, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16),
                            (_stats!['recomendados'] as List).isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('Sem recomendações de momento.',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  )
                                : Row(
                                    children: (_stats!['recomendados'] as List)
                                        .map<Widget>((rec) {
                                      return Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      DetalhesBadgeScreen(
                                                    badge: Map<String,
                                                        dynamic>.from(rec),
                                                  ),
                                                ),
                                              ).then((_) => _loadStats());
                                            },
                                            child: _buildRecommendedCard(
                                              rec['name'] ?? '',
                                              rec['rarity'] == 'Especial'
                                                  ? const Color(0xFFF1C40F)
                                                  : Colors.blueAccent,
                                              rec['rarity'] == 'Especial'
                                                  ? Icons
                                                      .workspace_premium_rounded
                                                  : Icons.star_border,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildMiniBadge(Color color, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, Color color, double progress,
      String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(String title, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Nenhum badge encontrado com esse nome.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados para "$_searchQuery"',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5B94)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final badge = _searchResults[index];
                return _buildSearchBadgeCard(badge);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBadgeCard(Map<String, dynamic> badge) {
    return CustomBadgeCard(
      badge: badge,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesBadgeScreen(badge: badge),
          ),
        ).then((_) => _loadStats());
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom Dia,';
    } else if (hour < 20) {
      return 'Boa Tarde,';
    } else {
      return 'Boa Noite,';
    }
  }

  Future<void> _verificarMarcosCelebracao(
      int totalPontos, int totalBadges) async {
    final user = Session.utilizador;
    if (user == null) return;
    final uid = user.uid;

    final prefs = await SharedPreferences.getInstance();

    final badgeMilestones = [5, 10, 15, 20];
    final pointsMilestones = [50, 150, 300, 500];

    // 1. Check Badges milestones
    for (var milestone in badgeMilestones) {
      final key = 'celebrated_badge_${uid}_$milestone';
      final alreadyCelebrated = prefs.getBool(key) ?? false;
      if (totalBadges >= milestone && !alreadyCelebrated) {
        await prefs.setBool(key, true);
        if (mounted) {
          _mostrarPopupCelebracao(
            'Marco de Conquista!',
            'Parabéns! Já obtiveste $milestone badges no total! Continua com o excelente percurso profissional. 🏆',
            'Trophy',
          );
        }
        return;
      }
    }

    // 2. Check Points milestones
    for (var milestone in pointsMilestones) {
      final key = 'celebrated_points_${uid}_$milestone';
      final alreadyCelebrated = prefs.getBool(key) ?? false;
      if (totalPontos >= milestone && !alreadyCelebrated) {
        await prefs.setBool(key, true);
        if (mounted) {
          _mostrarPopupCelebracao(
            'Marco de Pontuação!',
            'Parabéns! Alcançaste a pontuação acumulada de $milestone pontos! Incrível! ⚡',
            'Points',
          );
        }
        return;
      }
    }
  }

  void _mostrarPopupCelebracao(String title, String message, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final iconData = type == 'Trophy'
            ? Icons.emoji_events_rounded
            : Icons.offline_bolt_rounded;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.amber,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'PARABÉNS!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3C72),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
