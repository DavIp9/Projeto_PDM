import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _emailController = TextEditingController();

  bool _aEnviar = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarEmailRecuperacao() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduza o seu email.'),
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduza um email válido.'),
        ),
      );
      return;
    }

    setState(() {
      _aEnviar = true;
    });

    try {
      // Coloca o email do Firebase em português.
      await FirebaseAuth.instance.setLanguageCode('pt');

      // Envia o email seguro de recuperação.
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.mark_email_read_outlined,
              size: 50,
              color: Color(0xFF2E5B94),
            ),
            title: const Text(
              'Email enviado',
              textAlign: TextAlign.center,
            ),
            content: Text(
              'Enviámos um link de recuperação para:\n\n'
              '$email\n\n'
              'Abra o email e escolha uma nova password. '
              'Verifique também a pasta de spam.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5B94),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Volta ao ecrã de login.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Não foi possível enviar o email de recuperação.';

      if (e.code == 'invalid-email') {
        mensagem = 'O email introduzido não é válido.';
      } else if (e.code == 'too-many-requests') {
        mensagem =
            'Foram feitas demasiadas tentativas. Tente novamente mais tarde.';
      } else if (e.code == 'network-request-failed') {
        mensagem = 'Verifique a ligação à Internet.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao recuperar password: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _aEnviar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF2E5B94),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'SOFTINSA',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5B94),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Recuperar Password',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6D98CB),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Icon(
                Icons.lock_reset_outlined,
                size: 80,
                color: Color(0xFF2E5B94),
              ),
              const SizedBox(height: 24),
              const Text(
                'Introduza o email associado à sua conta. '
                'Vai receber um link seguro para escolher uma nova password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'xxx@softinsa.pt',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _aEnviar ? 'A enviar...' : 'Enviar email de recuperação',
                onPressed: _aEnviar ? null : _enviarEmailRecuperacao,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _aEnviar
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text(
                  'Voltar ao login',
                  style: TextStyle(
                    color: Color(0xFF2E5B94),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
