class AppMessage {
  const AppMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.photo,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  final int id;
  final String title;
  final String message;
  final String photo;
  final String createdAt;
  final bool isRead;
  final String type;

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: _intValue(json['id']),
      title: json['title']?.toString() ?? 'Pesan Booboo',
      message: json['message']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read']?.toString() == '1',
      type: json['type']?.toString() ?? 'personal',
    );
  }
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
