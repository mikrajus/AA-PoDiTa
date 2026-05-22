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
    if (status.toLowerCase().contains('stunting')) return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    if (status.toLowerCase().contains('pendek')) return Colors.orange;
    return AppColors.success;
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(_bayi.statusStunting).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor(_bayi.statusStunting).withOpacity(0.4)),
                  ),
                  child: Text(_bayi.statusStunting,
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: _statusColor(_bayi.statusStunting))),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 14),

          // Data ukur
          _infoCard('Data Pengukuran', [
            _infoRow('Nama Bayi', _bayi.namaBayi),
            _infoRow('Umur Bayi', '${_bayi.umurBulan} bulan'),
            _infoRow('Berat Badan', '${_bayi.beratBadan} kg'),
            _infoRow('Tinggi Badan', '${_bayi.tinggiBadan} cm'),
            _infoRow('Jenis Kelamin', _bayi.jenisKelamin),
            _infoRow('Nama Ibu', _bayi.namaIbu),
            _infoRow('Tanggal Pemeriksaan', _bayi.tanggalPemeriksaan),
          ]),
          const SizedBox(height: 14),

          // Status gizi & stunting
          Row(children: [
            Expanded(child: _statusCard(
                'Status Gizi', _bayi.statusGizi,
                Icons.monitor_weight_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statusCard(
                'Status Stunting', _bayi.statusStunting,
                Icons.health_and_safety_rounded)),
          ]),
          const SizedBox(height: 14),

          // Grafik placeholder
          _grafikCard(),
          const SizedBox(height: 14),

          // Riwayat
          if (_bayi.riwayatPemeriksaan.isNotEmpty) ...[
            _riwayatCard(),
            const SizedBox(height: 14),
          ],

          // Tombol update
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
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_chart_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Tambah Pemeriksaan',
                    style: GoogleFonts.poppins(
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
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
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

  Widget _grafikCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Grafik Pertumbuhan', style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 12),
      if (_bayi.riwayatPemeriksaan.length < 2)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Icon(Icons.show_chart_rounded,
                  size: 40, color: AppColors.textLight),
              const SizedBox(height: 8),
              Text('Butuh minimal 2 data pengukuran',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textLight)),
            ]),
          ),
        )
      else
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: const Size(double.infinity, 120),
            painter: _GrafikPainter(_bayi.riwayatPemeriksaan
                .map((r) => (r['tinggiBadan'] as double)).toList()),
          ),
        ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(r['statusStunting'] ?? '').withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(r['statusStunting'] ?? '-',
                style: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: _statusColor(r['statusStunting'] ?? ''))),
          ),
        ]),
      )),
    ]),
  );
}

class _GrafikPainter extends CustomPainter {
  final List<double> data;
  _GrafikPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = AppColors.pinkDark
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.pink.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final minVal = data.reduce((a, b) => a < b ? a : b) - 2;
    final maxVal = data.reduce((a, b) => a > b ? a : b) + 2;
    final range = maxVal - minVal;

    double x(int i) => i * size.width / (data.length - 1);
    double y(double v) => size.height - ((v - minVal) / range * size.height);

    final path = Path()..moveTo(x(0), y(data[0]));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(x(i), y(data[i]));
    }

    final fillPath = Path()..moveTo(x(0), size.height);
    for (int i = 0; i < data.length; i++) {
      fillPath.lineTo(x(i), y(data[i]));
    }
    fillPath.lineTo(x(data.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = AppColors.pinkDark
      ..style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      canvas.drawCircle(Offset(x(i), y(data[i])), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
