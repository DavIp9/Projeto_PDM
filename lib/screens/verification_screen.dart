import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ecra_login.dart';
import '../repositories/firestore_repository.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;

  void _verify() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await user?.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ainda não confirmou o email. Verifique a sua caixa de entrada.',
            ),
          ),
        );

        setState(() {
          _isLoading = false;
        });

        return;
      }

      await FirestoreRepository.instance.ativarUtilizador(widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta verificada com sucesso!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar conta: $e')),
      );
    }
  }

  void _reenviarEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      await user?.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de verificação reenviado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reenviar email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 90),
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
                  'Verificação de Registo',
                  style: TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2E5B94),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Enviámos um email de confirmação para:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 24),
              const Text(
                'Abra o seu email e clique no link de confirmação.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5B94),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Já confirmei o email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _reenviarEmail,
                child: const Text('Reenviar email de confirmação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
