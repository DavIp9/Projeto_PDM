import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/utilizador_model.dart';

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
    _isAvaliador = user != null && (user.idPerfil == 2 || user.idPerfil == 3 || user.idPerfil == 4);
    _loadCandidaturas();
  }

  Future<void> _loadCandidaturas() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper.instance.database;
      final user = Session.utilizador;
      if (user == null) return;

      if (_isAvaliador) {
        // Obter todas as candidaturas pendentes para avaliação
        final data = await db.rawQuery('''
          SELECT C.ID_CANDIDATURA as id, C.FASE as status, C.DATASUBMISSAO as date, 
                 U.NOME_UTILIZADOR as userName, N.NOME_NIVEL as level, B.NOME_BADGE as name,
                 B.PONTOS as points
          FROM CANDIDATURA C
          JOIN UTILIZADOR U ON C.ID_UTILIZADOR = U.ID_UTILIZADOR
          JOIN NIVEL N ON C.ID_NIVEL = N.ID_NIVEL
          JOIN BADGE B ON N.ID_BADGE = B.ID_BADGE
          WHERE C.FASE IN ('Submetida', 'Em Avaliacao Talent', 'Em Avaliacao Service', 'Em Correcao')
          ORDER BY C.DATASUBMISSAO DESC
        ''');
        setState(() {
          _candidaturas = data;
          _isLoading = false;
        });
      } else {
        // Obter as candidaturas apenas do utilizador consultor logado
        final data = await db.rawQuery('''
          SELECT C.ID_CANDIDATURA as id, C.FASE as status, C.DATASUBMISSAO as date, 
                 N.NOME_NIVEL as level, B.NOME_BADGE as name
          FROM CANDIDATURA C
          JOIN NIVEL N ON C.ID_NIVEL = N.ID_NIVEL
          JOIN BADGE B ON N.ID_BADGE = B.ID_BADGE
          WHERE C.ID_UTILIZADOR = ?
          ORDER BY C.DATASUBMISSAO DESC
        ''', [user.idUtilizador]);
        setState(() {
          _candidaturas = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter candidaturas: $e';
        _isLoading = false;
      });
    }
  }

  void _showAvaliarDialog(Map<String, dynamic> cand) async {
    final db = await DatabaseHelper.instance.database;
    final idCand = cand['id'] as int;

    // Obter evidências e ficheiros
    final evidences = await db.rawQuery('''
      SELECT E.ID_EVIDENCIA as idEvidencia, R.NOME_REQUISITO as reqName, 
             F.NOMEFICHEIRO as fileName, F.URL_FICHEIRO as fileUrl
      FROM EVIDENCIA E
      JOIN REQUISITO R ON E.ID_REQUISITO = R.ID_REQUISITO
      LEFT JOIN FICHEIROSEVIDENCIA F ON E.ID_EVIDENCIA = F.ID_EVIDENCIA
      WHERE E.ID_CANDIDATURA = ?
    ''', [idCand]);

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
                Text('Consultor: ${cand['userName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Nível: ${cand['level']}'),
                const SizedBox(height: 16),
                const Text('Evidências Submetidas:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                ...evidences.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('- Requisito: ${e['reqName']}', style: const TextStyle(fontSize: 13)),
                        Text('  Ficheiro: ${e['fileName'] ?? "N/A"}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text('Comentário/Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => _executarAvaliacao(cand, 'Rejeitada', commentController.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Rejeitar', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => _executarAvaliacao(cand, 'Aprovada', commentController.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Aprovar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _executarAvaliacao(Map<String, dynamic> cand, String acao, String comentario) async {
    final db = await DatabaseHelper.instance.database;
    final userEvaluator = Session.utilizador;
    if (userEvaluator == null) return;

    final idCand = cand['id'] as int;
    final points = cand['points'] as int? ?? 10;

    try {
      await db.transaction((txn) async {
        // 1. Obter info da candidatura (nomeadamente ID_UTILIZADOR consultor e ID_NIVEL)
        final infoRes = await txn.query('CANDIDATURA', where: 'ID_CANDIDATURA = ?', whereArgs: [idCand]);
        if (infoRes.isEmpty) return;
        final idConsultor = infoRes.first['ID_UTILIZADOR'] as int;
        final idNivel = infoRes.first['ID_NIVEL'] as int;

        int? idBadgeObtido;

        if (acao == 'Aprovada') {
          // Criar registo de badge obtido
          final boRes = await txn.rawQuery('SELECT MAX(ID_BADGEOBTIDO) as maxId FROM BADGE_OBTIDO');
          idBadgeObtido = (boRes.first['maxId'] as int? ?? 0) + 1;

          // Obter ID_BADGE a partir de NIVEL
          final lvlRes = await txn.query('NIVEL', where: 'ID_NIVEL = ?', whereArgs: [idNivel]);
          final idBadge = lvlRes.isNotEmpty ? lvlRes.first['ID_BADGE'] as int : 1;

          await txn.insert('BADGE_OBTIDO', {
            'ID_BADGEOBTIDO': idBadgeObtido,
            'ID_BADGE': idBadge,
            'ID_UTILIZADOR': idConsultor,
            'DATAOBTENCAO': DateTime.now().toString().split(' ')[0],
            'DATAEXPIRACAO': null,
            'PONTUACAO': points,
            'FASE': 'Ativo',
          });

          // Atualizar pontos e contadores do utilizador
          await txn.rawUpdate('''
            UPDATE UTILIZADOR 
            SET PONTUACAOTOTAL = PONTUACAOTOTAL + ?, BADGES_TOTAL = BADGES_TOTAL + 1
            WHERE ID_UTILIZADOR = ?
          ''', [points, idConsultor]);
        }

        // 2. Atualizar estado da candidatura
        await txn.update(
          'CANDIDATURA',
          {
            'FASE': acao,
            'ID_BADGEOBTIDO': idBadgeObtido,
          },
          where: 'ID_CANDIDATURA = ?',
          whereArgs: [idCand],
        );

        // 3. Inserir validação da candidatura
        final valRes = await txn.rawQuery('SELECT MAX(ID_VALIDACAO) as maxId FROM VALIDACAOCANDIDATURA');
        int nextValId = (valRes.first['maxId'] as int? ?? 0) + 1;

        await txn.insert('VALIDACAOCANDIDATURA', {
          'ID_VALIDACAO': nextValId,
          'ID_CANDIDATURA': idCand,
          'ID_UTILIZADOR': userEvaluator.idUtilizador,
          'DATAAVALIACAO': DateTime.now().toString().split(' ')[0],
          'ACAO': acao,
          'COMENTARIO': comentario,
          'FASE': 'Finalizada',
        });
      });

      if (!mounted) return;
      Navigator.pop(context); // Fechar dialog de avaliação
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
                        if (cand['status'] == 'Aprovada') statusColor = Colors.green;
                        if (cand['status'] == 'Rejeitada') statusColor = Colors.red;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E5B94).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.description_outlined, color: Color(0xFF2E5B94)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cand['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_isAvaliador)
                                      Text(
                                        'Por: ${cand['userName']} (${cand['level']})',
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      )
                                    else
                                      Text(
                                        'Nível: ${cand['level']}',
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Submetido a: ${cand['date']}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      cand['status'] ?? '',
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                  if (_isAvaliador)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextButton(
                                        onPressed: () => _showAvaliarDialog(cand),
                                        child: const Text('Avaliar', style: TextStyle(color: Color(0xFF2E5B94), fontWeight: FontWeight.bold)),
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
