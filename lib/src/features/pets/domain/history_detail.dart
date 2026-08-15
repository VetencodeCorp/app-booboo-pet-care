import 'pet.dart';

class HistoryDetail {
  const HistoryDetail({
    required this.id,
    required this.tanggal,
    required this.pet,
    required this.layananName,
    required this.kategori,
    required this.bb,
    required this.suhu,
    required this.diagnosa,
    required this.tindakan,
    required this.catatan,
    required this.dokter,
    required this.nota,
    required this.status,
    required this.jumlah,
  });

  final int id;
  final String? tanggal;
  final Pet pet;
  final String? layananName;
  final String? kategori;
  final String? bb;
  final String? suhu;
  final String? diagnosa;
  final String? tindakan;
  final String? catatan;
  final String? dokter;
  final String? nota;
  final String status;
  final int jumlah;

  factory HistoryDetail.fromJson(Map<String, dynamic> json) {
    final ringkasan = json['ringkasan'] as Map<String, dynamic>? ?? {};
    final layanan = json['layanan'] as Map<String, dynamic>? ?? {};
    final tagihan = json['tagihan'] as Map<String, dynamic>? ?? {};
    return HistoryDetail(
      id: (json['id'] as num).toInt(),
      tanggal: json['tanggal']?.toString(),
      pet: Pet.fromJson(json['pet'] as Map<String, dynamic>),
      layananName: layanan['name']?.toString(),
      kategori: layanan['kategori']?.toString(),
      bb: ringkasan['bb']?.toString(),
      suhu: ringkasan['suhu']?.toString(),
      diagnosa: ringkasan['diagnosa']?.toString(),
      tindakan: ringkasan['tindakan']?.toString(),
      catatan: ringkasan['catatan']?.toString(),
      dokter: ringkasan['dokter']?.toString(),
      nota: tagihan['nota']?.toString(),
      status: tagihan['status']?.toString() ?? '-',
      jumlah: (tagihan['jumlah'] as num?)?.toInt() ?? 0,
    );
  }
}
