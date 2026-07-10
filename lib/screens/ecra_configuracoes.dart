import 'package:flutter/material.dart';
import 'ecra_perfil.dart';
import '../widgets/configuracoes_widgets.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool temaEscuro = false;
  bool notificacoesEmail = true;
  bool alertasExpiracaoBadges = true;
  bool resultadosCandidatura = true;
  bool aceitarTermosRgpd = false;

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmarExportacao({
    required String titulo,
    required String mensagem,
    required String mensagemSucesso,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _mostrarMensagem(mensagemSucesso);
              },
              child: const Text('Exportar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        temaEscuro ? const Color(0xFF121212) : const Color(0xFFF6F8FB);
    final Color appBarColor =
        temaEscuro ? const Color(0xFF1E1E1E) : const Color(0xFF2E5B94);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ConfiguracoesSectionTitle(
            title: 'Perfil e preferências pessoais',
            isDark: temaEscuro,
          ),
          ConfiguracoesCard(
            isDark: temaEscuro,
            children: [
              ConfiguracoesOptionTile(
                icon: Icons.person_outline,
                title: 'Perfil',
                subtitle: 'Ver e editar dados do perfil',
                isDark: temaEscuro,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ConfiguracoesOptionTile(
                icon: Icons.verified_user_outlined,
                title: 'Email de confirmação',
                subtitle: 'Estado da confirmação de registo',
                isDark: temaEscuro,
                trailing: Text(
                  'Verificado',
                  style: TextStyle(
                    color: Color(0xFF2E5B94),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConfiguracoesSectionTitle(
            title: 'Preferências do painel',
            isDark: temaEscuro,
          ),
          ConfiguracoesCard(
            isDark: temaEscuro,
            children: [
              ConfiguracoesSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: temaEscuro ? 'Tema escuro' : 'Tema claro',
                subtitle: temaEscuro
                    ? 'O modo escuro está ativo'
                    : 'O modo claro está ativo',
                isDark: temaEscuro,
                value: temaEscuro,
                onChanged: (value) {
                  setState(() {
                    temaEscuro = value;
                  });

                  _mostrarMensagem(
                    value
                        ? 'Tema escuro selecionado'
                        : 'Tema claro selecionado',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConfiguracoesSectionTitle(
            title: 'Notificações',
            isDark: temaEscuro,
          ),
          ConfiguracoesCard(
            isDark: temaEscuro,
            children: [
              ConfiguracoesSwitchTile(
                icon: Icons.email_outlined,
                title: 'Notificações por email',
                subtitle: 'Receber avisos importantes por email',
                value: notificacoesEmail,
                onChanged: (value) {
                  setState(() {
                    notificacoesEmail = value;
                  });
                },
              ),
              const Divider(height: 1),
              ConfiguracoesSwitchTile(
                icon: Icons.warning_amber_outlined,
                title: 'Alertas de expiração de badges',
                subtitle: 'Avisar quando um badge estiver perto de expirar',
                value: alertasExpiracaoBadges,
                onChanged: (value) {
                  setState(() {
                    alertasExpiracaoBadges = value;
                  });
                },
              ),
              const Divider(height: 1),
              ConfiguracoesSwitchTile(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Resultados de candidatura',
                subtitle: 'Receber avisos sobre aprovação ou rejeição',
                value: resultadosCandidatura,
                onChanged: (value) {
                  setState(() {
                    resultadosCandidatura = value;
                  });
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
                subtitle: 'Atualizar a palavra-passe da conta',
                onTap: () {
                  _mostrarMensagem(
                      'Opção de alterar palavra-passe selecionada');
                },
              ),
              const Divider(height: 1),
              ConfiguracoesSwitchTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Aceitar termos RGPD',
                subtitle: 'Permitir publicação e partilha de badges',
                value: aceitarTermosRgpd,
                onChanged: (value) {
                  setState(() {
                    aceitarTermosRgpd = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ConfiguracoesSectionTitle(
            title: 'Exportação de dados',
          ),
          ConfiguracoesCard(
            children: [
              ConfiguracoesOptionTile(
                icon: Icons.download_outlined,
                title: 'Exportar dados pessoais',
                subtitle: 'Gerar ficheiro com os dados da conta',
                onTap: () {
                  _confirmarExportacao(
                    titulo: 'Exportar dados pessoais',
                    mensagem:
                        'Pretende exportar os seus dados pessoais em formato digital?',
                    mensagemSucesso:
                        'Pedido de exportação de dados pessoais criado.',
                  );
                },
              ),
              const Divider(height: 1),
              ConfiguracoesOptionTile(
                icon: Icons.history_outlined,
                title: 'Exportar histórico de avaliações',
                subtitle: 'Gerar ficheiro com o histórico de candidaturas',
                onTap: () {
                  _confirmarExportacao(
                    titulo: 'Exportar histórico',
                    mensagem:
                        'Pretende exportar o histórico de avaliações e candidaturas?',
                    mensagemSucesso:
                        'Pedido de exportação do histórico criado.',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
