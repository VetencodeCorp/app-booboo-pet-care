import '../../../core/utils/image_url_normalizer.dart';

class PetHistory {
  const PetHistory({
    required this.id,
    required this.tanggal,
    required this.petId,
    required this.petName,
    required this.petImage,
    required this.jenisHewan,
    required this.layanan,
    required this.kategoriLayanan,
    required this.bb,
    required this.suhu,
    required this.diagnosa,
    required this.tindakan,
    required this.catatan,
    required this.dokter,
    required this.nota,
    required this.statusPembayaran,
  });

  final int id;
  final String? tanggal;
  final int? petId;
  final String? petName;
  final String? petImage;
  final String? jenisHewan;
  final String? layanan;
  final String? kategoriLayanan;
  final String? bb;
  final String? suhu;
  final String? diagnosa;
  final String? tindakan;
  final String? catatan;
  final String? dokter;
  final String? nota;
  final String statusPembayaran;

  factory PetHistory.fromJson(Map<String, dynamic> json) {
    return PetHistory(
      id: (json['id'] as num).toInt(),
      tanggal: json['tanggal']?.toString(),
      petId: (json['pet_id'] as num?)?.toInt(),
      petName: json['pet_name']?.toString(),
      petImage: normalizePatientImageUrl(json['pet_image']?.toString()),
      jenisHewan: json['jenis_hewan']?.toString(),
      layanan: json['layanan']?.toString(),
      kategoriLayanan: json['kategori_layanan']?.toString(),
      bb: json['bb']?.toString(),
      suhu: json['suhu']?.toString(),
      diagnosa: json['diagnosa']?.toString(),
      tindakan: json['tindakan']?.toString(),
      catatan: json['catatan']?.toString(),
      dokter: json['dokter']?.toString(),
      nota: json['nota']?.toString(),
      statusPembayaran: json['status_pembayaran']?.toString() ?? '-',
    );
  }
}
