// lib/screens/kepala/detail_bayi_kepala_screen.dart
// View-only untuk kepala puskesmas (tidak ada tombol edit/tambah)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/bayi_model.dart';

class DetailBayiKepalaScreen extends StatelessWidget {
  final BayiModel bayi;
  const DetailBayiKepalaScreen({super.key, required this.bayi});

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('berat')) return const Color(0xFFE53935);
    if (status.toLowerCase() == 'stunting') return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    if (status.toLowerCase().contains('pendek')) return Colors.orange;
    return AppColors.success;
  }

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
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text('Detail Bayi', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.blueDark)),
            Text(bayi.namaBayi, style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.blueDark.withOpacity(0.7))),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Header bayi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? AppColors.blue : AppColors.pink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? Icons.boy_rounded : Icons.girl_rounded,
                  color: bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? AppColors.blueDark : AppColors.pinkDark,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bayi.namaBayi, style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('${bayi.umurBulan} bulan · ${bayi.jenisKelamin}',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(bayi.statusStunting).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor(bayi.statusStunting).withOpacity(0.4)),
                  ),
                  child: Text(bayi.statusStunting, style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _statusColor(bayi.statusStunting))),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 14),

          // Data pengukuran
          _infoCard('Data Pengukuran', [
            _infoRow('Nama Bayi', bayi.namaBayi),
            _infoRow('Umur Bayi', '${bayi.umurBulan} bulan'),
            _infoRow('Berat Badan', '${bayi.beratBadan} kg'),
            _infoRow('Tinggi Badan', '${bayi.tinggiBadan} cm'),
            _infoRow('Jenis Kelamin', bayi.jenisKelamin),
            _infoRow('Nama Ibu', bayi.namaIbu),
            _infoRow('Tanggal Pemeriksaan', bayi.tanggalPemeriksaan),
          ]),
          const SizedBox(height: 14),

          // Identitas ibu
          _infoCard('Identitas Ibu', [
            _infoRow('Nama Ibu', bayi.namaIbu),
            _infoRow('Umur Ibu', bayi.umurIbu),
            _infoRow('Pendidikan', bayi.pendidikanIbu),
            _infoRow('Pekerjaan', bayi.pekerjaanIbu),
            _infoRow('Jumlah Anak', '${bayi.jumlahAnak} anak'),
          ]),
          const SizedBox(height: 14),

          // Status
          Row(children: [
            Expanded(child: _statusCard('Status Gizi', bayi.statusGizi,
                Icons.monitor_weight_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statusCard('Status Stunting', bayi.statusStunting,
                Icons.health_and_safety_rounded)),
          ]),
          const SizedBox(height: 14),

          // Riwayat
          if (bayi.riwayatPemeriksaan.isNotEmpty)
            _riwayatCard(),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 10),
      ...rows,
    ]),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(flex: 2, child: Text(label, style: GoogleFonts.poppins(
          fontSize: 12, color: AppColors.textMedium))),
      Expanded(flex: 3, child: Text(value, style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textDark))),
    ]),
  );

  Widget _statusCard(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _statusColor(value).withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _statusColor(value).withOpacity(0.3)),
    ),
    child: Column(children: [
      Icon(icon, color: _statusColor(value), size: 24),
      const SizedBox(height: 8),
      Text(label, style: GoogleFonts.poppins(
          fontSize: 11, color: AppColors.textMedium)),
      const SizedBox(height: 4),
      Text(value, textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: _statusColor(value))),
    ]),
  );

  Widget _riwayatCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Riwayat Pemeriksaan', style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 10),
      ...bayi.riwayatPemeriksaan.reversed.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['tanggal'] ?? '-', style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
            Text('BB: ${r['beratBadan']} kg · TB: ${r['tinggiBadan']} cm',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMedium)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(r['statusStunting'] ?? '').withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(r['statusStunting'] ?? '-', style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: _statusColor(r['statusStunting'] ?? ''))),
          ),
        ]),
      )),
    ]),
  );
}
