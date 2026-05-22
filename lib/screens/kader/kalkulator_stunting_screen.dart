// lib/screens/kader/kalkulator_stunting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';

class KalkulatorStuntingScreen extends StatefulWidget {
  const KalkulatorStuntingScreen({super.key});
  @override
  State<KalkulatorStuntingScreen> createState() =>
      _KalkulatorStuntingScreenState();
}

class _KalkulatorStuntingScreenState extends State<KalkulatorStuntingScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _umurCtrl = TextEditingController();
  final _tbCtrl   = TextEditingController();
  String _jenisKelamin = 'Laki-laki';
  bool _sudahHitung = false;
  double _zScore = 0;
  String _statusGizi = '';
  String _statusStunting = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _umurCtrl.dispose(); _tbCtrl.dispose(); super.dispose();
  }

  void _hitung() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      final umur = int.tryParse(_umurCtrl.text) ?? 0;
      final tb   = double.tryParse(_tbCtrl.text) ?? 0;

      // Gunakan BayiService untuk hitung z-score
      final svc = BayiService();
      // Buat bayi dummy untuk hitung
      final isMale = _jenisKelamin.toLowerCase().contains('laki');
      final tabel = isMale ? BayiService.tabelLakiLaki : BayiService.tabelPerempuan;
      final idx = umur.clamp(0, tabel.length - 1);
      final row = tabel[idx];
      final median = row[0];
      final sd1Neg = row[1];
      final sd1Pos = row[2];

      final z = tb < median
          ? (tb - median) / (median - sd1Neg)
          : (tb - median) / (sd1Pos - median);

      String statusGizi;
      if (z < -3) statusGizi = 'Sangat Pendek';
      else if (z < -2) statusGizi = 'Pendek';
      else if (z <= 2) statusGizi = 'Normal';
      else statusGizi = 'Tinggi';

      String statusStunting;
      if (z < -3) statusStunting = 'Stunting Berat';
      else if (z < -2) statusStunting = 'Stunting';
      else if (z < -1) statusStunting = 'Risiko Stunting';
      else statusStunting = 'Normal';

      setState(() {
        _zScore = z;
        _statusGizi = statusGizi;
        _statusStunting = statusStunting;
        _sudahHitung = true;
        _isLoading = false;
      });
    });
  }

  Color get _statusColor {
    if (_statusStunting.contains('Berat')) return const Color(0xFFE53935);
    if (_statusStunting.contains('Stunting') &&
        !_statusStunting.contains('Risiko')) return const Color(0xFFE57373);
    if (_statusStunting.contains('Risiko')) return Colors.orange;
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
            Text('Kalkulator Stunting', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.pinkDark)),
            Text('Standar WHO · PMK No.2 Tahun 2020',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.pinkDark.withOpacity(0.7))),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.blueDark),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Menggunakan rumus Z-Score TB/U berdasarkan standar WHO dan PMK Nomor 2 Tahun 2020.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.blueDark, height: 1.4),
              )),
            ]),
          ),
          const SizedBox(height: 20),

          // Form input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Form(
              key: _formKey,
              child: Column(children: [
                _label('Jenis Kelamin'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _jenisKelamin,
                      isExpanded: true,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textDark),
                      items: ['Laki-laki', 'Perempuan'].map((v) =>
                          DropdownMenuItem(value: v,
                              child: Text(v))).toList(),
                      onChanged: (v) =>
                          setState(() { _jenisKelamin = v!; _sudahHitung = false; }),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _label('Umur (bulan)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _umurCtrl,
                  style: GoogleFonts.poppins(fontSize: 14),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: 'Contoh: 26'),
                  onChanged: (_) => setState(() => _sudahHitung = false),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Umur wajib diisi';
                    final u = int.tryParse(v) ?? 0;
                    if (u < 0 || u > 60) return 'Umur 0-60 bulan';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _label('Tinggi Badan (cm)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tbCtrl,
                  style: GoogleFonts.poppins(fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  decoration: const InputDecoration(hintText: 'Contoh: 87'),
                  onChanged: (_) => setState(() => _sudahHitung = false),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Tinggi badan wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _isLoading ? null : _hitung,
                  child: Container(
                    width: double.infinity, height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.blueDark, strokeWidth: 2.5))
                          : Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.calculate_rounded,
                                  color: AppColors.blueDark, size: 20),
                              const SizedBox(width: 8),
                              Text('Hitung Status',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, fontWeight: FontWeight.w600,
                                      color: AppColors.blueDark)),
                            ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // Hasil
          if (_sudahHitung) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor.withOpacity(0.4)),
              ),
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _statusStunting == 'Normal'
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: _statusColor, size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hasil Perhitungan', style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textMedium)),
                    Text(_statusStunting, style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: _statusColor)),
                  ])),
                ]),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),

                _hasilRow('Z-Score', '${_zScore.toStringAsFixed(2)} SD'),
                _hasilRow('Status Gizi', _statusGizi),
                _hasilRow('Status Stunting', _statusStunting),

                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Rumus Z-Score TB/U:', style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textMedium)),
                    const SizedBox(height: 4),
                    Text(
                      'Z = (TB anak – TB median) / (TB median – (-1SD))\n'
                      'Z = (${_tbCtrl.text} – referensi) = ${_zScore.toStringAsFixed(2)} SD',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMedium, height: 1.5),
                    ),
                  ]),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.poppins(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
  );

  Widget _hasilRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(label, style: GoogleFonts.poppins(
          fontSize: 13, color: AppColors.textMedium))),
      Text(value, style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    ]),
  );
}
