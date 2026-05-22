// lib/screens/kepala/monitoring_bayi_screen.dart
// View-only untuk kepala puskesmas
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../models/bayi_model.dart';
import 'detail_bayi_kepala_screen.dart';

class MonitoringBayiScreen extends StatefulWidget {
  const MonitoringBayiScreen({super.key});
  @override
  State<MonitoringBayiScreen> createState() => _MonitoringBayiScreenState();
}

class _MonitoringBayiScreenState extends State<MonitoringBayiScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filter = 'Semua';
  final List<String> _filters = [
    'Semua', 'Normal', 'Risiko Stunting', 'Stunting', 'Stunting Berat'
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<BayiModel> get _filtered {
    final data = BayiService().dataBayi;
    return data.where((b) {
      final matchSearch = _search.isEmpty ||
          b.namaBayi.toLowerCase().contains(_search.toLowerCase()) ||
          b.namaIbu.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'Semua' ||
          b.statusStunting.toLowerCase() == _filter.toLowerCase();
      return matchSearch && matchFilter;
    }).toList();
  }

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('berat')) return const Color(0xFFE53935);
    if (status.toLowerCase() == 'stunting') return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
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
            Text('Monitoring Bayi', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.blueDark)),
            Text('${BayiService().totalBayi} bayi terdaftar',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.blueDark.withOpacity(0.7))),
          ]),
        ]),
      ),
      body: Column(children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded,
                    color: AppColors.textLight, size: 20),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari nama bayi atau ibu...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: AppColors.textLight),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                )),
                if (_search.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _search = '');
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textLight, size: 18),
                  ),
              ]),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _filters.map((f) {
                final active = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.blueDark : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active
                              ? AppColors.blueDark : AppColors.cardBorder),
                    ),
                    child: Text(f, style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? Colors.white : AppColors.textMedium)),
                  ),
                );
              }).toList()),
            ),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    BayiService().totalBayi == 0
                        ? 'Belum ada data bayi'
                        : 'Tidak ditemukan',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final bayi = list[i];
                    final isLaki =
                        bayi.jenisKelamin.toLowerCase().contains('laki');
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              DetailBayiKepalaScreen(bayi: bayi))),
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
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: isLaki ? AppColors.blue : AppColors.pink,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              isLaki ? Icons.boy_rounded : Icons.girl_rounded,
                              color: isLaki
                                  ? AppColors.blueDark : AppColors.pinkDark,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(bayi.namaBayi, style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text('Ibu: ${bayi.namaIbu}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: AppColors.textMedium)),
                            Text('${bayi.umurBulan} bulan · BB ${bayi.beratBadan} kg · TB ${bayi.tinggiBadan} cm',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: AppColors.textMedium)),
                          ])),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(bayi.statusStunting)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(bayi.statusStunting,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w600,
                                      color: _statusColor(bayi.statusStunting))),
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
        ),
      ]),
    );
  }
}
