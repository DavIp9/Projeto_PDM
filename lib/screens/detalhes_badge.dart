import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/requisito_model.dart';

class DetalhesBadgeScreen extends StatefulWidget {
  final Map<String, dynamic> badge;

  const DetalhesBadgeScreen({super.key, required this.badge});

  @override
  State<DetalhesBadgeScreen> createState() => _DetalhesBadgeScreenState();
}

class _DetalhesBadgeScreenState extends State<DetalhesBadgeScreen> {
  List<Requisito> _requisitos = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRequisitos();
  }

  Future<void> _loadRequisitos() async {
    final idNivel = widget.badge['idNivel'] as int?;
    if (idNivel == null) {
      setState(() {
        _isLoading = false;
        _error = 'ID de Nível inválido.';
      });
      return;
    }
    try {
      final reqs = await DatabaseHelper.instance.obterRequisitosPorNivel(idNivel);
      setState(() {
        _requisitos = reqs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erro ao obter requisitos: $e';
      });
    }
  }

  void _showSubmitModal() {
    final Map<int, TextEditingController> controllers = {};
    for (var req in _requisitos) {
      controllers[req.idRequisito] = TextEditingController();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Submeter Evidências',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Introduza o caminho ou link do ficheiro de evidência para cada requisito.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ..._requisitos.map((req) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.nomeRequisito,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controllers[req.idRequisito],
                          decoration: InputDecoration(
                            hintText: 'ex: link_ficheiro.${req.tipoEvidencia?.toLowerCase() ?? "pdf"}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Map<int, String> evs = {};
                    bool allFilled = true;
                    controllers.forEach((idReq, controller) {
                      final val = controller.text.trim();
                      if (val.isEmpty) {
                        allFilled = false;
                      } else {
                        evs[idReq] = val;
                      }
                    });

                    if (!allFilled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, preencha todas as evidências.')),
                      );
                      return;
                    }

                    try {
                      final user = Session.utilizador;
                      if (user == null) return;
                      final idNivel = widget.badge['idNivel'] as int;
                      
                      await DatabaseHelper.instance.submeterCandidaturaComEvidencias(
                        user.idUtilizador,
                        idNivel,
                        evs,
                      );

                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Candidatura submetida com sucesso!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao submeter: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5B94),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submeter Candidatura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.badge['name'] ?? 'Badge';
    final String level = widget.badge['level'] ?? 'Base';
    final String area = widget.badge['area'] ?? 'Área desconhecida';
    final int points = widget.badge['points'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Detalhes do Badge',
          style: TextStyle(
            color: Color(0xFF2E5B94),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E5B94), Color(0xFF5B8AC6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    level.split(' ').last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5B94),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              area,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$points Pontos',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5B94),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Requisitos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5B94),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                          ? Text(_error)
                          : Column(
                              children: _requisitos.map((req) {
                                return _buildRequirementItem(
                                  '${req.nomeRequisito}: ${req.descricao} (${req.tipoEvidencia ?? "PDF"})'
                                );
                              }).toList(),
                            )
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (!_isLoading && _error.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: _showSubmitModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5B94),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submeter Evidências', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
