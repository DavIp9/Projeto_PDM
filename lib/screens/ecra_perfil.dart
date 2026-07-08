import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/utilizador_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  String _error = '';

  String _perfilNome = '';
  String _serviceLineNome = '';
  String _areaNome = '';

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = Session.utilizador;
    if (user == null) {
      setState(() {
        _error = 'Utilizador não autenticado.';
        _isLoading = false;
      });
      return;
    }

    _nomeController.text = user.nomeUtilizador;
    _telefoneController.text = user.telefone;

    try {
      final perfil = await DatabaseHelper.instance.obterNomePerfil(user.idPerfil);
      final sl = await DatabaseHelper.instance.obterNomeServiceLine(user.idServiceLine);
      final area = await DatabaseHelper.instance.obterNomeArea(user.idArea);

      setState(() {
        _perfilNome = perfil;
        _serviceLineNome = sl;
        _areaNome = area;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar detalhes do perfil: $e';
        _isLoading = false;
      });
    }
  }

  void _saveProfile() async {
    final user = Session.utilizador;
    if (user == null) return;

    final nome = _nomeController.text.trim();
    final telefone = _telefoneController.text.trim();

    if (nome.isEmpty || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.atualizarDadosPerfil(user.idUtilizador, nome, telefone);
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.utilizador;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Nenhum utilizador logado.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E5B94),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'O Meu Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _nomeController.text = user.nomeUtilizador;
                  _telefoneController.text = user.telefone;
                  _isEditing = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
          ]
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header card with gradient
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2E5B94), Color(0xFF5B8AC6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.only(bottom: 30, top: 10),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, size: 60, color: Color(0xFF2E5B94)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!_isEditing)
                              Text(
                                user.nomeUtilizador,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: TextField(
                                  controller: _nomeController,
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: 'Nome',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              _perfilNome,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Informação Pessoal
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.person_outline, color: Color(0xFF2E5B94)),
                                    SizedBox(width: 12),
                                    Text(
                                      'Informações Pessoais',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow('Email', user.email, isEditable: false),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  'Telefone',
                                  user.telefone,
                                  isEditable: _isEditing,
                                  controller: _telefoneController,
                                ),
                                const Divider(height: 20),
                                _buildInfoRow('Data Ingresso', user.dataIngresso, isEditable: false),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Posicionamento Corporativo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.business_outlined, color: Color(0xFF2E5B94)),
                                    SizedBox(width: 12),
                                    Text(
                                      'Estrutura Softinsa',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow('Service Line', _serviceLineNome, isEditable: false),
                                const Divider(height: 20),
                                _buildInfoRow('Área', _areaNome, isEditable: false),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required bool isEditable, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        if (!isEditable)
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          )
        else
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: UnderlineInputBorder(),
            ),
          ),
      ],
    );
  }
}
