import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/firestore_repository.dart';
import '../models/requisito_model.dart';
import '../models/utilizador_model.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DetalhesBadgeScreen extends StatefulWidget {
  final Map<String, dynamic> badge;

  const DetalhesBadgeScreen({super.key, required this.badge});

  @override
  State<DetalhesBadgeScreen> createState() => _DetalhesBadgeScreenState();
}

class _DetalhesBadgeScreenState extends State<DetalhesBadgeScreen> {
  List<Requisito> _requisitos = [];
  bool _isLoading = true;
  bool _isConquistado = false;
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
      final reqs =
          await FirestoreRepository.instance.obterRequisitosPorNivel(idNivel);

      final earnedBadges =
          await FirestoreRepository.instance.obterBadgesConquistados();

      final badgeId = widget.badge['id']?.toString();
      final legacyId = widget.badge['ID_BADGE'];

      final conquistado = earnedBadges.any((b) {
        final bId = b['id']?.toString();
        final bLegacyId = b['ID_BADGE'];

        final matchesDocId = bId != null && badgeId != null && bId == badgeId;
        final matchesLegacyId =
            bLegacyId != null && legacyId != null && bLegacyId == legacyId;

        return matchesDocId || matchesLegacyId;
      });

      setState(() {
        _requisitos = reqs;
        _isConquistado = conquistado;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erro ao obter requisitos: $e';
      });
    }
  }

  Future<void> _selecionarFicheiro(
      int idRequisito, StateSetter setModalState) async {
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

  void _simularAvaliacaoAutomatico(
      String idCandidatura, int idNivel, String badgeNome, int pontos) async {
    await Future.delayed(const Duration(seconds: 5));

    try {
      final user = Session.utilizador;
      if (user == null) return;

      final isApproved = (DateTime.now().millisecond % 4) != 0;
      final String comentario = isApproved
          ? 'Parabéns! As tuas evidências foram analisadas e consideradas conformes com os requisitos de nível.'
          : 'Infelizmente, as evidências submetidas não provam cabalmente a conformidade com todos os requisitos.';

      await FirestoreRepository.instance
          .evaluateApplication(idCandidatura, isApproved, comentario);

      final updatedUser =
          await FirestoreRepository.instance.obterUtilizadorAtual();
      if (updatedUser != null) {
        Session.utilizador = updatedUser;
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
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
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5B94)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione um ficheiro de evidência real para cada um dos requisitos abaixo.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ..._requisitos.map((req) {
                      final temFicheiro =
                          _nomesFicheiros.containsKey(req.idRequisito);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.nomeRequisito,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _nomesFicheiros[req.idRequisito] ??
                                          'Nenhum ficheiro selecionado',
                                      style: TextStyle(
                                        color: temFicheiro
                                            ? Colors.black87
                                            : Colors.grey,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _selecionarFicheiro(
                                      req.idRequisito, setModalState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E5B94),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.attach_file,
                                      color: Colors.white, size: 18),
                                  label: const Text('Escolher',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13)),
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
                          if (!_caminhosFicheiros
                              .containsKey(req.idRequisito)) {
                            allFilled = false;
                            break;
                          }
                        }

                        if (!allFilled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Por favor, selecione um ficheiro para todos os requisitos.')),
                          );
                          return;
                        }

                        try {
                          final user = Session.utilizador;
                          if (user == null) return;
                          final idNivel = widget.badge['idNivel'] as int;
                          final badgeNome =
                              widget.badge['name'] as String? ?? 'Badge';
                          final pontos = widget.badge['points'] as int? ?? 10;

                          final idCandidatura = await FirestoreRepository
                              .instance
                              .submeterCandidaturaComEvidencias(
                            user.idUtilizador,
                            idNivel,
                            _caminhosFicheiros,
                          );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Candidatura submetida com sucesso!')),
                          );

                          _simularAvaliacaoAutomatico(
                              idCandidatura, idNivel, badgeNome, pontos);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao submeter: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5B94),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Submeter Candidatura',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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

  Future<void> _gerarEPartilharCertificado() async {
    setState(() => _isLoading = true);
    try {
      final user = Session.utilizador ??
          await FirestoreRepository.instance.obterUtilizadorAtual();
      if (user == null) throw Exception('Utilizador não autenticado.');

      final pdf = pw.Document();

      final String name = widget.badge['name'] ?? 'Badge';
      final String level = widget.badge['level'] ?? 'Base';
      final String area = widget.badge['area'] ?? 'Área desconhecida';
      final int points = widget.badge['points'] ?? 0;
      final String description = widget.badge['description'] ?? '';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.amber, width: 4),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'CERTIFICADO DE CONQUISTA',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2E5B94'),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Certifica-se que o/a consultor(a)',
                    style: pw.TextStyle(
                        fontSize: 14, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    user.nomeUtilizador,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'conquistou com sucesso o badge',
                    style: pw.TextStyle(
                        fontSize: 14, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    name,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#2E5B94'),
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'na área de especialidade: $area',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Nível: $level | Pontuação: $points Pontos',
                    style: pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 30),
                  if (description.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                      child: pw.Text(
                        description,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  pw.SizedBox(height: 50),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Gerado automaticamente pela aplicação Softinsa Badges',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey500),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final sanitizedBadgeName =
          name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final path = '${dir.path}/certificado_$sanitizedBadgeName.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      setState(() => _isLoading = false);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Conquistei o badge "$name" na Softinsa! 🏆🚀',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar certificado: $e')),
        );
      }
    }
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.badge['rarity'] == 'Especial'
                        ? [const Color(0xFFF1C40F), const Color(0xFFF39C12)]
                        : [const Color(0xFF2E5B94), const Color(0xFF5B8AC6)],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFFC107), size: 20),
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Text(
                  widget.badge['description'] ?? 'Sem descrição disponível.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                                    '${req.nomeRequisito}: ${req.descricao} (${req.tipoEvidencia ?? "PDF"})');
                              }).toList(),
                            )
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (!_isLoading && _error.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _isConquistado
                    ? ElevatedButton.icon(
                        onPressed: _gerarEPartilharCertificado,
                        icon: const Icon(Icons.share, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        label: const Text(
                          'Partilhar Certificado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _showSubmitModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5B94),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Submeter Evidências',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
