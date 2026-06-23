// lib/screens/kader/detail_bayi_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/bayi_model.dart';
import '../../services/bayi_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'update_pemeriksaan_screen.dart';
import 'tambah_bayi_screen.dart';

class DetailBayiScreen extends StatefulWidget {
  final BayiModel bayi;
  const DetailBayiScreen({super.key, required this.bayi});
  @override
  State<DetailBayiScreen> createState() => _DetailBayiScreenState();
}

class _DetailBayiScreenState extends State<DetailBayiScreen> {
  late BayiModel _bayi;

  @override
  void initState() {
    super.initState();
    _bayi = widget.bayi;
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('sangat pendek') || s.contains('sangat kurang')) return const Color(0xFFE53935);
    if (s.contains('pendek') || s.contains('kurang') || s.contains('risiko')) return Colors.orange;
    return AppColors.success;
  }

  List<Map<String, dynamic>> get _semuaData {
    final List<Map<String, dynamic>> data = [];
    for (final r in _bayi.riwayatPemeriksaan) {
      data.add({
        'tanggal': r['tanggal'] ?? '-',
        'statusGizi': r['statusGizi'] ?? '-',
        'statusStunting': r['statusStunting'] ?? '-',
        'beratBadan': double.tryParse(r['beratBadan'].toString()) ?? 0.0,
        'tinggiBadan': double.tryParse(r['tinggiBadan'].toString()) ?? 0.0,
        'umurBulan':
            _hitungUmurBulanPadaTanggal(_bayi.tanggalLahir, r['tanggal'] ?? ''),
      });
    }
    data.add({
      'tanggal': _bayi.tanggalPemeriksaan,
      'statusGizi': _bayi.statusGizi,
      'statusStunting': _bayi.statusStunting,
      'beratBadan': _bayi.beratBadan,
      'tinggiBadan': _bayi.tinggiBadan,
      'umurBulan': _bayi.umurBulan,
    });
    data.sort(
        (a, b) => (a['umurBulan'] as int).compareTo(b['umurBulan'] as int));
    return data;
  }

  void _editBayi() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahBayiScreen(bayiToEdit: _bayi),
      ),
    );
    if (result == true) {
      final updated = BayiService().getBayiById(_bayi.id);
      if (updated != null) {
        setState(() {
          _bayi = updated;
        });
      }
    }
  }

  void _hapusBayi() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Bayi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
            'Yakin ingin menghapus data ${_bayi.namaBayi}? Seluruh riwayat pemeriksaan juga akan terhapus.',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              final ok = BayiService().hapusBayi(_bayi.id);
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Data bayi berhasil dihapus.',
                      style: GoogleFonts.poppins(fontSize: 13)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ));
                Navigator.pop(context, true); // return true to refresh list
              }
            },
            child: Text('Hapus',
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double zBBU = BayiService().hitungZScoreBBU(
      _bayi.umurBulan,
      _bayi.beratBadan,
      _bayi.jenisKelamin,
    );
    final double zTBU = BayiService().hitungZScoreTBU(
      _bayi.umurBulan,
      _bayi.tinggiBadan,
      _bayi.jenisKelamin,
    );
    final String zBBUStr = (zBBU >= 0 ? '+' : '') + zBBU.toStringAsFixed(2);
    final String zTBUStr = (zTBU >= 0 ? '+' : '') + zTBU.toStringAsFixed(2);
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
                Text('Detail Bayi',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pinkDark)),
                Text(_bayi.namaBayi,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.pinkDark.withOpacity(0.7))),
              ]),
          const Spacer(),
          GestureDetector(
            onTap: _editBayi,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.pinkDark, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _hapusBayi,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_rounded,
                  color: AppColors.pinkDark, size: 18),
            ),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── Header bayi ────────────────────────────────────────────────
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? AppColors.blue
                      : AppColors.pink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? Icons.boy_rounded
                      : Icons.girl_rounded,
                  color: _bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? AppColors.blueDark
                      : AppColors.pinkDark,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_bayi.namaBayi,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text('${_bayi.umurBulan} bulan · ${_bayi.jenisKelamin}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textMedium)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(_bayi.statusStunting).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusColor(_bayi.statusStunting)
                                .withOpacity(0.4)),
                      ),
                      child: Text(_bayi.statusStunting,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(_bayi.statusStunting))),
                    ),
                  ])),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Identitas & Pengukuran ────────────────────────────────────────────
          _infoCard('Identitas Bayi', [
            _infoRow('Nama Bayi', _bayi.namaBayi),
            _infoRow('Umur Bayi', '${_bayi.umurBulan} bulan'),
            _infoRow('Jenis Kelamin', _bayi.jenisKelamin),
            _infoRow('Anak Ke-', '${_bayi.anakKe}'),
          ]),
          const SizedBox(height: 14),
          _infoCard('Identitas Ibu', [
            _infoRow('Nama Ibu', _bayi.namaIbu),
            _infoRow('No. HP Ibu', _bayi.noHpIbu),
            _infoRow('Desa', _bayi.desa),
            _infoRow('Pendidikan Ibu', _bayi.pendidikanIbu),
            _infoRow('Pekerjaan Ibu', _bayi.pekerjaanIbu),
          ]),
          const SizedBox(height: 14),
          _infoCard('Data Pengukuran Terkini', [
            _infoRow('Tgl Pemeriksaan', _bayi.tanggalPemeriksaan),
            _infoRow('Berat Badan', '${_bayi.beratBadan} kg'),
            _infoRow('Tinggi Badan', '${_bayi.tinggiBadan} cm'),
          ]),
          const SizedBox(height: 14),

          // ── Riwayat pemeriksaan ────────────────────────────────────────
          if (_bayi.riwayatPemeriksaan.isNotEmpty) ...[
            _riwayatCard(),
            const SizedBox(height: 14),
          ],

          // ── Status card ────────────────────────────────────────────────
          Row(children: [
            Expanded(
                child: _statusCard('Status Gizi', _bayi.statusGizi, zBBUStr,
                    Icons.monitor_weight_rounded, () {
              _showStatusDetailDialog(
                title: 'Status Gizi',
                value: _bayi.statusGizi,
                zScore: zBBU,
                icon: Icons.monitor_weight_rounded,
                isBBU: true,
              );
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _statusCard('Status Stunting', _bayi.statusStunting,
                    zTBUStr, Icons.health_and_safety_rounded, () {
              _showStatusDetailDialog(
                title: 'Status Stunting',
                value: _bayi.statusStunting,
                zScore: zTBU,
                icon: Icons.health_and_safety_rounded,
                isBBU: false,
              );
            })),
          ]),
          const SizedBox(height: 14),

          // ── Rekomendasi Kemenkes ───────────────────────────────────────
          _buildRekomendasiSection(),
          const SizedBox(height: 14),

          // ── Grafik Status Gizi ─────────────────────────────────────────
          _buildGrafikCard(
            title: 'Grafik Status Gizi (BB/U)',
            data: _semuaData,
            isBBU: true,
            color: AppColors.blueDark,
            bgColor: AppColors.blue,
          ),
          const SizedBox(height: 14),

          // ── Grafik Status Stunting ─────────────────────────────────────
          _buildGrafikCard(
            title: 'Grafik Status Tinggi Badan (TB/U)',
            data: _semuaData,
            isBBU: false,
            color: AppColors.pinkDark,
            bgColor: AppColors.pink,
          ),
          const SizedBox(height: 14),

          // ── Tombol update ──────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UpdatePemeriksaanScreen(bayi: _bayi)));
              if (result == true) {
                final updated = BayiService().getBayiById(_bayi.id);
                if (updated != null) {
                  setState(() {
                    _bayi = updated;
                  });
                }
              }
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.pinkDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_chart_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Tambah Pemeriksaan',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ]),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  // ── Grafik card ──────────────────────────────────────────────────────────
  Widget _buildGrafikCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required bool isBBU,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.show_chart_rounded, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(height: 14),
        if (data.length < 2)
          Center(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Icon(Icons.show_chart_rounded,
                  size: 36, color: color.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text('Butuh minimal 2 data pemeriksaan',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textLight)),
            ]),
          ))
        else ...[
          // Grafik KMS
          SizedBox(
            height: 250, // Diperbesar untuk menampilkan grafik KMS lebih baik
            child: _buildFlChart(data, isBBU, _bayi.jenisKelamin.toLowerCase().contains('laki'), color),
          ),
          const SizedBox(height: 16),

          // Legend untuk KMS
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendItem('+3/-3 SD', Colors.black45),
              _legendItem('+2/-2 SD', Colors.red.withValues(alpha: 0.6)),
              _legendItem('0 SD (Median)', Colors.green.withValues(alpha: 0.8)),
              _legendItem('Pertumbuhan Bayi', color),
            ],
          ),
          const SizedBox(height: 16),

          // Status terkini
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pinkDark.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _statusColor(isBBU ? data.last['statusGizi'] : data.last['statusStunting']).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline_rounded, size: 18, color: _statusColor(isBBU ? data.last['statusGizi'] : data.last['statusStunting'])),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Terkini', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
                    Text(
                      isBBU ? data.last['statusGizi'] : data.last['statusStunting'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(isBBU ? data.last['statusGizi'] : data.last['statusStunting']),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildFlChart(List<Map<String, dynamic>> data, bool isBBU, bool isMale, Color lineColor) {
    int maxUmur = 24;
    for (var d in data) {
      if ((d['umurBulan'] as int) > maxUmur) maxUmur = d['umurBulan'] as int;
    }
    maxUmur = ((maxUmur + 5) ~/ 6) * 6;
    if (maxUmur < 24) maxUmur = 24;

    double maxY = isBBU ? 20.0 : 110.0;
    double minY = isBBU ? 2.0 : 40.0;

    final lastCurve = BayiService().getZScoreCurve(maxUmur, isMale, isBBU);
    if ((lastCurve['3'] ?? 0) > maxY) maxY = (lastCurve['3'] ?? 0) + 2;
    final firstCurve = BayiService().getZScoreCurve(0, isMale, isBBU);
    if ((firstCurve['-3'] ?? 0) < minY) {
      minY = ((firstCurve['-3'] ?? 0) - 2).clamp(0.0, double.infinity);
    }

    List<FlSpot> spot3 = [];
    List<FlSpot> spot2 = [];
    List<FlSpot> spot0 = [];
    List<FlSpot> spotMin2 = [];
    List<FlSpot> spotMin3 = [];
    
    for (int i = 0; i <= maxUmur; i++) {
      final curve = BayiService().getZScoreCurve(i, isMale, isBBU);
      spot3.add(FlSpot(i.toDouble(), curve['3'] ?? 0));
      spot2.add(FlSpot(i.toDouble(), curve['2'] ?? 0));
      spot0.add(FlSpot(i.toDouble(), curve['0'] ?? 0));
      spotMin2.add(FlSpot(i.toDouble(), curve['-2'] ?? 0));
      spotMin3.add(FlSpot(i.toDouble(), curve['-3'] ?? 0));
    }

    List<FlSpot> babySpots = [];
    for (var d in data) {
      final double umur = (d['umurBulan'] as int).toDouble();
      final double val = isBBU ? d['beratBadan'] as double : d['tinggiBadan'] as double;
      babySpots.add(FlSpot(umur, val));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxUmur.toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: isBBU ? 2 : 10,
          verticalInterval: maxUmur <= 24 ? 3 : 6,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: maxUmur <= 24 ? 3.0 : 6.0,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMedium));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: isBBU ? 2.0 : 10.0,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMedium));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: AppColors.cardBorder)),
        lineBarsData: [
          LineChartBarData(spots: spot3, isCurved: true, color: Colors.black26, barWidth: 1.5, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: spot2, isCurved: true, color: Colors.red.withValues(alpha: 0.6), barWidth: 1.5, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: spot0, isCurved: true, color: Colors.green.withValues(alpha: 0.8), barWidth: 2, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: spotMin2, isCurved: true, color: Colors.red.withValues(alpha: 0.6), barWidth: 1.5, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: spotMin3, isCurved: true, color: Colors.black26, barWidth: 1.5, dotData: const FlDotData(show: false)),
          LineChartBarData(
            spots: babySpots,
            isCurved: false,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(radius: 4, color: lineColor, strokeWidth: 2, strokeColor: Colors.white);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 2, color: color),
        const SizedBox(width: 4),
        Text(label,
            style:
                GoogleFonts.poppins(fontSize: 10, color: AppColors.textMedium)),
      ],
    );
  }

  void _showStatusDetailDialog({
    required String title,
    required String value,
    required double zScore,
    required IconData icon,
    required bool isBBU,
  }) {
    final zScoreStr = (zScore >= 0 ? '+' : '') + zScore.toStringAsFixed(2);
    final List<Map<String, dynamic>> ranges = isBBU
        ? [
            {
              'label': 'BB Sangat Kurang',
              'range': '< -3 SD',
              'color': const Color(0xFFE53935),
            },
            {
              'label': 'BB Kurang',
              'range': '-3 SD s/d -2 SD',
              'color': Colors.orange,
            },
            {
              'label': 'BB Normal (Risiko Gemuk)',
              'range': '-2 SD s/d +1 SD',
              'color': AppColors.success,
            },
            {
              'label': 'Risiko BB Lebih (Gemuk)',
              'range': '> +1 SD',
              'color': Colors.orange,
            },
          ]
        : [
            {
              'label': 'Sangat Pendek (Stunting)',
              'range': '< -3 SD',
              'color': const Color(0xFFE53935),
            },
            {
              'label': 'Pendek (Risiko Stunting)',
              'range': '-3 SD s/d -2 SD',
              'color': Colors.orange,
            },
            {
              'label': 'Normal',
              'range': '-2 SD s/d +2 SD',
              'color': AppColors.success,
            },
            {
              'label': 'Tinggi',
              'range': '> +2 SD',
              'color': AppColors.success,
            },
          ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor(value).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _statusColor(value), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child:
                  const Icon(Icons.close_rounded, color: AppColors.textLight),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Z-Score Bayi (PMK No. 2 Tahun 2020)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _statusColor(value).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _statusColor(value).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Z-Score Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$zScoreStr SD',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(value),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori: $value',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tabel Referensi Ambang Batas',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: ranges.map((item) {
                final isCurrent = item['label'].toString().toLowerCase() ==
                    value.toLowerCase();
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? item['color'].withOpacity(0.12)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent ? item['color'] : AppColors.cardBorder,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isCurrent) ...[
                            Icon(Icons.check_circle_rounded,
                                color: item['color'], size: 16),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            item['label'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight:
                                  isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? item['color']
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item['range'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isCurrent ? item['color'] : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info cards ───────────────────────────────────────────────────────────
  Widget _infoCard(String title, List<Widget> rows) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 10),
          ...rows,
        ]),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textMedium))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark))),
        ]),
      );

  Widget _statusCard(String label, String value, String zScoreStr,
          IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _statusColor(value).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _statusColor(value).withOpacity(0.3)),
          ),
          child: Column(children: [
            Icon(icon, color: _statusColor(value), size: 24),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMedium)),
            const SizedBox(height: 4),
            Text(value,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(value))),
            const SizedBox(height: 6),
            Text(
              'Z-Score: $zScoreStr SD',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor(value).withOpacity(0.85),
              ),
            ),
          ]),
        ),
      );

  int _hitungUmurBulanPadaTanggal(String lahirStr, String pemStr) {
    try {
      final partsLahir = lahirStr.split('-');
      final partsPem = pemStr.split('-');
      if (partsLahir.length != 3 || partsPem.length != 3) return 0;
      final lahir = DateTime(int.parse(partsLahir[0]), int.parse(partsLahir[1]),
          int.parse(partsLahir[2]));
      final pem = DateTime(int.parse(partsPem[0]), int.parse(partsPem[1]),
          int.parse(partsPem[2]));
      int months = (pem.year - lahir.year) * 12 + (pem.month - lahir.month);
      if (pem.day < lahir.day) {
        months--;
      }
      return months < 0 ? 0 : months;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildRekomendasiSection() {
    String stuntingTitle = "";
    String stuntingText = "";
    Color stuntingColor = Colors.grey;

    String giziTitle = "";
    String giziText = "";
    Color giziColor = Colors.grey;

    // Stunting logic
    if (_bayi.statusStunting.toLowerCase().contains('pendek') ||
        _bayi.statusStunting.toLowerCase().contains('stunting')) {
      stuntingTitle = "Anak Stunting (Pendek / Sangat Pendek)";
      stuntingText =
          "• Tetap lanjutkan ASI + MPASI gizi lengkap.\n• Protein hewani WAJIB tiap hari: telur, ikan, ayam, hati.\n• PMT Pemulihan 90 hari (biskuit/kudapan tinggi protein dari Puskesmas).\n• Pantau tiap bulan di Posyandu.\n• Rujuk ke Puskesmas untuk cek penyakit penyerta.\n• Lakukan stimulasi agar otak berkembang maksimal.\n\nCatatan: Fokus pada KEJAR TUMBUH pakai protein hewani + pantau ketat.";
      stuntingColor = const Color(0xFFE53935);
    } else {
      stuntingTitle = "Anak Tidak Stunting (Normal / Tinggi)";
      stuntingText =
          "• Pertahankan pola makan gizi seimbang (Isi Piringku).\n• Lanjut ASI sampai 2 tahun + MPASI bervariasi.\n• Timbang & ukur tiap bulan di Posyandu.\n• Pastikan anak aktif bermain agar pertumbuhan optimal.\n• Lengkapi imunisasi & Vitamin A.";
      stuntingColor = AppColors.success;
    }

    // Gizi logic
    final gizi = _bayi.statusGizi.toLowerCase();
    if (gizi.contains('sangat kurang') || gizi.contains('buruk')) {
      giziTitle = "Anak Gizi Buruk (Sangat Kurang)";
      giziText =
          "• Rujuk SEGERA ke Puskesmas/RS untuk rawat inap.\n• Terapi khusus (F75, F100) sesuai Tatalaksana Gizi Buruk.\n• Cek penyakit penyerta.\n\nDANGER: Harus ditangani Nakes. Kader wajib lapor <24 jam.";
      giziColor = const Color(0xFFE53935);
    } else if (gizi.contains('kurang')) {
      giziTitle = "Anak Gizi Kurang";
      giziText =
          "• PMT Pemulihan 90 hari tinggi protein.\n• 3x makan utama + 2x selingan padat gizi.\n• Konseling gizi untuk ibu.\n• Pantau BB tiap 2 minggu.\n\nWASPADA: Bisa jadi gizi buruk kalau telat ditangani.";
      giziColor = Colors.orange;
    } else if (gizi.contains('lebih') ||
        gizi.contains('gemuk') ||
        gizi.contains('risiko')) {
      giziTitle = "Anak Gizi Lebih (Gemuk / Risiko)";
      giziText =
          "• Kurangi porsi karbohidrat/nasi, perbanyak sayur.\n• Stop makanan/minuman manis & jajanan sachet.\n• Ajak anak aktif bergerak 60 menit/hari.";
      giziColor = Colors.orange;
    } else {
      giziTitle = "Anak Gizi Baik (Normal)";
      giziText =
          "• Pertahankan Isi Piringku: 60% karbo, 25% protein, 15% lemak.\n• Variasikan menu protein hewani.\n• Batasi gula-garam-lemak.\n• Tetap rutin ke Posyandu tiap bulan.\n\nPERTAHANKAN: Jaga agar status tidak turun.";
      giziColor = AppColors.success;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Rekomendasi Kemenkes RI',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _rekomendasiItem(stuntingTitle, stuntingText, stuntingColor),
          const SizedBox(height: 12),
          _rekomendasiItem(giziTitle, giziText, giziColor),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.blueDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kunci "Isi Piringku": 1/2 Piring Sayur+Buah, 1/3 Lauk Protein Hewani (Telur, Ikan, Hati), 1/6 Makanan Pokok.',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.blueDark,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _rekomendasiItem(String title, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 8),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textMedium, height: 1.5)),
        ],
      ),
    );
  }

  Widget _riwayatCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Riwayat Pemeriksaan',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 10),
          ..._bayi.riwayatPemeriksaan.reversed.map((r) {
            final double bb =
                double.tryParse(r['beratBadan'].toString()) ?? 0.0;
            final double tb =
                double.tryParse(r['tinggiBadan'].toString()) ?? 0.0;
            final int umurDiRiwayat = _hitungUmurBulanPadaTanggal(
                _bayi.tanggalLahir, r['tanggal'] ?? '');
            final double zBBUVal = BayiService()
                .hitungZScoreBBU(umurDiRiwayat, bb, _bayi.jenisKelamin);
            final double zTBUVal = BayiService()
                .hitungZScoreTBU(umurDiRiwayat, tb, _bayi.jenisKelamin);
            final String zBBUStr =
                (zBBUVal >= 0 ? '+' : '') + zBBUVal.toStringAsFixed(2);
            final String zTBUStr =
                (zTBUVal >= 0 ? '+' : '') + zTBUVal.toStringAsFixed(2);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(r['tanggal'] ?? '-',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text(
                          'BB: ${r['beratBadan']} kg · TB: ${r['tinggiBadan']} cm',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textMedium)),
                      const SizedBox(height: 3),
                      Text('Z-BB/U: $zBBUStr SD · Z-TB/U: $zTBUStr SD',
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(r['statusStunting'] ?? '')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(r['statusStunting'] ?? '-',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(r['statusStunting'] ?? ''))),
                  ),
                  const SizedBox(height: 2),
                  Text(r['statusGizi'] ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.textLight)),
                ]),
              ]),
            );
          }),
        ]),
      );
}


