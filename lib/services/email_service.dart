import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailService {
  EmailService._();

  static final EmailService instance = EmailService._();

  static const String _serviceId = 'service_59sdxcq';
  static const String _templateId = 'template_8pxjolo';
  static const String _publicKey = 'dUv8-7YCbwinJGOoS';

  static final Uri _sendUri = Uri.parse(
    'https://api.emailjs.com/api/v1.0/email/send',
  );

  Future<void> enviarCandidaturaSubmetida({
    required String nome,
    required String email,
    required String badge,
    required String nivel,
  }) async {
    final emailNormalizado = email.trim();

    if (emailNormalizado.isEmpty) {
      throw ArgumentError(
        'O utilizador não possui um endereço de email.',
      );
    }

    final response = await http.post(
      _sendUri,
      headers: const {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'user_name': nome.trim(),
          'user_email': emailNormalizado,
          'badge_name': badge.trim(),
          'level_name': nivel.trim(),
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'EmailJS ${response.statusCode}: ${response.body}',
      );
    }
  }
}
