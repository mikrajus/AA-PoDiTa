// lib/screens/kader/riwayat_kader_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../models/bayi_model.dart';
import 'detail_bayi_screen.dart';

class RiwayatKaderScreen extends StatefulWidget {
  const RiwayatKaderScreen({super.key});
  @override
  State<RiwayatKaderScreen> createState() => _RiwayatKaderScreenState();
}

class _RiwayatKaderScreenState extends State<RiwayatKaderScreen> {
  // Kumpulkan semua riwayat pemeriksaan dari semua bayi
  List<Map<String, dynamic>> get _semuaRiwayat {
    final List<Map<String, dynamic>> hasil = [];
    for (final bayi in BayiService().dataBayi) {
      // Pemeriksaan terkini
      hasil.add({
        'bayi': bayi,
        'tanggal': bayi.tanggalPemeriksaan,
        'bb': bayi.beratBadan,
        'tb': bayi.tinggiBadan,
        'statusGizi': bayi.statusGizi,
        'statusStunting': bayi.statusStunting,
        'isTerkini': true,
      });
      // Riwayat lama
      for (final r in bayi.riwayatPemeriksaan.reversed) {
        hasil.add({
          'bayi': bayi,
          'tanggal': r['tanggal'] ?? '-',
          'bb': r['beratBadan'],
          'tb': r['tinggiBadan'],
          'statusGizi': r['statusGizi'] ?? '-',
          'statusStunting': r['statusStunting'] ?? '-',
          'isTerkini': false,
        });
      }
    }
    // Sort by tanggal terbaru
    hasil.sort((a, b) => (b['tanggal'] as String)
        .compareTo(a['tanggal'] as String));
    return hasil;
  }

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('berat')) return const Color(0xFFE53935);
    if (status.toLowerCase() == 'stunting') return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    if (status.toLowerCase().contains('pendek')) return Colors.orange;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = _semuaRiwayat;
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
            Text('Riwayat', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.pinkDark)),
            Text('Semua aktivitas pemeriksaan',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.pinkDark.withOpacity(0.7))),
          ]),
        ]),
      ),
      body: riwayat.isEmpty
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pinkPale,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.history_rounded,
                    size: 56, color: AppColors.pinkDark),
              ),
              const SizedBox(height: 20),
              Text('Belum ada riwayat', style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Riwayat pemeriksaan akan tampil di sini',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textMedium)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: riwayat.length,
              itemBuilder: (_, i) {
                final item = riwayat[i];
                final bayi = item['bayi'] as BayiModel;
                final isTerkini = item['isTerkini'] as bool;
                final isLaki = bayi.jenisKelamin.toLowerCase().contains('laki');
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                            DetailBayiScreen(bayi: bayi)));
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isLaki ? AppColors.blue : AppColors.pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isLaki ? Icons.boy_rounded : Icons.girl_rounded,
                          color: isLaki ? AppColors.blueDark : AppColors.pinkDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Text(bayi.namaBayi, style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                          if (isTerkini) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.bluePale,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Terkini',
                                  style: GoogleFonts.poppins(
                                      fontSize: 9, fontWeight: FontWeight.w600,
                                      color: AppColors.blueDark)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 2),
                        Text('BB: ${item['bb']} kg · TB: ${item['tb']} cm',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textMedium)),
                        Text(item['tanggal'],
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textLight)),
                      ])),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(item['statusStunting'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(item['statusStunting'],
                              style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  color: _statusColor(item['statusStunting']))),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: AppColors.textLight),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
