import 'package:url_launcher/url_launcher.dart';

const boobooWhatsappNumber = '6281224792834';

Future<bool> openBoobooWhatsapp(String message) async {
  final uri = Uri.https('wa.me', '/$boobooWhatsappNumber', {'text': message});
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
