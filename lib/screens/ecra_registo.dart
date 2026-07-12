import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'verification_screen.dart';
import '../database/database_helper.dart';
import '../models/area_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _keepLoggedIn = false;
  bool _aRegistar = false;

  Area? _selectedArea;
  List<Area> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await DatabaseHelper.instance.obterAreas();

      if (!mounted) return;

      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar áreas: $e')),
      );
    }
  }

  Future<void> _register() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (nome.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A password deve ter pelo menos 6 caracteres.'),
        ),
      );
      return;
    }

    setState(() {
      _aRegistar = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /*
       * Guarda também o nome no utilizador do Firebase.
       * Para o "Bem-vindo", a tua aplicação pode continuar
       * a ler NOME_UTILIZADOR da SQLite.
       */
      await credential.user?.updateDisplayName(nome);

      await credential.user?.sendEmailVerification();

      /*
       * Aqui deixamos de usar email.split('@').first.
       * O primeiro argumento passa a ser o nome escrito pelo utilizador.
       */
      await DatabaseHelper.instance.criarUtilizador(
        nome,
        email,
        password,
        '910000000',
        _selectedArea!.idArea,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conta criada. Enviámos um email de confirmação.',
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(email: email),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao criar conta.';

      if (e.code == 'email-already-in-use') {
        mensagem = 'Este email já está registado.';
      } else if (e.code == 'weak-password') {
        mensagem = 'A password é demasiado fraca.';
      } else if (e.code == 'invalid-email') {
        mensagem = 'O email introduzido não é válido.';
      } else if (e.code == 'operation-not-allowed') {
        mensagem = 'O registo por email não está ativado no Firebase.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      /*
       * Se o Firebase criou a conta, mas a SQLite falhou,
       * apagamos a conta Firebase recém-criada para não ficar
       * uma conta incompleta.
       */
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar conta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _aRegistar = false;
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
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
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6D98CB),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _nomeController,
                labelText: 'Nome de utilizador',
                hintText: 'Introduza o seu nome',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              const Text(
                'Área',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<Area>(
                      decoration: InputDecoration(
                        hintText: 'Escolha a sua área profissional',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      value: _selectedArea,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _areas.map((Area area) {
                        return DropdownMenuItem<Area>(
                          value: area,
                          child: Text(
                            area.nomeArea,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (Area? newValue) {
                        setState(() {
                          _selectedArea = newValue;
                        });
                      },
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
                text: _aRegistar ? 'A registar...' : 'Registar',
                onPressed: _aRegistar ? null : _register,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem conta? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Iniciar sessão.',
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
