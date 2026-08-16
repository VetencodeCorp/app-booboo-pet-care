import '../constants/api_config.dart';

String normalizePatientImageUrl(String? rawUrl) {
  final url = rawUrl?.trim() ?? '';
  if (url.isEmpty) return '';

  final uri = Uri.tryParse(url);
  final path = uri?.path ?? url;
  const patientImagePath = '/assets/images/pasien/';
  final index = path.indexOf(patientImagePath);

  if (index == -1) return url;

  final filename = path.substring(index + patientImagePath.length);
  if (filename.isEmpty) return url;

  final encodedFilename = filename.replaceAll('.', '~');
  return '${ApiConfig.baseUrl}/api/patient-image/$encodedFilename';
}
