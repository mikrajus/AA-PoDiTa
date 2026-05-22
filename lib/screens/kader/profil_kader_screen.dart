// lib/screens/kader/profil_kader_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class ProfilKaderScreen extends StatelessWidget {
  final String namaKader;
  final String namaPosyandu;
  final String namaPuskesmas;

  const ProfilKaderScreen({
    super.key,
    this.namaKader = '',
    this.namaPosyandu = '',
    this.namaPuskesmas = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.kaderHeader,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.pinkDark, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text('Profil', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.pinkDark)),
            Text('Informasi akun', style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.pinkDark.withOpacity(0.7))),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 10),
          // Avatar
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.pink,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.pinkDark, size: 50),
          ),
          const SizedBox(height: 14),
          Text(
            namaKader.isEmpty ? 'Kader Posyandu' : namaKader,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pinkPale,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.pink),
            ),
            child: Text('Kader Posyandu',
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.pinkDark)),
          ),
          const SizedBox(height: 28),

          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              _InfoRow(label: 'Nama Lengkap',
                  value: namaKader.isEmpty ? '-' : namaKader,
                  icon: Icons.person_outline_rounded),
              _divider(),
              _InfoRow(label: 'Posyandu',
                  value: namaPosyandu.isEmpty ? '-' : namaPosyandu,
                  icon: Icons.home_work_outlined),
              _divider(),
              _InfoRow(label: 'Puskesmas',
                  value: namaPuskesmas.isEmpty ? '-' : namaPuskesmas,
                  icon: Icons.local_hospital_outlined),
              _divider(),
              _InfoRow(label: 'Role',
                  value: 'Kader Posyandu',
                  icon: Icons.badge_outlined),
            ]),
          ),
          const SizedBox(height: 20),

          // Tombol keluar
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
                          style: GoogleFonts.poppins(color: AppColors.textMedium)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      child: Text('Keluar',
                          style: GoogleFonts.poppins(
                              color: AppColors.pinkDark,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                color: AppColors.pinkPale,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.pink),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout_rounded,
                    color: AppColors.pinkDark, size: 20),
                const SizedBox(width: 8),
                Text('Keluar dari Akun',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.pinkDark)),
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
  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.pinkPale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColors.pinkDark),
    ),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(
          fontSize: 11, color: AppColors.textLight)),
      Text(value, style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    ])),
  ]);
}
