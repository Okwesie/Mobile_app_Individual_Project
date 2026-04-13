import 'package:url_launcher/url_launcher.dart';

class SmsService {
  SmsService._();
  static final SmsService instance = SmsService._();

  /// Opens the native SMS app pre-filled with [body] addressed to [number].
  /// Returns true if the intent was launched.
  Future<bool> sendSms({required String number, required String body}) async {
    final encoded = Uri.encodeComponent(body);
    final uri = Uri.parse('sms:$number?body=$encoded');

    if (!await canLaunchUrl(uri)) {
      // Fallback: try without the number so at least the composer opens
      final fallback = Uri.parse('sms:?body=$encoded');
      return launchUrl(fallback);
    }
    return launchUrl(uri);
  }

  /// Compose SMS with just a body (no pre-selected recipient).
  Future<bool> composeSms(String body) => sendSms(number: '', body: body);
}
