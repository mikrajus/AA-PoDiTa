// lib/screens/kader/update_pemeriksaan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/bayi_model.dart';
import '../../services/bayi_service.dart';

class UpdatePemeriksaanScreen extends StatefulWidget {
  final BayiModel bayi;
  const UpdatePemeriksaanScreen({super.key, required this.bayi});
  @override
  State<UpdatePemeriksaanScreen> createState() =>
      _UpdatePemeriksaanScreenState();
}

class _UpdatePemeriksaanScreenState extends State<UpdatePemeriksaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tglCtrl = TextEditingController();
  final _umurCtrl = TextEditingController();
  final _bbCtrl = TextEditingController();
  final _tbCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bbCtrl.text = (widget.bayi.beratBadan * 1000).toInt().toString();
    _tbCtrl.text = widget.bayi.tinggiBadan.toString();
    _umurCtrl.text = '${widget.bayi.umurBulan} bulan';
    _tglCtrl.text = widget.bayi.tanggalPemeriksaan;
  }

  @override
  void dispose() {
    _tglCtrl.dispose();
    _umurCtrl.dispose();
    _bbCtrl.dispose();
    _tbCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.pinkDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final newDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _tglCtrl.text = newDate;

      // Hitung ulang umur berdasarkan tanggal baru
      try {
        final parts = widget.bayi.tanggalLahir.split('-');
        if (parts.length == 3) {
          final lahir = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          final umurBaru =
              (picked.year - lahir.year) * 12 + (picked.month - lahir.month);
          setState(() {
            _umurCtrl.text = '$umurBaru bulan';
          });
        }
      } catch (_) {}
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final bb = _bbCtrl.text.isEmpty
        ? widget.bayi.beratBadan
        : (double.tryParse(_bbCtrl.text) ?? 0) / 1000.0;
    final tb = double.tryParse(_tbCtrl.text) ?? widget.bayi.tinggiBadan;

    final zBBU = BayiService()
        .hitungZScoreBBU(widget.bayi.umurBulan, bb, widget.bayi.jenisKelamin);
    final zTBU = BayiService()
        .hitungZScoreTBU(widget.bayi.umurBulan, tb, widget.bayi.jenisKelamin);

    BayiService().updatePemeriksaan(
      widget.bayi.id,
      tanggalPemeriksaan: _tglCtrl.text.trim(),
      beratBadan: bb,
      tinggiBadan: tb,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    await _showResultDialog(context, widget.bayi, zBBU, zTBU);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pemeriksaan berhasil diperbarui!',
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
    Navigator.pop(context, true);
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
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Update Pemeriksaan',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pinkDark)),
                Text(widget.bayi.namaBayi,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.pinkDark.withOpacity(0.7))),
              ]),
        ]),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info bayi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pinkPale,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.pink),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.child_care_rounded,
                        color: AppColors.pinkDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.bayi.namaBayi,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        Text(
                            '${widget.bayi.umurBulan} bulan · ${widget.bayi.jenisKelamin}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textMedium)),
                      ]),
                ]),
              ),
              const SizedBox(height: 24),

              _label('Tanggal Pemeriksaan'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tglCtrl,
                readOnly: true,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Pilih tanggal pemeriksaan',
                  suffixIcon: Icon(Icons.calendar_today_rounded,
                      size: 18, color: AppColors.textLight),
                ),
                onTap: _pilihTanggal,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Tanggal wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              _label('Umur Bayi (otomatis)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _umurCtrl,
                readOnly: true,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textMedium),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 14),

              _label('Berat Badan (gram)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bbCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                ],
                decoration: const InputDecoration(hintText: 'Contoh: 9200'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Berat badan wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              _label('Tinggi Badan (cm)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tbCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                ],
                decoration:
                    const InputDecoration(hintText: 'Masukkan tinggi badan'),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Tinggi badan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: _isLoading ? null : _simpan,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.pinkDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.save_rounded,
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark));

  Future<void> _showResultDialog(
      BuildContext context, BayiModel bayi, double zBBU, double zTBU) async {
    Color statusColor(String status) {
      final s = status.toLowerCase();
      if (s.contains('sangat pendek')) return const Color(0xFFE53935);
      if (s.contains('pendek')) return Colors.orange;
      return AppColors.success;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.pinkPale,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: AppColors.pinkDark,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hasil Z-Score Pemeriksaan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: ${bayi.namaBayi}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Umur: ${bayi.umurBulan} bulan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.monitor_weight_rounded,
                    color: statusColor(bayi.statusGizi), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Gizi (BB/U)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                      Text(
                        '${zBBU.toStringAsFixed(2)} SD (${bayi.statusGizi})',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: statusColor(bayi.statusGizi),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.straighten_rounded,
                    color: statusColor(bayi.statusStunting), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Stunting (TB/U)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                      Text(
                        '${zTBU.toStringAsFixed(2)} SD (${bayi.statusStunting})',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: statusColor(bayi.statusStunting),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.pinkDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
