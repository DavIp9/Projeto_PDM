import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';
import '../models/requisito_model.dart';
import '../models/utilizador_model.dart';

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
  final Map<int, String> _caminhosFicheiros = {};
  final Map<int, String> _nomesFicheiros = {};

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

  Future<void> _selecionarFicheiro(int idRequisito, StateSetter setModalState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        setModalState(() {
          _caminhosFicheiros[idRequisito] = result.files.single.path!;
          _nomesFicheiros[idRequisito] = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar ficheiro: $e')),
      );
    }
  }

  void _simularAvaliacaoAutomatico(int idCandidatura, int idNivel, String badgeNome, int pontos) async {
    await Future.delayed(const Duration(seconds: 5));

    try {
      final db = await DatabaseHelper.instance.database;
      final user = Session.utilizador;
      if (user == null) return;

      final isApproved = (DateTime.now().millisecond % 4) != 0;
      final String acao = isApproved ? 'Aprovada' : 'Rejeitada';
      final String comentario = isApproved
          ? 'Parabéns! As tuas evidências foram analisadas e consideradas conformes com os requisitos de nível.'
          : 'Infelizmente, as evidências submetidas não provam cabalmente a conformidade com todos os requisitos.';

      await db.transaction((txn) async {
        int? idBadgeObtido;

        if (isApproved) {
          final boRes = await txn.rawQuery('SELECT MAX(ID_BADGEOBTIDO) as maxId FROM BADGE_OBTIDO');
          idBadgeObtido = (boRes.first['maxId'] as int? ?? 0) + 1;

          final lvlRes = await txn.query('NIVEL', where: 'ID_NIVEL = ?', whereArgs: [idNivel]);
          final idBadge = lvlRes.isNotEmpty ? lvlRes.first['ID_BADGE'] as int : 1;

          await txn.insert('BADGE_OBTIDO', {
            'ID_BADGEOBTIDO': idBadgeObtido,
            'ID_BADGE': idBadge,
            'ID_UTILIZADOR': user.idUtilizador,
            'DATAOBTENCAO': DateTime.now().toString().split(' ')[0],
            'DATAEXPIRACAO': null,
            'PONTUACAO': pontos,
            'FASE': 'Ativo',
          });

          await txn.rawUpdate('''
            UPDATE UTILIZADOR 
            SET PONTUACAOTOTAL = PONTUACAOTOTAL + ?, BADGES_TOTAL = BADGES_TOTAL + 1
            WHERE ID_UTILIZADOR = ?
          ''', [pontos, user.idUtilizador]);
        }

        await txn.update(
          'CANDIDATURA',
          {
            'FASE': acao,
            'ID_BADGEOBTIDO': idBadgeObtido,
          },
          where: 'ID_CANDIDATURA = ?',
          whereArgs: [idCandidatura],
        );

        final valRes = await txn.rawQuery('SELECT MAX(ID_VALIDACAO) as maxId FROM VALIDACAOCANDIDATURA');
        int nextValId = (valRes.first['maxId'] as int? ?? 0) + 1;

        await txn.insert('VALIDACAOCANDIDATURA', {
          'ID_VALIDACAO': nextValId,
          'ID_CANDIDATURA': idCandidatura,
          'ID_UTILIZADOR': 2, // Filipe Sá (SLL)
          'DATAAVALIACAO': DateTime.now().toString().split(' ')[0],
          'ACAO': acao,
          'COMENTARIO': comentario,
          'FASE': 'Finalizada',
        });

        final notRes = await txn.rawQuery('SELECT MAX(ID_NOTIFICACAO) as maxId FROM NOTIFICACOES');
        int idNotif = (notRes.first['maxId'] as int? ?? 0) + 1;

        await txn.insert('NOTIFICACOES', {
          'ID_NOTIFICACAO': idNotif,
          'ID_BADGEOBTIDO': idBadgeObtido,
          'ID_CANDIDATURA': idCandidatura,
          'ID_UTILIZADOR': user.idUtilizador,
          'TIPO_NOTIFICACAO': acao,
          'MENSAGEM': isApproved
              ? 'A tua candidatura ao badge "$badgeNome" foi Aprovada! Parabéns, ganhaste $pontos pontos!'
              : 'A tua candidatura ao badge "$badgeNome" foi Rejeitada. Motivo: $comentario',
          'DATACRIACAO': DateTime.now().toString().split(' ')[0],
          'FASE': 'Nao Lida',
          'TITULO': isApproved ? 'Candidatura Aprovada!' : 'Candidatura Rejeitada',
        });
      });

      if (user.idUtilizador == Session.utilizador?.idUtilizador) {
        final updatedRes = await db.query('UTILIZADOR', where: 'ID_UTILIZADOR = ?', whereArgs: [user.idUtilizador]);
        if (updatedRes.isNotEmpty) {
          Session.utilizador = Utilizador.fromMap(updatedRes.first);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isApproved ? Colors.green[700] : Colors.red[700],
            duration: const Duration(seconds: 4),
            content: Text(
              isApproved
                  ? 'A tua candidatura ao badge "$badgeNome" foi Aprovada! (+ $pontos pts)'
                  : 'A tua candidatura ao badge "$badgeNome" foi Recusada por falta de evidências.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      print('Erro na avaliação simulada: $e');
    }
  }

  void _showSubmitModal() {
    _caminhosFicheiros.clear();
    _nomesFicheiros.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      'Selecione um ficheiro de evidência real para cada um dos requisitos abaixo.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ..._requisitos.map((req) {
                      final temFicheiro = _nomesFicheiros.containsKey(req.idRequisito);
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
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _nomesFicheiros[req.idRequisito] ?? 'Nenhum ficheiro selecionado',
                                      style: TextStyle(
                                        color: temFicheiro ? Colors.black87 : Colors.grey,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _selecionarFicheiro(req.idRequisito, setModalState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E5B94),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.attach_file, color: Colors.white, size: 18),
                                  label: const Text('Escolher', style: TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        bool allFilled = true;
                        for (var req in _requisitos) {
                          if (!_caminhosFicheiros.containsKey(req.idRequisito)) {
                            allFilled = false;
                            break;
                          }
                        }

                        if (!allFilled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, selecione um ficheiro para todos os requisitos.')),
                          );
                          return;
                        }

                        try {
                          final user = Session.utilizador;
                          if (user == null) return;
                          final idNivel = widget.badge['idNivel'] as int;
                          final badgeNome = widget.badge['name'] as String? ?? 'Badge';
                          final pontos = widget.badge['points'] as int? ?? 10;
                          
                          final idCandidatura = await DatabaseHelper.instance.submeterCandidaturaComEvidencias(
                            user.idUtilizador,
                            idNivel,
                            _caminhosFicheiros,
                          );

                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Candidatura submetida com sucesso!')),
                          );

                          _simularAvaliacaoAutomatico(idCandidatura, idNivel, badgeNome, pontos);
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
