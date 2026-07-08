import 'package:flutter/material.dart';
import '../widgets/side_menu_drawer.dart';
import 'notificacoes.dart';
import '../database/database_helper.dart';
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
      final db = await DatabaseHelper.instance.database;
      final results = await db.rawQuery('''
        SELECT B.ID_BADGE, B.NOME_BADGE as name, B.DESCRICAO as description, 
               B.PONTOS as points, B.RARIDADE as rarity, B.URL_IMAGEM as urlImagem,
               N.ID_NIVEL as idNivel, N.NOME_NIVEL as level, A.NOME_AREA as area
        FROM BADGE B
        LEFT JOIN NIVEL N ON B.ID_BADGE = N.ID_BADGE
        LEFT JOIN AREA A ON N.ID_AREA = A.ID_AREA
        WHERE B.NOME_BADGE LIKE ? OR B.DESCRICAO LIKE ?
      ''', ['%$_searchQuery%', '%$_searchQuery%']);

      setState(() {
        _searchResults = results;
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
      final stats = await DatabaseHelper.instance.obterEstatisticasHome(user.idUtilizador);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
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
      drawer: SideMenuDrawer(username: username),
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
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_none, size: 28),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()));
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
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Meta Definida',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                  'Conseguiste alcançar ${_stats!['badgesCount']} badges!\nPontuação acumulada: ${_stats!['pontos']} pontos.',
                                  style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 20),
                              const Text('Badges conquistados',
                                  style:
                                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: (_stats!['badges'] as List).isEmpty
                                    ? [const Text('Ainda não tens badges conquistados.', style: TextStyle(color: Colors.black38))]
                                    : (_stats!['badges'] as List).map<Widget>((badge) {
                                        return _buildMiniBadge(
                                            Colors.blueAccent, Icons.workspace_premium, badge['name'] ?? '');
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
                                style:
                                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Icon(Icons.arrow_forward, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        (_stats!['candidaturas'] as List).isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Nenhuma candidatura submetida.', style: TextStyle(color: Colors.black54)),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.95,
                                ),
                                itemCount: (_stats!['candidaturas'] as List).length,
                                itemBuilder: (context, index) {
                                  final cand = (_stats!['candidaturas'] as List)[index];
                                  Color statusColor = Colors.orange;
                                  if (cand['status'] == 'Aprovada') statusColor = Colors.green;
                                  if (cand['status'] == 'Rejeitada') statusColor = Colors.red;
                                  
                                  return _buildProgressCard(
                                    cand['name'] ?? '',
                                    statusColor,
                                    cand['status'] == 'Aprovada' ? 1.0 : 0.5,
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
                                style:
                                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Icon(Icons.arrow_forward, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        (_stats!['recomendados'] as List).isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Sem recomendações de momento.', style: TextStyle(color: Colors.black54)),
                              )
                            : Row(
                                children: (_stats!['recomendados'] as List).map<Widget>((rec) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: _buildRecommendedCard(
                                        rec['name'] ?? '',
                                        Colors.blueAccent,
                                        Icons.star_border,
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
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
        );
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
}
