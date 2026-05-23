// lib/screens/kader/detail_bayi_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/bayi_model.dart';
import 'update_pemeriksaan_screen.dart';

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
    if (status.toLowerCase().contains('berat')) return const Color(0xFFE53935);
    if (status.toLowerCase() == 'stunting') return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    if (status.toLowerCase().contains('pendek')) return Colors.orange;
    return AppColors.success;
  }

  // Konversi status stunting ke angka untuk grafik
  double _statusToValue(String status) {
    switch (status.toLowerCase()) {
      case 'normal': return 4;
      case 'risiko stunting': return 3;
      case 'stunting': return 2;
      case 'stunting berat': return 1;
      default: return 0;
    }
  }

  // Konversi status gizi ke angka untuk grafik
  double _giziToValue(String status) {
    switch (status.toLowerCase()) {
      case 'normal': return 4;
      case 'tinggi': return 5;
      case 'pendek': return 2;
      case 'sangat pendek': return 1;
      default: return 0;
    }
  }

  // Ambil semua riwayat + data terkini sebagai list terurut
  List<Map<String, dynamic>> get _semuaData {
    final List<Map<String, dynamic>> data = [];
    // Riwayat lama (dari yang paling awal)
    for (final r in _bayi.riwayatPemeriksaan) {
      data.add({
        'tanggal': r['tanggal'] ?? '-',
        'statusGizi': r['statusGizi'] ?? '-',
        'statusStunting': r['statusStunting'] ?? '-',
      });
    }
    // Data terkini
    data.add({
      'tanggal': _bayi.tanggalPemeriksaan,
      'statusGizi': _bayi.statusGizi,
      'statusStunting': _bayi.statusStunting,
    });
    return data;
  }

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
            Text('Detail Bayi', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.pinkDark)),
            Text(_bayi.namaBayi, style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.pinkDark.withOpacity(0.7))),
          ]),
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
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: _bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? AppColors.blue : AppColors.pink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? Icons.boy_rounded : Icons.girl_rounded,
                  color: _bayi.jenisKelamin.toLowerCase().contains('laki')
                      ? AppColors.blueDark : AppColors.pinkDark,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_bayi.namaBayi, style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700,
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
                    color: _statusColor(_bayi.statusStunting).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor(_bayi.statusStunting)
                            .withOpacity(0.4)),
                  ),
                  child: Text(_bayi.statusStunting, style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _statusColor(_bayi.statusStunting))),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Data pengukuran ────────────────────────────────────────────
          _infoCard('Data Pengukuran', [
            _infoRow('Nama Bayi', _bayi.namaBayi),
            _infoRow('Umur Bayi', '${_bayi.umurBulan} bulan'),
            _infoRow('Berat Badan', '${_bayi.beratBadan} kg'),
            _infoRow('Tinggi Badan', '${_bayi.tinggiBadan} cm'),
            _infoRow('Jenis Kelamin', _bayi.jenisKelamin),
            _infoRow('Nama Ibu', _bayi.namaIbu),
            _infoRow('Tgl Pemeriksaan', _bayi.tanggalPemeriksaan),
          ]),
          const SizedBox(height: 14),

          // ── Status card ────────────────────────────────────────────────
          Row(children: [
            Expanded(child: _statusCard('Status Gizi', _bayi.statusGizi,
                Icons.monitor_weight_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statusCard('Status Stunting', _bayi.statusStunting,
                Icons.health_and_safety_rounded)),
          ]),
          const SizedBox(height: 14),

          // ── Grafik Status Gizi ─────────────────────────────────────────
          _buildGrafikCard(
            title: 'Grafik Status Gizi',
            data: _semuaData,
            getValue: (d) => _giziToValue(d['statusGizi']),
            getLabel: (d) => d['statusGizi'],
            color: AppColors.blueDark,
            bgColor: AppColors.blue,
            labelMap: {
              5: 'Tinggi',
              4: 'Normal',
              2: 'Pendek',
              1: 'Sangat Pendek',
            },
          ),
          const SizedBox(height: 14),

          // ── Grafik Status Stunting ─────────────────────────────────────
          _buildGrafikCard(
            title: 'Grafik Status Stunting',
            data: _semuaData,
            getValue: (d) => _statusToValue(d['statusStunting']),
            getLabel: (d) => d['statusStunting'],
            color: AppColors.pinkDark,
            bgColor: AppColors.pink,
            labelMap: {
              4: 'Normal',
              3: 'Risiko',
              2: 'Stunting',
              1: 'Berat',
            },
          ),
          const SizedBox(height: 14),

          // ── Riwayat pemeriksaan ────────────────────────────────────────
          if (_bayi.riwayatPemeriksaan.isNotEmpty) ...[
            _riwayatCard(),
            const SizedBox(height: 14),
          ],

          // ── Tombol update ──────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                      UpdatePemeriksaanScreen(bayi: _bayi)));
              if (result == true) setState(() {});
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                color: AppColors.pinkDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Icon(Icons.add_chart_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Tambah Pemeriksaan', style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600,
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
    required double Function(Map<String, dynamic>) getValue,
    required String Function(Map<String, dynamic>) getLabel,
    required Color color,
    required Color bgColor,
    required Map<int, String> labelMap,
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
          Text(title, style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
        ]),
        const SizedBox(height: 14),

        if (data.length < 2)
          Center(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Icon(Icons.show_chart_rounded, size: 36, color: color.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text('Butuh minimal 2 data pemeriksaan',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textLight)),
            ]),
          ))
        else ...[
          // Grafik
          SizedBox(
            height: 130,
            child: CustomPaint(
              size: const Size(double.infinity, 130),
              painter: _StatusGrafikPainter(
                values: data.map(getValue).toList(),
                color: color,
                bgColor: bgColor,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Label tanggal di bawah grafik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(data.length, (i) {
              final tgl = data[i]['tanggal'] as String;
              // Ambil bulan-tahun saja
              final parts = tgl.split('-');
              final label = parts.length >= 2
                  ? '${parts[1]}/${parts[0].substring(2)}'
                  : tgl;
              return Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 9, color: AppColors.textLight)),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Status terkini
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor(getLabel(data.last)).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: _statusColor(getLabel(data.last)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Terkini: ',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textMedium)),
              Text(getLabel(data.last),
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: _statusColor(getLabel(data.last)))),
            ]),
          ),
        ],
      ]),
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
      Text(title, style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.textDark)),
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
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.textDark)),
      const SizedBox(height: 10),
      ..._bayi.riwayatPemeriksaan.reversed.map((r) => Container(
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
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(r['statusStunting'] ?? '')
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(r['statusStunting'] ?? '-',
                  style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: _statusColor(r['statusStunting'] ?? ''))),
            ),
            const SizedBox(height: 2),
            Text(r['statusGizi'] ?? '-', style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.textLight)),
          ]),
        ]),
      )),
    ]),
  );
}

// ── Custom Painter untuk grafik status ──────────────────────────────────────
class _StatusGrafikPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color bgColor;

  _StatusGrafikPainter({
    required this.values,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxVal = 5.0;
    final minVal = 0.0;
    final range = maxVal - minVal;

    double x(int i) => i * size.width / (values.length - 1);
    double y(double v) =>
        size.height - ((v - minVal) / range * (size.height - 20)) - 10;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.cardBorder
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final yPos = size.height - (i / 5 * (size.height - 20)) - 10;
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }

    // Fill
    final fillPath = Path()..moveTo(x(0), size.height);
    for (int i = 0; i < values.length; i++) {
      fillPath.lineTo(x(i), y(values[i]));
    }
    fillPath.lineTo(x(values.length - 1), size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()..color = bgColor.withOpacity(0.2)..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path()..moveTo(x(0), y(values[0]));
    for (int i = 1; i < values.length; i++) {
      linePath.lineTo(x(i), y(values[i]));
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(
        Offset(x(i), y(values[i])),
        5,
        Paint()..color = Colors.white..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(x(i), y(values[i])),
        4,
        Paint()..color = color..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
