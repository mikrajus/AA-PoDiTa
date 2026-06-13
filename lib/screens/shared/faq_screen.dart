import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class FAQScreen extends StatelessWidget {
  final bool isKader;

  const FAQScreen({super.key, required this.isKader});

  @override
  Widget build(BuildContext context) {
    final headerColor =
        isKader ? AppColors.kaderHeader : AppColors.kepalaHeader;
    final primaryColor = isKader ? AppColors.pinkDark : AppColors.blueDark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: primaryColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tanya Jawab',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryColor)),
                Text('Bantuan Seputar Aplikasi',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: primaryColor.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFAQItem(
            context,
            primaryColor,
            'Apa itu AA-PoDiTa?',
            'AA-PoDiTa (Posyandu Digital Terpadu) adalah aplikasi yang dibuat untuk membantu tugas kader Posyandu dan tenaga kesehatan. Aplikasi ini memudahkan pencatatan, pemantauan, dan melihat perkembangan gizi balita lewat HP untuk mencegah stunting.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            context,
            primaryColor,
            'Bagaimana cara menambah data bayi baru?',
            'Pada halaman Beranda, silakan pilih menu "Tambah Bayi" di bagian bawah layar. Setelah itu, lengkapi isian data seperti nama bayi, tanggal lahir, dan nama orang tua sesuai dengan yang diminta.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            context,
            primaryColor,
            'Bagaimana status stunting anak ditentukan?',
            'Status stunting dihitung langsung oleh aplikasi berdasarkan perbandingan tinggi badan dan umur anak, sesuai dengan standar dari WHO. Pastikan angka umur dan tinggi badan diisi dengan benar agar hasilnya tepat.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            context,
            primaryColor,
            'Apakah data pemeriksaan dapat diubah setelah disimpan?',
            'Saat ini, aplikasi menyimpan riwayat secara tetap agar grafik pertumbuhan anak tidak berantakan. Jika ada salah ketik atau salah isi, Ibu/Bapak disarankan untuk mencatat ulang pemeriksaan di hari yang sama dengan angka yang benar, dan tambahkan catatan penjelasan.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            context,
            primaryColor,
            'Bagaimana dengan keamanan data di dalam aplikasi?',
            'Seluruh data yang dimasukkan akan disimpan secara aman dan rahasia. Data anak-anak hanya bisa dilihat oleh kader dan tenaga kesehatan yang memang terdaftar di posyandu atau puskesmas masing-masing.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, Color primaryColor,
      String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryColor,
          collapsedIconColor: AppColors.textMedium,
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
