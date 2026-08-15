class PetHistory {
  const PetHistory({
    required this.id,
    required this.tanggal,
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
