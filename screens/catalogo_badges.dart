import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'detalhes_badge.dart';

class CatalogoBadgesScreen extends StatefulWidget {
  const CatalogoBadgesScreen({super.key});

  @override
  State<CatalogoBadgesScreen> createState() => _CatalogoBadgesScreenState();
}

class _CatalogoBadgesScreenState extends State<CatalogoBadgesScreen> {
  List<dynamic> allBadges = [];
  List<dynamic> filteredBadges = [];
  List<String> areas = [];
  
  String? selectedArea;
  String? selectedLevel;
  final List<String> levels = ['A1', 'A2', 'A3', 'A4'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);
    setState(() {
      allBadges = data['badges'];
      filteredBadges = allBadges;
      areas = List<String>.from(data['areas']);
    });
  }

  void _applyFilter() {
    setState(() {
      filteredBadges = allBadges.where((badge) {
        final matchesArea = selectedArea == null || badge['area'] == selectedArea;
        final matchesLevel = selectedLevel == null || badge['level'] == selectedLevel;
        return matchesArea && matchesLevel;
      }).toList();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filtrar Badges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94))),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Área', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: selectedArea,
                    hint: const Text('Todas as áreas'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Todas as áreas')),
                      ...areas.map((area) => DropdownMenuItem(value: area, child: Text(area, overflow: TextOverflow.ellipsis)))
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedArea = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Nível', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: selectedLevel,
                    hint: const Text('Todos os níveis'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Todos os níveis')),
                      ...levels.map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedLevel = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilter();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5B94),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Aplicar Filtros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
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
          'Catálogo de Badges',
          style: TextStyle(
            color: Color(0xFF2E5B94),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF2E5B94)),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: filteredBadges.isEmpty
          ? const Center(child: Text('Nenhum badge encontrado para os filtros selecionados.', textAlign: TextAlign.center))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: filteredBadges.length,
                itemBuilder: (context, index) {
                  final badge = filteredBadges[index];
                  return _buildBadgeCard(badge);
                },
              ),
            ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesBadgeScreen(badge: badge),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Medal/Drop shape
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E5B94), Color(0xFF5B8AC6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(10), // Makes it drop-like
                    ),
                  ),
                  child: Center(
                    child: Text(
                      badge['level'] ?? 'A1',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge['name'] ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${badge['points']} Pontos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
