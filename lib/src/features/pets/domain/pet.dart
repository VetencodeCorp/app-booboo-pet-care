class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.jenisId,
    required this.jenisHewan,
    required this.genderCode,
    required this.gender,
    required this.image,
    this.ownerName,
    this.totalRiwayat,
    this.kunjunganTerakhir,
  });

  final int id;
  final String name;
  final int? jenisId;
  final String jenisHewan;
  final String genderCode;
  final String gender;
  final String image;
  final String? ownerName;
  final int? totalRiwayat;
  final String? kunjunganTerakhir;

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      jenisId: (json['jenis_id'] as num?)?.toInt(),
      jenisHewan: json['jenis_hewan']?.toString() ?? '',
      genderCode: json['gender_code']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      ownerName: json['owner_name']?.toString(),
      totalRiwayat: (json['total_riwayat'] as num?)?.toInt(),
      kunjunganTerakhir: json['kunjungan_terakhir']?.toString(),
    );
  }
}
