// lib/screens/kepala/profil_kepala_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../shared/faq_screen.dart';
import '../shared/tentang_kami_screen.dart';

class ProfilKepalaScreen extends StatelessWidget {
  final String namaKepala;
  final String namaPuskesmas;
  final String nik;
  final String nomorHp;
  final bool showBackButton;

  const ProfilKepalaScreen({
    super.key,
    this.namaKepala = '',
    this.namaPuskesmas = '',
    this.nik = '',
    this.nomorHp = '',
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.kepalaHeader,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.blueDark, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Profil',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blueDark)),
                Text('Informasi akun',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.blueDark.withOpacity(0.7))),
              ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.blueDark, size: 50),
          ),
          const SizedBox(height: 14),
          Text(
            namaKepala.isEmpty ? 'Tenaga Kesehatan' : namaKepala,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blue),
            ),
            child: Text('Tenaga Kesehatan',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDark)),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              _InfoRow(
                  label: 'Nama Lengkap',
                  value: namaKepala.isEmpty ? '-' : namaKepala,
                  icon: Icons.person_outline_rounded,
                  color: AppColors.blueDark,
                  bgColor: AppColors.bluePale),
              _divider(),
              _InfoRow(
                  label: 'NIK',
                  value: nik.isEmpty ? '-' : nik,
                  icon: Icons.badge_outlined,
                  color: AppColors.blueDark,
                  bgColor: AppColors.bluePale),
              _divider(),
              _InfoRow(
                  label: 'Nomor HP',
                  value: nomorHp.isEmpty ? '-' : nomorHp,
                  icon: Icons.phone_outlined,
                  color: AppColors.blueDark,
                  bgColor: AppColors.bluePale),
              _divider(),
              const _InfoRow(
                  label: 'Role',
                  value: 'Tenaga Kesehatan',
                  icon: Icons.badge_outlined,
                  color: AppColors.blueDark,
                  bgColor: AppColors.bluePale),
            ]),
          ),
          const SizedBox(height: 20),

          // Menu Bantuan & Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              _ActionMenu(
                icon: Icons.help_outline_rounded,
                label: 'Tanya Jawab (FAQ)',
                color: AppColors.blueDark,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FAQScreen(isKader: false))),
              ),
              _divider(),
              _ActionMenu(
                icon: Icons.info_outline_rounded,
                label: 'Tentang Kami',
                color: AppColors.blueDark,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const TentangKamiScreen(isKader: false))),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text('Keluar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  content: Text('Yakin ingin keluar dari akun?',
                      style: GoogleFonts.poppins(fontSize: 14)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal',
                          style:
                              GoogleFonts.poppins(color: AppColors.textMedium)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      child: Text('Keluar',
                          style: GoogleFonts.poppins(
                              color: AppColors.blueDark,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.blue),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout_rounded,
                    color: AppColors.blueDark, size: 20),
                const SizedBox(width: 8),
                Text('Keluar dari Akun',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueDark)),
              ]),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1, color: AppColors.divider),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bgColor;
  const _InfoRow(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.bgColor});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textLight)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ])),
      ]);
}

class _ActionMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionMenu(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textLight, size: 14),
          ],
        ),
      ),
    );
  }
}
