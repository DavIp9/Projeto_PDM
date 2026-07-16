import 'package:flutter/material.dart';
import '../models/utilizador_model.dart';
import '../repositories/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/requisito_model.dart';

class CandidaturasScreen extends StatefulWidget {
  const CandidaturasScreen({super.key});

  @override
  State<CandidaturasScreen> createState() => _CandidaturasScreenState();
}

class _CandidaturasScreenState extends State<CandidaturasScreen> {
  List<Map<String, dynamic>> _candidaturas = [];
  bool _isLoading = true;
  String _error = '';
  late bool _isAvaliador;

  @override
  void initState() {
    super.initState();
    final user = Session.utilizador;
    // Perfis: 2 = Service Line Leader, 3 = Talent Manager, 4 = Admin
    _isAvaliador = user != null &&
        (user.idPerfil == 2 || user.idPerfil == 3 || user.idPerfil == 4);
    _loadCandidaturas();
  }

  Future<void> _loadCandidaturas() async {
    setState(() => _isLoading = true);
    try {
      final user = Session.utilizador;
      if (user == null) return;

      final QuerySnapshot<Map<String, dynamic>> snap;
      if (_isAvaliador) {
        // Obter todas as candidaturas pendentes para avaliação
        snap = await FirebaseFirestore.instance
            .collection('applications')
            .orderBy('submittedAt', descending: true)
            .get();
      } else {
        // Obter as candidaturas apenas do utilizador consultor logado
        snap = await FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: FirestoreRepository.instance.uid)
            .orderBy('submittedAt', descending: true)
            .get();
      }

      final data = snap.docs.map((doc) {
        final map = doc.data();
        String formattedDate = '';
        if (map['submittedAt'] is Timestamp) {
          final date = (map['submittedAt'] as Timestamp).toDate();
          formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
        return {
          'id': doc.id,
          'status': map['status'] ?? 'Submetida',
          'date': formattedDate,
          'userName': map['userName'] ?? 'Consultor',
          'level': map['levelName'] ?? 'Nível',
          'levelId': map['levelId'] ?? 0,
          'name': map['badgeName'] ?? 'Badge',
          'points': map['badgePoints'] ?? 10,
        };
      }).toList();

      setState(() {
        _candidaturas = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter candidaturas: $e';
        _isLoading = false;
      });
    }
  }

  void _showAvaliarDialog(Map<String, dynamic> cand) async {
    final applicationId = cand['id'] as String;
    final levelId = cand['levelId'] as int;

    // Obter os requisitos para este nível
    final requirements = await FirestoreRepository.instance.obterRequisitosPorNivel(levelId);

    // Obter as evidências a partir do Firestore
    final evidencesSnap = await FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .collection('evidences')
        .get();

    final evidencesList = evidencesSnap.docs.map((d) => d.data()).toList();

    // Mapear cada evidência para incluir o nome do requisito
    final List<Map<String, dynamic>> mappedEvidences = [];
    for (var ev in evidencesList) {
      final reqId = ev['requirementId'] as int?;
      final req = requirements.firstWhere(
        (r) => r.idRequisito == reqId,
        orElse: () => Requisito(
          idRequisito: reqId ?? 0,
          idNivel: levelId,
          nomeRequisito: 'Requisito #${reqId}',
          descricao: '',
          tipoEvidencia: '',
          urlImagem: '',
        ),
      );
      mappedEvidences.add({
        'reqName': req.nomeRequisito,
        'fileName': ev['fileName'] ?? 'Ficheiro',
        'fileUrl': ev['downloadUrl'] ?? '',
      });
    }

    final commentController = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Avaliar Candidatura: ${cand['name']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Consultor: ${cand['userName']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Nível: ${cand['level']}'),
                const SizedBox(height: 16),
                const Text('Evidências Submetidas:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                ...mappedEvidences.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('- Requisito: ${e['reqName']}',
                            style: const TextStyle(fontSize: 13)),
                        Text('  Ficheiro: ${e['fileName']}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text('Comentário/Feedback:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Insira o feedback para o consultor...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () =>
                  _executarAvaliacao(cand, 'Rejeitada', commentController.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Rejeitar', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () =>
                  _executarAvaliacao(cand, 'Aprovada', commentController.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text('Aprovar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _executarAvaliacao(
      Map<String, dynamic> cand, String acao, String comentario) async {
    final idCand = cand['id'] as String;
    final approved = acao == 'Aprovada';

    try {
      await FirestoreRepository.instance.evaluateApplication(idCand, approved, comentario);

      if (!mounted) return;
      Navigator.pop(context); // Fechar o diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Candidatura $acao com sucesso!')),
      );
      _loadCandidaturas(); // recarregar lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao executar avaliação: $e')),
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          _isAvaliador ? 'Avaliações Pendentes' : 'As Minhas Candidaturas',
          style: const TextStyle(
            color: Color(0xFF2E5B94),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _candidaturas.isEmpty
                  ? Center(
                      child: Text(
                        _isAvaliador
                            ? 'Nenhuma candidatura pendente de validação.'
                            : 'Ainda não submeteste nenhuma candidatura.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _candidaturas.length,
                      itemBuilder: (context, index) {
                        final cand = _candidaturas[index];
                        Color statusColor = Colors.orange;
                        if (cand['status'] == 'Aprovada')
                          statusColor = Colors.green;
                        if (cand['status'] == 'Rejeitada')
                          statusColor = Colors.red;

                        final statusPendente = ['Submetida', 'Em Correcao', 'Em Avaliacao Talent', 'Em Avaliacao Service'].contains(cand['status']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2E5B94).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.description_outlined,
                                    color: Color(0xFF2E5B94)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cand['name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_isAvaliador)
                                      Text(
                                        'Por: ${cand['userName']} (${cand['level']})',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12),
                                      )
                                    else
                                      Text(
                                        'Nível: ${cand['level']}',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Submetido a: ${cand['date']}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      cand['status'] ?? '',
                                      style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11),
                                    ),
                                  ),
                                  if (_isAvaliador && statusPendente)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextButton(
                                        onPressed: () =>
                                            _showAvaliarDialog(cand),
                                        child: const Text('Avaliar',
                                            style: TextStyle(
                                                color: Color(0xFF2E5B94),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
