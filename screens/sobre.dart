import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sobre',
          style: TextStyle(
            color: Color(0xFF2E5B94),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta plataforma gere e valida as competências dos consultores da Softinsa através de badges. O objetivo é reconhecer o talento e apoiar o crescimento profissional de forma transparente.',
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              // Sistema de Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_outlined, color: Color(0xFF2E5B94), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Sistema de Badges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Badges representam competências certificadas, associados a áreas técnicas e comportamentais, com níveis de senioridade de Júnior a Líder de Conhecimento.',
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Perfis
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFF2E5B94), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Perfis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfileItem('Consultor', 'Submete pedidos, faz upload de evidências e acompanha progresso'),
              const SizedBox(height: 12),
              _buildProfileItem('Talent Manager', 'Valida evidências e assegura cumprimento de SLA'),
              const SizedBox(height: 12),
              _buildProfileItem('Service Line Leader', 'Realiza validação final e aprova pedidos'),
              const SizedBox(height: 32),

              // Como Funciona
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF2E5B94), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Como Funciona',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5B94)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNumberedList([
                'Consultor submete pedido com evidências',
                'Talent Manager valida evidências',
                'Service Line Leader faz validação final',
                'Badge é aprovado ou devolvido com feedback',
              ]),
              const SizedBox(height: 32),

              const Divider(),
              const SizedBox(height: 16),

              // Privacy Footer
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                  children: [
                    TextSpan(text: 'Privacidade: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Cumprimento de RGPD. Partilha de badges apenas com consentimento.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        int index = entry.key + 1;
        String text = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
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
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
