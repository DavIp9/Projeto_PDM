import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'verification_screen.dart';
import '../repositories/firestore_repository.dart';
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
  bool _isLoading = true;

  Area? _selectedArea;
  List<Area> _areas = [];

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
      final areas = await FirestoreRepository.instance.obterAreas();

      if (!mounted) return;

      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _areas = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível carregar as áreas: $e'),
        ),
      );
    }
  }

  Future<void> _register() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (nome.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }

    // A área só é obrigatória quando existem áreas configuradas no Firestore.
    if (_areas.isNotEmpty && _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma área profissional.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A password deve ter pelo menos 6 caracteres.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _aRegistar = true;
    });

    User? firebaseUser;

    try {
      // 1. Cria a conta no Firebase Authentication.
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('O Firebase não devolveu o novo utilizador.');
      }

      // 2. Guarda o nome no Firebase Authentication.
      await firebaseUser.updateDisplayName(nome);

      // 3. Cria automaticamente users/{uid} no Cloud Firestore.
      //
      // A password é passada apenas porque o método antigo ainda possui
      // esse parâmetro. O FirestoreRepository não guarda a password.
      await FirestoreRepository.instance.criarUtilizador(
        nome,
        email,
        password,
        '',
        _selectedArea?.idArea,
      );

      // 4. Envia o email de confirmação.
      await firebaseUser.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conta criada. Enviámos um email de confirmação.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(email: email),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao criar conta.';

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este email já está registado.';
          break;

        case 'weak-password':
          mensagem = 'A password é demasiado fraca.';
          break;

        case 'invalid-email':
          mensagem = 'O email introduzido não é válido.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O registo por email não está ativado no Firebase.';
          break;

        case 'network-request-failed':
          mensagem = 'Verifique a ligação à Internet.';
          break;

        default:
          mensagem = e.message ?? mensagem;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      /*
       * Se a conta tiver sido criada no Authentication, mas a criação
       * do documento Firestore falhar, elimina-se a conta incompleta.
       */
      try {
        await firebaseUser?.delete();
      } catch (_) {
        // A eliminação pode falhar se a sessão tiver expirado.
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar conta: $e'),
        ),
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
              _buildAreaField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _keepLoggedIn,
                      onChanged: _aRegistar
                          ? null
                          : (value) {
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
                    onTap: _aRegistar
                        ? null
                        : () {
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

  Widget _buildAreaField() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_areas.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: const Text(
          'Nenhuma área configurada',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return DropdownButtonFormField<Area>(
      value: _selectedArea,
      isExpanded: true,
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
      icon: const Icon(Icons.keyboard_arrow_down),
      items: _areas.map((area) {
        return DropdownMenuItem<Area>(
          value: area,
          child: Text(
            area.nomeArea,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _aRegistar
          ? null
          : (newValue) {
              setState(() {
                _selectedArea = newValue;
              });
            },
    );
  }
}