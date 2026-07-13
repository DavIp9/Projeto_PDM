import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ecra_registo.dart';
import 'ecra_home.dart';
import 'alterar_password_primeiro_login.dart';
import '../database/database_helper.dart';
import '../models/utilizador_model.dart';
import 'recuperar_pass.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _keepLoggedIn = false;
  bool _aEntrar = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }

    setState(() {
      _aEntrar = true;
    });

    try {
      // O Firebase verifica se o email e a password estão corretos.
      final firebaseCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualiza os dados do utilizador Firebase.
      await firebaseCredential.user?.reload();

      final firebaseUser = FirebaseAuth.instance.currentUser;

      // Impede o acesso enquanto o email não estiver confirmado.
      if (firebaseUser == null || !firebaseUser.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Confirme o seu email antes de iniciar sessão.',
            ),
          ),
        );
        return;
      }

      // A SQLite procura apenas os dados do utilizador pelo email.
      // Já não compara a password local.
      final user = await DatabaseHelper.instance.obterUtilizadorPorEmail(email);

      if (user == null) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Utilizador não encontrado na base de dados local.',
            ),
          ),
        );
        return;
      }

      if (user.estado != 'Ativo') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta conta ainda não está ativa.'),
          ),
        );
        return;
      }

      Session.utilizador = user;

      if (!mounted) return;

      // Primeiro login: obriga a alterar a password.
      if (user.primeiroLogin == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlterarPasswordPrimeiroLoginScreen(
              email: email,
              passwordAtual: password,
            ),
          ),
        );
        return;
      }

      // Restantes logins: entra diretamente na aplicação.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainDashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao iniciar sessão.';

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-login-credentials') {
        mensagem = 'Email ou password incorretos.';
      } else if (e.code == 'invalid-email') {
        mensagem = 'O email introduzido não é válido.';
      } else if (e.code == 'too-many-requests') {
        mensagem = 'Demasiadas tentativas. Tente novamente mais tarde.';
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
          content: Text('Erro ao iniciar sessão: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _aEntrar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
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
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6D98CB),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'xxx@softinsa.pt',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Introduza a sua password',
                prefixIcon: Icons.lock_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _keepLoggedIn,
                      onChanged: (value) {
                        setState(() {
                          _keepLoggedIn = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Manter sessão iniciada'),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _aEntrar ? 'A entrar...' : 'Entrar',
                onPressed: _aEntrar ? null : _login,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _aEntrar
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    'Esqueceste-te da tua password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem conta? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registe-se.',
                      style: TextStyle(
                        color: Color(0xFF2E5B94),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
