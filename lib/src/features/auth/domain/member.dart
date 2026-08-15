class Member {
  const Member({
    required this.id,
    required this.idNumber,
    required this.fullname,
    required this.phone,
    required this.address,
    required this.avatar,
    required this.points,
  });

  final int id;
  final String idNumber;
  final String fullname;
  final String phone;
  final String address;
  final String avatar;
  final int points;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: (json['id'] as num).toInt(),
      idNumber: json['id_number']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}
