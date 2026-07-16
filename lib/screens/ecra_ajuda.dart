import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ajuda',
          style: TextStyle(
            color: Color(0xFF2E5B94),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildExpansionTile(
                title: 'Sistema de Badges',
                icon: Icons.workspace_premium_outlined,
                content: const Text(
                  'Os badges certificam competências técnicas e comportamentais dos consultores da Softinsa, promovendo reconhecimento, evolução profissional e transparência no processo de avaliação.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'Como pedir um Badge',
                icon: Icons.description_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNumberedList([
                      'Acede ao Catálogo de Badges',
                      'Seleciona o badge pretendido',
                      'Consulta os requisitos e critérios',
                      'Submete o pedido com evidências',
                      'Aguarda validação do Talent Manager'
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        border: const Border(
                          left: BorderSide(color: Color(0xFFFFC107), width: 4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFFFFC107), size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Pedidos incompletos podem ser devolvidos.',
                              style: TextStyle(color: Color(0xFFB08D00), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'Evidências aceites',
                icon: Icons.check_circle_outline,
                content: const Text(
                  'Podem ser submetidos certificados, links de repositórios, documentos ou qualquer comprovativo válido para os requisitos do badge.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'Pedido devolvido ou rejeitado',
                icon: Icons.cancel_outlined,
                content: const Text(
                  'Se o pedido for devolvido, terás acesso a feedback para corrigir o problema. Se for rejeitado, significa que não cumpre os requisitos.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'SLA — Tempo de Resposta',
                icon: Icons.access_time,
                content: const Text(
                  'O Talent Manager tem um prazo (SLA) para validar as evidências submetidas e responder ao teu pedido.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'Notificações',
                icon: Icons.notifications_none,
                content: const Text(
                  'Receberás alertas na aplicação sobre a mudança de estado dos teus pedidos e novos badges disponíveis.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'Partilha de Badges',
                icon: Icons.ios_share,
                content: const Text(
                  'Podes partilhar os teus badges em redes sociais ou anexá-los ao teu portefólio com aprovação prévia.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              _buildExpansionTile(
                title: 'Acompanhamento',
                icon: Icons.trending_up,
                content: const Text(
                  'Acompanha todo o progresso dos teus pedidos e histórico através do teu Perfil.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required IconData icon, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF2E5B94),
          collapsedIconColor: const Color(0xFF2E5B94),
          leading: Icon(icon, color: const Color(0xFF2E5B94)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        int index = entry.key + 1;
        String text = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E5B94),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
