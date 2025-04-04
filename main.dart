sendWhatsAppBusinessMessage("+1234567890", "Ceci est un message de test via WhatsApp Business.");

void sendMessage(String phone, String message, bool sendSMS, bool sendWhatsApp, bool sendTelegram, bool sendMessenger) {
  if (sendSMS) {
    Telephony.instance.sendSms(to: phone, message: message);
  }
  if (sendWhatsApp) {
    sendWhatsAppBusinessMessage(phone, message);
  }
  if (sendTelegram) {
    sendTelegramMessage(message);
  }
  if (sendMessenger) {
    sendMessengerMessage(message);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendWhatsAppBusinessMessage(String phone, String message) async {
  final String url = 'https://graph.facebook.com/v12.0/<YourPhoneNumberID>/messages';
  final String accessToken = '<YourAccessToken>'; // Remplace par ton access token

  final Map<String, dynamic> payload = {
    'messaging_product': 'whatsapp',
    'to': phone,
    'text': {'body': message},
  };

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    print('Message envoyé avec succès via WhatsApp Business');
  } else {
    print('Erreur lors de l\'envoi du message: ${response.body}');
  }
}