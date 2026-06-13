import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class TentangKamiScreen extends StatelessWidget {
  final bool isKader;

  const TentangKamiScreen({super.key, required this.isKader});

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
                Text('Tentang Kami',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryColor)),
                Text('Informasi Aplikasi',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: primaryColor.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AA-PoDiTa',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Posyandu Digital Terpadu\nVersi 1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Aplikasi AA-PoDiTa dikembangkan untuk memfasilitasi pencatatan dan pemantauan status gizi anak secara digital.\n\nFokus utama kami adalah memberikan alat yang praktis bagi kader Posyandu dan tenaga kesehatan untuk bersama-sama mencegah stunting di Indonesia.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Didukung Oleh:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInstitutionLogo(
                    'assets/images/logo_dppm.png', Icons.account_balance),
                const SizedBox(width: 16),
                _buildInstitutionLogo(
                    'assets/images/logo_ubp.png', Icons.school),
                const SizedBox(width: 16),
                _buildInstitutionLogo(
                    'assets/images/logo_usk.png', Icons.school_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'DPPM Kemdiktisaintek RI\nUniversitas Bumi Persada · Universitas Syiah Kuala',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionLogo(String assetPath, IconData fallbackIcon) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Image.asset(
        assetPath,
        errorBuilder: (context, error, stackTrace) =>
            Icon(fallbackIcon, color: AppColors.textLight, size: 30),
      ),
    );
  }
}
