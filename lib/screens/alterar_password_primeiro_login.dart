import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ecra_home.dart';
import '../repositories/firestore_repository.dart';
import '../models/utilizador_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AlterarPasswordPrimeiroLoginScreen extends StatefulWidget {
  final String email;
  final String passwordAtual;

  const AlterarPasswordPrimeiroLoginScreen({
    super.key,
    required this.email,
    required this.passwordAtual,
  });

  @override
  State<AlterarPasswordPrimeiroLoginScreen> createState() =>
      _AlterarPasswordPrimeiroLoginScreenState();
}

class _AlterarPasswordPrimeiroLoginScreenState
    extends State<AlterarPasswordPrimeiroLoginScreen> {
  final _passwordAtualController = TextEditingController();
  final _novaPasswordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _aAlterar = false;

  @override
  void dispose() {
    _passwordAtualController.dispose();
    _novaPasswordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _alterarPassword() async {
    final passwordAtual = _passwordAtualController.text.trim();
    final novaPassword = _novaPasswordController.text.trim();
    final confirmarPassword = _confirmarPasswordController.text.trim();

    if (passwordAtual.isEmpty ||
        novaPassword.isEmpty ||
        confirmarPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );
      return;
    }

    if (passwordAtual != widget.passwordAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A password atual está incorreta.'),
        ),
      );
      return;
    }

    if (novaPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A nova password deve ter pelo menos 6 caracteres.'),
        ),
      );
      return;
    }

    if (novaPassword == passwordAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A nova password deve ser diferente da atual.'),
        ),
      );
      return;
    }

    if (novaPassword != confirmarPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As novas passwords não coincidem.'),
        ),
      );
      return;
    }

    setState(() {
      _aAlterar = true;
    });

    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        final loginFirebase =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: passwordAtual,
        );

        firebaseUser = loginFirebase.user;
      }

      if (firebaseUser == null) {
        throw Exception(
            'Não foi possível autenticar o utilizador no Firebase.');
      }

      final credential = EmailAuthProvider.credential(
        email: widget.email,
        password: passwordAtual,
      );

      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(novaPassword);

      await FirestoreRepository.instance.alterarPasswordPrimeiroLogin(
        widget.email,
        novaPassword,
      );

      final utilizadorAtualizado =
          await FirestoreRepository.instance.autenticarUtilizador(
        widget.email,
        novaPassword,
      );

      if (utilizadorAtualizado == null) {
        throw Exception('Não foi possível carregar o utilizador atualizado.');
      }

      Session.utilizador = utilizadorAtualizado;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password alterada com sucesso.'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainDashboardScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao alterar a password.';

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {
        mensagem = 'A password atual está incorreta.';
      } else if (e.code == 'weak-password') {
        mensagem = 'A nova password é demasiado fraca.';
      } else if (e.code == 'requires-recent-login') {
        mensagem = 'Volte a iniciar sessão e tente novamente.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alterar password: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _aAlterar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 95),
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
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Alterar a Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2E5B94),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                controller: _passwordAtualController,
                labelText: 'Password Atual',
                hintText: 'Introduza a sua password atual',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _novaPasswordController,
                labelText: 'Password Nova',
                hintText: 'Introduza a sua password nova',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmarPasswordController,
                labelText: 'Confirmar Password',
                hintText: 'Introduza novamente a sua password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: _aAlterar ? 'A alterar...' : 'Alterar e Entrar',
                onPressed: _aAlterar ? null : _alterarPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
