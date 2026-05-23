// lib/screens/kader/kalkulator_stunting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../models/bayi_model.dart';

class KalkulatorStuntingScreen extends StatefulWidget {
  const KalkulatorStuntingScreen({super.key});
  @override
  State<KalkulatorStuntingScreen> createState() =>
      _KalkulatorStuntingScreenState();
}

class _KalkulatorStuntingScreenState extends State<KalkulatorStuntingScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _bbCtrl    = TextEditingController();
  final _tbCtrl    = TextEditingController();
  final _umurCtrl  = TextEditingController();
  final _tglCtrl   = TextEditingController();

  String _jenisKelamin = 'Laki-laki';
  BayiModel? _bayiDipilih;
  bool _sudahHitung = false;
  bool _isLoading   = false;
  bool _modePilihBayi = false; // toggle pilih bayi atau input manual

  // Hasil
  double _zScoreBBU = 0;
  double _zScoreTBU = 0;
  String _statusGizi = '';
  String _statusStunting = '';

  @override
  void dispose() {
    _bbCtrl.dispose(); _tbCtrl.dispose();
    _umurCtrl.dispose(); _tglCtrl.dispose();
    super.dispose();
  }

  void _pilihBayi(BayiModel bayi) {
    setState(() {
      _bayiDipilih = bayi;
      _jenisKelamin = bayi.jenisKelamin;
      _umurCtrl.text = '${bayi.umurBulan}';
      _bbCtrl.text = bayi.beratBadan.toString();
      _tbCtrl.text = bayi.tinggiBadan.toString();
      _sudahHitung = false;
    });
    Navigator.pop(context);
  }

  void _showPilihBayi() {
    final data = BayiService().dataBayi;
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Belum ada data bayi terdaftar',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Text('Pilih Bayi', style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textMedium),
              ),
            ]),
          ),
          const Divider(height: 1),
          ...data.map((bayi) => ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: bayi.jenisKelamin.toLowerCase().contains('laki')
                    ? AppColors.blue : AppColors.pink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                bayi.jenisKelamin.toLowerCase().contains('laki')
                    ? Icons.boy_rounded : Icons.girl_rounded,
                color: bayi.jenisKelamin.toLowerCase().contains('laki')
                    ? AppColors.blueDark : AppColors.pinkDark,
                size: 22,
              ),
            ),
            title: Text(bayi.namaBayi, style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('${bayi.umurBulan} bulan · ${bayi.jenisKelamin}',
                style: GoogleFonts.poppins(fontSize: 11)),
            onTap: () => _pilihBayi(bayi),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _hitung() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      final umur = int.tryParse(_umurCtrl.text) ?? 0;
      final bb   = double.tryParse(_bbCtrl.text) ?? 0;
      final tb   = double.tryParse(_tbCtrl.text) ?? 0;

      final hasil = BayiService().kalkulasiStunting(
        umurBulan: umur,
        beratBadan: bb,
        tinggiBadan: tb,
        jenisKelamin: _jenisKelamin,
      );

      setState(() {
        _zScoreBBU = hasil['zScoreBBU'];
        _zScoreTBU = hasil['zScoreTBU'];
        _statusGizi = hasil['statusGizi'];
        _statusStunting = hasil['statusStunting'];
        _sudahHitung = true;
        _isLoading = false;
      });
    });
  }

  void _simpanKePemeriksaan() async {
    if (_bayiDipilih == null) return;

    final tgl = _tglCtrl.text.trim();
    if (tgl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Isi tanggal pemeriksaan dulu',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Simpan Pemeriksaan?', style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700)),
        content: Text(
          'Hasil ini akan disimpan sebagai pemeriksaan baru untuk ${_bayiDipilih!.namaBayi}.',
          style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(
                color: AppColors.textMedium))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Simpan', style: GoogleFonts.poppins(
                color: AppColors.pinkDark, fontWeight: FontWeight.w600))),
        ],
      ),
    );

    if (konfirmasi != true) return;

    BayiService().updatePemeriksaan(
      _bayiDipilih!.id,
      tanggalPemeriksaan: tgl,
      beratBadan: double.tryParse(_bbCtrl.text) ?? _bayiDipilih!.beratBadan,
      tinggiBadan: double.tryParse(_tbCtrl.text) ?? _bayiDipilih!.tinggiBadan,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pemeriksaan berhasil disimpan!',
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
    Navigator.pop(context, true);
  }

  Color get _statusStuntingColor {
    if (_statusStunting.contains('Sangat')) return const Color(0xFFE53935);
    if (_statusStunting.contains('Pendek')) return const Color(0xFFE57373);
    return AppColors.success;
  }

  Color get _statusGiziColor {
    if (_statusGizi.contains('Sangat')) return const Color(0xFFE53935);
    if (_statusGizi.contains('Kurang')) return const Color(0xFFE57373);
    if (_statusGizi.contains('Risiko')) return Colors.orange;
    return AppColors.success;
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.pinkDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tglCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
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
            Text('BB/U & TB/U · PMK No.2 Tahun 2020',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.pinkDark.withOpacity(0.7))),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Info
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
                'Menghitung BB/U (Status Gizi) dan TB/U (Status Stunting) berdasarkan PMK No.2 Tahun 2020.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.blueDark, height: 1.4),
              )),
            ]),
          ),
          const SizedBox(height: 16),

          // Pilih bayi (opsional)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Pilih Bayi (Opsional)', style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Pilih bayi terdaftar untuk simpan hasil otomatis',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textMedium)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showPilihBayi,
                child: Container(
                  width: double.infinity, height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.pinkPale,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.pink),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.person_search_rounded,
                        color: AppColors.pinkDark, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _bayiDipilih == null
                          ? 'Pilih dari daftar bayi'
                          : _bayiDipilih!.namaBayi,
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.pinkDark),
                    ),
                  ]),
                ),
              ),
              if (_bayiDipilih != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _bayiDipilih = null;
                    _umurCtrl.clear();
                    _bbCtrl.clear();
                    _tbCtrl.clear();
                    _jenisKelamin = 'Laki-laki';
                    _sudahHitung = false;
                  }),
                  child: Text('Hapus pilihan',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMedium,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 16),

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
                // Jenis kelamin
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
                          DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: _bayiDipilih != null ? null : (v) =>
                          setState(() {
                            _jenisKelamin = v!;
                            _sudahHitung = false;
                          }),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Umur
                _label('Umur (bulan)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _umurCtrl,
                  readOnly: _bayiDipilih != null,
                  style: GoogleFonts.poppins(fontSize: 14,
                      color: _bayiDipilih != null
                          ? AppColors.textMedium : AppColors.textDark),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Contoh: 26',
                    filled: _bayiDipilih != null,
                    fillColor: _bayiDipilih != null
                        ? const Color(0xFFF1F5F9) : AppColors.white,
                  ),
                  onChanged: (_) => setState(() => _sudahHitung = false),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Umur wajib diisi';
                    final u = int.tryParse(v) ?? 0;
                    if (u < 0 || u > 60) return 'Umur 0-60 bulan';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Berat badan
                _label('Berat Badan (kg)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bbCtrl,
                  style: GoogleFonts.poppins(fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  decoration: const InputDecoration(hintText: 'Contoh: 9.2'),
                  onChanged: (_) => setState(() => _sudahHitung = false),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Berat badan wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // Tinggi badan
                _label('Tinggi Badan (cm)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tbCtrl,
                  style: GoogleFonts.poppins(fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  decoration: const InputDecoration(hintText: 'Contoh: 78.5'),
                  onChanged: (_) => setState(() => _sudahHitung = false),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Tinggi badan wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                // Tombol hitung
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
                              Text('Hitung Status', style: GoogleFonts.poppins(
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(children: [
                Text('Hasil Perhitungan', style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
                const SizedBox(height: 16),

                // BB/U
                _hasilCard(
                  label: 'Status Gizi (BB/U)',
                  status: _statusGizi,
                  zScore: _zScoreBBU,
                  color: _statusGiziColor,
                  icon: Icons.monitor_weight_rounded,
                ),
                const SizedBox(height: 12),

                // TB/U
                _hasilCard(
                  label: 'Status Stunting (TB/U)',
                  status: _statusStunting,
                  zScore: _zScoreTBU,
                  color: _statusStuntingColor,
                  icon: Icons.straighten_rounded,
                ),
                const SizedBox(height: 16),

                // Rumus
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
                      'Z = (TB anak − TB median) / (TB median − (−1SD))\n'
                      'Z = ${_zScoreTBU.toStringAsFixed(2)} SD → $_statusStunting',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMedium,
                          height: 1.5),
                    ),
                  ]),
                ),

                // Tombol simpan jika ada bayi dipilih
                if (_bayiDipilih != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Simpan sebagai pemeriksaan baru untuk',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMedium)),
                  Text(_bayiDipilih!.namaBayi, style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  // Tanggal pemeriksaan
                  TextFormField(
                    controller: _tglCtrl,
                    readOnly: true,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Pilih tanggal pemeriksaan',
                      suffixIcon: const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.textLight),
                    ),
                    onTap: _pilihTanggal,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _simpanKePemeriksaan,
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.pinkDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const Icon(Icons.save_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Simpan ke Riwayat Bayi',
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ]),
                    ),
                  ),
                ],
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

  Widget _hasilCard({
    required String label,
    required String status,
    required double zScore,
    required Color color,
    required IconData icon,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.textMedium)),
            Text(status, style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            Text('Z-Score: ${zScore.toStringAsFixed(2)} SD',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMedium)),
          ])),
        ]),
      );
}
