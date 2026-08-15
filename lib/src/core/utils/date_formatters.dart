import 'package:intl/intl.dart';

class DateFormatters {
  static final _short = DateFormat('d MMM yyyy', 'id_ID');

  static String short(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return _short.format(date);
  }
}
