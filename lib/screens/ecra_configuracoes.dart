import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ecra_perfil.dart';
import 'ecra_login.dart';
import 'recuperar_pass.dart';

import '../widgets/configuracoes_widgets.dart';
import '../repositories/firestore_repository.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _aCarregar = true;
  bool _aEliminarConta = false;
  bool _termosRgpdAceites = false;

  @override
  void initState() {
    super.initState();
    _carregarEstadoRgpd();
  }

  Future<void> _carregarEstadoRgpd() async {
    final utilizador = FirebaseAuth.instance.currentUser;

    if (utilizador == null) {
      if (!mounted) return;

      setState(() {
        _aCarregar = false;
      });

      return;
    }

    try {
      final documento = await FirebaseFirestore.instance
          .collection('users')
          .doc(utilizador.uid)
          .get();

      if (!mounted) return;

      setState(() {
        _termosRgpdAceites = documento.data()?['rgpdAccepted'] == true;

        _aCarregar = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _aCarregar = false;
      });

      _mostrarMensagem(
        'Não foi possível carregar as configurações.',
      );
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _tituloTermos(String texto) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 5,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF243247),
        ),
      ),
    );
  }

  Widget _pontoTermos(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.circle,
              size: 5,
              color: Color(0xFF416EA9),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                height: 1.35,
                color: Color(0xFF4D5665),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarTermosRgpd() async {
    final aceite = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            0,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            4,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          title: const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE8EFF8),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Color(0xFF416EA9),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Termos RGPD',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Versão 1.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ao aceitar estes termos, autoriza a aplicação '
                    'Softinsa Badges a tratar os dados pessoais '
                    'estritamente necessários ao funcionamento da '
                    'plataforma.',
                    style: TextStyle(
                      height: 1.4,
                      color: Color(0xFF4D5665),
                    ),
                  ),
                  _tituloTermos(
                    'Dados pessoais tratados',
                  ),
                  _pontoTermos(
                    'Nome, email, telefone e área profissional.',
                  ),
                  _pontoTermos(
                    'Candidaturas, evidências e comprovativos '
                    'submetidos.',
                  ),
                  _pontoTermos(
                    'Badges obtidos, pontos, nível e posição no '
                    'ranking.',
                  ),
                  _pontoTermos(
                    'Notificações e histórico de atividade na '
                    'aplicação.',
                  ),
                  _tituloTermos(
                    'Finalidades do tratamento',
                  ),
                  _pontoTermos(
                    'Gerir candidaturas e validar a atribuição '
                    'de badges.',
                  ),
                  _pontoTermos(
                    'Calcular pontos, níveis, rankings e percursos '
                    'de aprendizagem.',
                  ),
                  _pontoTermos(
                    'Apresentar o perfil, histórico e progresso '
                    'do utilizador.',
                  ),
                  _pontoTermos(
                    'Enviar notificações relacionadas com a '
                    'plataforma.',
                  ),
                  _tituloTermos(
                    'Direitos do utilizador',
                  ),
                  _pontoTermos(
                    'Consultar, corrigir ou atualizar os seus '
                    'dados pessoais.',
                  ),
                  _pontoTermos(
                    'Retirar o consentimento a qualquer momento.',
                  ),
                  _pontoTermos(
                    'Solicitar a eliminação permanente da conta '
                    'e dos dados.',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'A retirada do consentimento pode limitar '
                      'funcionalidades que dependem do tratamento '
                      'destes dados.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF616B79),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                _termosRgpdAceites ? 'Fechar' : 'Cancelar',
              ),
            ),
            if (!_termosRgpdAceites)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF416EA9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Li e aceito'),
              ),
          ],
        );
      },
    );

    if (aceite == true) {
      await _guardarRgpd(true);
    }
  }

  Future<void> _confirmarRetiradaRgpd() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Retirar consentimento?',
          ),
          content: const Text(
            'Algumas funcionalidades podem ficar indisponíveis '
            'depois de retirar o consentimento RGPD.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Retirar consentimento',
                style: TextStyle(
                  color: Color(0xFFC63D45),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _guardarRgpd(false);
    }
  }

  Future<void> _guardarRgpd(bool aceite) async {
    final utilizador = FirebaseAuth.instance.currentUser;

    if (utilizador == null) {
      _mostrarMensagem(
        'Utilizador não autenticado.',
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(utilizador.uid)
          .set(
        {
          'rgpdAccepted': aceite,
          'rgpdAcceptedAt': aceite ? FieldValue.serverTimestamp() : null,
          'rgpdVersion': aceite ? '1.0' : null,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        _termosRgpdAceites = aceite;
      });

      _mostrarMensagem(
        aceite ? 'Termos RGPD aceites.' : 'Consentimento RGPD retirado.',
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível atualizar os termos RGPD.',
      );
    }
  }

  Future<void> _confirmarEliminacaoConta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Eliminar conta',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Esta ação é permanente.',
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            20,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E9EF),
                      foregroundColor: const Color(0xFF2E5B94),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _aEliminarConta = true;
    });

    try {
      await FirestoreRepository.instance.eliminarContaEDados();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _aEliminarConta = false;
      });

      final mensagem = e.code == 'requires-recent-login'
          ? 'Por segurança, termine sessão, volte a entrar '
              'e tente eliminar a conta novamente.'
          : 'Não foi possível eliminar a conta.';

      _mostrarMensagem(mensagem);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _aEliminarConta = false;
      });

      _mostrarMensagem(
        'Não foi possível eliminar a conta: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_aCarregar) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFF2E5B94),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ConfiguracoesSectionTitle(
            title: 'Perfil',
          ),
          ConfiguracoesCard(
            children: [
              ConfiguracoesOptionTile(
                icon: Icons.person_outline,
                title: 'O meu perfil',
                subtitle: 'Ver e editar os dados do perfil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ConfiguracoesSectionTitle(
            title: 'Segurança e privacidade',
          ),
          ConfiguracoesCard(
            children: [
              ConfiguracoesOptionTile(
                icon: Icons.lock_outline,
                title: 'Alterar palavra-passe',
                subtitle: 'Receber um email para alterar a palavra-passe',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ConfiguracoesSwitchTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Termos RGPD',
                subtitle: _termosRgpdAceites
                    ? 'Termos aceites — versão 1.0'
                    : 'Ler e aceitar os termos de proteção '
                        'de dados',
                value: _termosRgpdAceites,
                onChanged: (value) async {
                  if (value) {
                    await _mostrarTermosRgpd();
                  } else {
                    await _confirmarRetiradaRgpd();
                  }
                },
              ),
              const Divider(height: 1),
              ConfiguracoesOptionTile(
                icon: Icons.delete_forever_outlined,
                title: 'Eliminar conta',
                subtitle: _aEliminarConta
                    ? 'A eliminar conta e dados...'
                    : 'Eliminar permanentemente a conta e os dados',
                trailing: _aEliminarConta
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right,
                        color: Colors.red,
                      ),
                onTap: _aEliminarConta ? null : _confirmarEliminacaoConta,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'A eliminação da conta remove permanentemente '
            'todos os dados associados ao utilizador.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
