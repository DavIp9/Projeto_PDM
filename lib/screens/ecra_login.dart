import 'package:flutter/material.dart';
import 'ecra_registo.dart';
import 'ecra_home.dart';
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

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      final user = await DatabaseHelper.instance.autenticarUtilizador(email, password);
      
      if (user != null) {
        if (user.estado != 'Ativo') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Esta conta ainda não está ativa.')),
          );
          return;
        }
        
        Session.utilizador = user;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainDashboardScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciais incorretas.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar sessão: $e')),
      );
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
              // Logo Placeholder
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
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Manter sessão iniciada'),
                ],
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Entrar',
                onPressed: _login,
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
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
                              builder: (_) => const SignUpScreen()));
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
