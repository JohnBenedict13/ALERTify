import 'package:http/http.dart' as http;
import 'dart:convert';

/// 🔐 EMAILJS CONFIG (FINAL & CORRECT)
const String serviceId = 'service_9xuj6at';
const String templateId = 'template_wekswri';
const String publicKey = 's_PuVVHmHwNznZ2Wv';

Future<void> sendOtpEmail(String email, String otp) async {
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'origin': 'http://localhost', // REQUIRED by EmailJS
    },
    body: jsonEncode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': publicKey,
      'template_params': {'to_email': email, 'otp': otp},
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('EmailJS failed: ${response.statusCode} ${response.body}');
  }
}
