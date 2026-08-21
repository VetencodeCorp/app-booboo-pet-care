import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = [
    _PolicySection(
      title: '1. Informasi yang kami kumpulkan',
      body:
          'Booboo Pet Care dapat mengumpulkan data yang diperlukan untuk menjalankan layanan aplikasi member, seperti nama lengkap, nomor telepon, alamat, data akun, data anabul, dan riwayat perawatan yang tercatat di sistem kami.',
    ),
    _PolicySection(
      title: '2. Data penggunaan aplikasi',
      body:
          'Aplikasi dapat mencatat data teknis seperti jenis perangkat, alamat IP, sistem operasi, waktu akses, halaman yang dibuka, dan data diagnostik lain untuk keamanan, perbaikan bug, dan peningkatan layanan.',
    ),
    _PolicySection(
      title: '3. Cara kami menggunakan data',
      body:
          'Data digunakan untuk mengelola akun member, menampilkan riwayat perawatan, menghubungi pengguna terkait layanan, membantu permintaan bantuan, menjaga keamanan aplikasi, menganalisis penggunaan layanan, dan meningkatkan kualitas produk Booboo Pet Care.',
    ),
    _PolicySection(
      title: '4. Pengiriman informasi dan promo',
      body:
          'Kami dapat mengirim informasi layanan, pengingat, promo, atau pembaruan yang relevan melalui WhatsApp, telepon, SMS, email, notifikasi aplikasi, atau kanal komunikasi lain. Pengguna dapat meminta untuk berhenti menerima komunikasi promosi kapan saja.',
    ),
    _PolicySection(
      title: '5. Berbagi data dengan pihak lain',
      body:
          'Kami tidak menjual data pribadi pengguna. Data dapat dibagikan kepada penyedia layanan yang membantu operasional aplikasi, kebutuhan hukum, keamanan, proses bisnis, atau pihak lain jika pengguna memberikan persetujuan.',
    ),
    _PolicySection(
      title: '6. Penyimpanan data',
      body:
          'Data pribadi disimpan selama masih diperlukan untuk menyediakan layanan, memenuhi kewajiban hukum, menyelesaikan sengketa, menjaga keamanan, atau kebutuhan administrasi. Data akun dapat disimpan hingga 24 bulan setelah akun ditutup jika masih diperlukan.',
    ),
    _PolicySection(
      title: '7. Penghapusan dan perubahan data',
      body:
          'Pengguna dapat memperbarui sebagian data melalui aplikasi. Untuk meminta akses, koreksi, atau penghapusan data pribadi, pengguna dapat menghubungi Booboo Pet Care. Beberapa data mungkin tetap disimpan jika diwajibkan oleh hukum atau alasan operasional yang sah.',
    ),
    _PolicySection(
      title: '8. Keamanan data',
      body:
          'Kami berupaya melindungi data pribadi dengan langkah keamanan yang wajar. Namun, tidak ada metode pengiriman data melalui internet atau penyimpanan elektronik yang sepenuhnya bebas risiko.',
    ),
    _PolicySection(
      title: '9. Privasi anak',
      body:
          'Layanan ini tidak ditujukan untuk anak di bawah usia 16 tahun. Jika kami mengetahui ada data anak yang dikirim tanpa izin orang tua atau wali, kami akan mengambil langkah yang wajar untuk menghapus data tersebut.',
    ),
    _PolicySection(
      title: '10. Tautan pihak ketiga',
      body:
          'Aplikasi dapat memuat tautan ke situs atau layanan pihak ketiga. Kebijakan privasi pihak ketiga berada di luar kendali Booboo Pet Care, sehingga pengguna disarankan membaca kebijakan masing-masing layanan.',
    ),
    _PolicySection(
      title: '11. Perubahan kebijakan',
      body:
          'Kebijakan Privasi dapat diperbarui dari waktu ke waktu. Perubahan berlaku sejak dipublikasikan di aplikasi atau halaman kebijakan resmi Booboo Pet Care.',
    ),
    _PolicySection(
      title: '12. Kontak',
      body:
          'Jika ada pertanyaan tentang Kebijakan Privasi ini, hubungi Booboo Pet Care melalui WhatsApp di 0812-2479-2834.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), AppColors.lavender],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.softPurple,
                  child: Icon(Icons.shield_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privasi Member',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Terakhir diperbarui: 17 Agustus 2026',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kebijakan Privasi ini menjelaskan cara Booboo Pet Care mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi pengguna saat menggunakan aplikasi member Booboo Pet Care.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          for (final section in _sections) ...[
            _PolicyCard(section: section),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          const Text(
            'Alamat Booboo Pet Care: Jl. Arwinda Asri, Sukataris, Kec. Karangtengah, Kabupaten Cianjur, Jawa Barat 43281, Indonesia.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.section});

  final _PolicySection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;
}
