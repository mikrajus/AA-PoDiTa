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
  State<UpdatePemeriksaanScreen> createState() => _UpdatePemeriksaanScreenState();
}

class _UpdatePemeriksaanScreenState extends State<UpdatePemeriksaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tglCtrl = TextEditingController();
  final _umurCtrl = TextEditingController();
  final _bbCtrl   = TextEditingController();
  final _tbCtrl   = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bbCtrl.text = widget.bayi.beratBadan.toString();
    _tbCtrl.text = widget.bayi.tinggiBadan.toString();
    _umurCtrl.text = '${widget.bayi.umurBulan} bulan';
    _tglCtrl.text = widget.bayi.tanggalPemeriksaan;
  }

  @override
  void dispose() {
    _tglCtrl.dispose(); _umurCtrl.dispose();
    _bbCtrl.dispose(); _tbCtrl.dispose();
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
          colorScheme: ColorScheme.light(primary: AppColors.pinkDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _tglCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    BayiService().updatePemeriksaan(
      widget.bayi.id,
      tanggalPemeriksaan: _tglCtrl.text.trim(),
      beratBadan: double.tryParse(_bbCtrl.text) ?? widget.bayi.beratBadan,
      tinggiBadan: double.tryParse(_tbCtrl.text) ?? widget.bayi.tinggiBadan,
    );

    setState(() => _isLoading = false);
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
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text('Update Pemeriksaan', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.pinkDark)),
            Text(widget.bayi.namaBayi, style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.pinkDark.withOpacity(0.7))),
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
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.child_care_rounded,
                        color: AppColors.pinkDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.bayi.namaBayi, style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                    Text('${widget.bayi.umurBulan} bulan · ${widget.bayi.jenisKelamin}',
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
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal pemeriksaan',
                  suffixIcon: const Icon(Icons.calendar_today_rounded,
                      size: 18, color: AppColors.textLight),
                ),
                onTap: _pilihTanggal,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Tanggal wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              _label('Umur Bayi (otomatis)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _umurCtrl,
                readOnly: true,
                style: GoogleFonts.poppins(fontSize: 14,
                    color: AppColors.textMedium),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 14),

              _label('Berat Badan (kg)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bbCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                decoration: const InputDecoration(hintText: 'Masukkan berat badan'),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Berat badan wajib diisi' : null,
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
                decoration: const InputDecoration(
                    hintText: 'Masukkan tinggi badan'),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Tinggi badan wajib diisi' : null,
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: _isLoading ? null : _simpan,
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.pinkDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.save_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text('Tambah Pemeriksaan',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.w600,
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

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(
      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark));
}
