// lib/screens/kepala/riwayat_kepala_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../services/export_service.dart';
import '../../models/bayi_model.dart';
import 'detail_bayi_kepala_screen.dart';

class RiwayatKepalaScreen extends StatefulWidget {
  final bool showBackButton;
  const RiwayatKepalaScreen({super.key, this.showBackButton = true});

  @override
  State<RiwayatKepalaScreen> createState() => _RiwayatKepalaScreenState();
}

class _RiwayatKepalaScreenState extends State<RiwayatKepalaScreen> {
  String _searchQuery = '';

  String _filterBulan = 'Semua Bulan';
  String _filterTahun = 'Semua Tahun';
  String _filterDesa = 'Semua Desa';
  String _filterJk = 'Semua JK';

  final _listBulan = [
    'Semua Bulan',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  final _listTahun = [
    'Semua Tahun',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030'
  ];
  final _listDesa = ['Semua Desa', 'Blang Teue', 'Lain-lain'];
  final _listJk = ['Semua JK', 'Laki-laki', 'Perempuan'];

  final ScrollController _filterScrollCtrl = ScrollController();

  @override
  void dispose() {
    _filterScrollCtrl.dispose();
    super.dispose();
  }

  List<BayiModel> get _semuaRiwayat {
    var listBayi = BayiService()
        .dataBayi
        .where((b) =>
            b.tanggalPemeriksaan.isNotEmpty && b.tanggalPemeriksaan != '-')
        .toList();

    // Sort by tanggal terbaru
    listBayi
        .sort((a, b) => b.tanggalPemeriksaan.compareTo(a.tanggalPemeriksaan));

    // Filter
    listBayi = listBayi.where((b) {
      bool matchWaktu = true;
      if (_filterBulan != 'Semua Bulan' || _filterTahun != 'Semua Tahun') {
        bool anyMatch = false;

        bool cekTanggal(String tglStr) {
          final parts = tglStr.split('-');
          if (parts.length == 3) {
            final y = parts[0];
            final m = int.tryParse(parts[1]) ?? 0;

            bool okBulan = _filterBulan == 'Semua Bulan' ||
                (m > 0 && m <= 12 && _listBulan[m] == _filterBulan);
            bool okTahun = _filterTahun == 'Semua Tahun' || y == _filterTahun;

            return okBulan && okTahun;
          }
          return false;
        }

        // Cek tanggal saat ini
        if (cekTanggal(b.tanggalPemeriksaan)) {
          anyMatch = true;
        }

        // Cek riwayat
        if (!anyMatch) {
          for (var riwayat in b.riwayatPemeriksaan) {
            final tgl = riwayat['tanggal'] ?? riwayat['tanggalPemeriksaan'];
            if (tgl != null && tgl != '-') {
              if (cekTanggal(tgl.toString())) {
                anyMatch = true;
                break;
              }
            }
          }
        }
        matchWaktu = anyMatch;
      }

      bool matchDesa = true;
      if (_filterDesa != 'Semua Desa') {
        matchDesa = b.desa == _filterDesa;
      }

      bool matchJk = true;
      if (_filterJk != 'Semua JK') {
        matchJk = b.jenisKelamin == _filterJk;
      }

      return matchWaktu && matchDesa && matchJk;
    }).toList();

    if (_searchQuery.isEmpty) return listBayi;

    return listBayi.where((bayi) {
      final query = _searchQuery.toLowerCase();
      return bayi.namaBayi.toLowerCase().contains(query) ||
          bayi.namaIbu.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = _semuaRiwayat;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.kepalaHeader,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(children: [
          if (widget.showBackButton) ...[
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
                Text('Riwayat',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blueDark)),
                Text('Semua aktivitas pemeriksaan',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.blueDark.withOpacity(0.7))),
              ]),
        ]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase();
                      final allNames = BayiService()
                          .dataBayi
                          .expand((b) => [b.namaBayi, b.namaIbu])
                          .toSet()
                          .where((name) => name.toLowerCase().contains(query));
                      return allNames;
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _searchQuery = selection;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari nama bayi atau ibu...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textLight),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.blue),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    controller.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Icon(Icons.clear_rounded,
                                      color: AppColors.textMedium),
                                )
                              : null,
                        ),
                        onChanged: (v) {
                          setState(() {
                            _searchQuery = v;
                          });
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            width: MediaQuery.of(context).size.width -
                                32 -
                                64, // Kurangi lebar filter button
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(option,
                                        style:
                                            GoogleFonts.poppins(fontSize: 14)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterPopup,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.tune_rounded, color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    if (riwayat.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Tidak ada data untuk diexport.')));
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mengekspor data...')));
                    try {
                      await ExportService.exportRiwayatToExcel(
                          riwayat, 'Rekap_Riwayat_Posyandu');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Data berhasil diexport!')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal export: $e')));
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_view_rounded,
                        color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: riwayat.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.bluePale,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.history_rounded,
                              size: 56, color: AppColors.blueDark),
                        ),
                        const SizedBox(height: 20),
                        Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada riwayat'
                                : 'Tidak ditemukan',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text(
                            _searchQuery.isEmpty
                                ? 'Riwayat pemeriksaan akan tampil di sini'
                                : 'Coba masukkan kata kunci pencarian lain',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: AppColors.textMedium)),
                      ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: riwayat.length,
                    itemBuilder: (_, i) {
                      final bayi = riwayat[i];
                      final isLaki =
                          bayi.jenisKelamin.toLowerCase().contains('laki');
                      final totalPemeriksaan =
                          1 + bayi.riwayatPemeriksaan.length;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailBayiKepalaScreen(bayi: bayi))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isLaki ? AppColors.blue : AppColors.pink,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isLaki ? Icons.boy_rounded : Icons.girl_rounded,
                                color: isLaki
                                    ? AppColors.blueDark
                                    : AppColors.pinkDark,
                                size: 24,
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
                                  Text('$totalPemeriksaan Total Pemeriksaan',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMedium)),
                                  Text('Ibu: ${bayi.namaIbu}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppColors.textLight)),
                                ])),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.pinkPale,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Terakhir',
                                        style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.blueDark)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(bayi.tanggalPemeriksaan,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark)),
                                ]),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMedium),
          style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showFilterPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Filter Riwayat',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bulan',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.textMedium)),
                          const SizedBox(height: 6),
                          _buildDropdown(_filterBulan, _listBulan, (v) {
                            setModalState(() => _filterBulan = v!);
                            setState(() {});
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tahun',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.textMedium)),
                          const SizedBox(height: 6),
                          _buildDropdown(_filterTahun, _listTahun, (v) {
                            setModalState(() => _filterTahun = v!);
                            setState(() {});
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Desa',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 6),
                _buildDropdown(_filterDesa, _listDesa, (v) {
                  setModalState(() => _filterDesa = v!);
                  setState(() {});
                }),
                const SizedBox(height: 12),
                Text('Jenis Kelamin',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 6),
                _buildDropdown(_filterJk, _listJk, (v) {
                  setModalState(() => _filterJk = v!);
                  setState(() {});
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Terapkan Filter',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
