// lib/screens/kader/data_bayi_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../services/auth_service.dart';
import '../../models/bayi_model.dart';
import 'detail_bayi_screen.dart';
import 'tambah_bayi_screen.dart';

class DataBayiScreen extends StatefulWidget {
  const DataBayiScreen({super.key});
  @override
  State<DataBayiScreen> createState() => _DataBayiScreenState();
}

class _DataBayiScreenState extends State<DataBayiScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Normal',
    'Risiko Stunting',
    'Pendek',
    'Sangat Pendek'
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BayiModel> get _filtered {
    final currentKader = AuthService.currentUsername;
    final data = BayiService().getBayiByKader(currentKader);
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
    if (status.toLowerCase().contains('sangat')) return const Color(0xFFE53935);
    if (status.toLowerCase().contains('pendek')) return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    return AppColors.success;
  }

  void _hapusBayi(BayiModel bayi) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Data Bayi?',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFE53935), size: 20),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                'Data ${bayi.namaBayi} dan seluruh riwayat pemeriksaannya akan dihapus permanen.',
                style: GoogleFonts.poppins(
                    fontSize: 12, height: 1.4, color: const Color(0xFFE53935)),
              )),
            ]),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: AppColors.textMedium))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Hapus',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFE53935),
                      fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (konfirmasi == true) {
      BayiService().hapusBayi(bayi.id);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data ${bayi.namaBayi} dihapus',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.textMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentKader = AuthService.currentUsername;
    final list = _filtered;
    final totalBayi = BayiService().getTotalBayiByKader(currentKader);
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
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Data Bayi',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pinkDark)),
                Text('$totalBayi bayi terdaftar',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.pinkDark.withOpacity(0.7))),
              ]),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TambahBayiScreen()));
              if (result == true) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.pinkDark, size: 22),
            ),
          ),
        ]),
      ),
      body: AnimatedBuilder(
        animation: BayiService(),
        builder: (context, _) {
          final currentKader = AuthService.currentUsername;
          final list = _filtered;
          final totalBayi = BayiService().getTotalBayiByKader(currentKader);
          return Column(children: [
            // Search & filter
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
                    Expanded(
                        child: TextField(
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
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
                  child: Row(
                      children: _filters.map((f) {
                    final active = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.pinkDark
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active
                                  ? AppColors.pinkDark
                                  : AppColors.cardBorder),
                        ),
                        child: Text(f,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w400,
                                color: active
                                    ? Colors.white
                                    : AppColors.textMedium)),
                      ),
                    );
                  }).toList()),
                ),
              ]),
            ),

            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => BayiService().refreshData(),
                color: AppColors.pinkDark,
                child: list.isEmpty
                    ? Stack(
                        children: [
                          ListView(), // Needed for RefreshIndicator to work on empty state
                          Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                const Icon(Icons.search_off_rounded,
                                    size: 48, color: AppColors.textLight),
                                const SizedBox(height: 12),
                                Text(
                                    totalBayi == 0
                                        ? 'Belum ada data bayi'
                                        : 'Tidak ditemukan',
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text(
                                    totalBayi == 0
                                        ? 'Tekan + untuk menambah data bayi'
                                        : 'Coba kata kunci lain',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textMedium)),
                              ])),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final bayi = list[i];
                          final isLaki =
                              bayi.jenisKelamin.toLowerCase().contains('laki');
                          return Dismissible(
                            key: Key(bayi.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_rounded,
                                  color: Color(0xFFE53935), size: 24),
                            ),
                            confirmDismiss: (_) async {
                              _hapusBayi(bayi);
                              return false; // kita handle manual
                            },
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            DetailBayiScreen(bayi: bayi)));
                                if (result == true) setState(() {});
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3))
                                  ],
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: isLaki
                                          ? AppColors.blue
                                          : AppColors.pink,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      isLaki
                                          ? Icons.boy_rounded
                                          : Icons.girl_rounded,
                                      color: isLaki
                                          ? AppColors.blueDark
                                          : AppColors.pinkDark,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(bayi.namaBayi,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark)),
                                        const SizedBox(height: 2),
                                        Text('Ibu: ${bayi.namaIbu}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppColors.textMedium)),
                                        Text(
                                            '${bayi.umurBulan} bln · ${bayi.beratBadan} kg · ${bayi.tinggiBadan} cm',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppColors.textMedium)),
                                      ])),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                                    bayi.statusStunting)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(bayi.statusStunting,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: _statusColor(
                                                      bayi.statusStunting))),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () => _hapusBayi(bayi),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: AppColors.textLight),
                                          ),
                                        ),
                                      ]),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
