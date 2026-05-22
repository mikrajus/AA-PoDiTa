// lib/screens/kader/tambah_bayi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/bayi_model.dart';
import '../../services/bayi_service.dart';

class TambahBayiScreen extends StatefulWidget {
  const TambahBayiScreen({super.key});
  @override
  State<TambahBayiScreen> createState() => _TambahBayiScreenState();
}

class _TambahBayiScreenState extends State<TambahBayiScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _tglPemeriksaanCtrl = TextEditingController();
  final _namaBayiCtrl       = TextEditingController();
  final _tglLahirCtrl       = TextEditingController();
  final _bbCtrl             = TextEditingController();
  final _tbCtrl             = TextEditingController();
  final _namaIbuCtrl        = TextEditingController();
  final _umurIbuCtrl        = TextEditingController();
  final _pendidikanCtrl     = TextEditingController();
  final _pekerjaanCtrl      = TextEditingController();
  final _jumlahAnakCtrl     = TextEditingController();

  String _jenisKelamin = 'Laki-laki';

  @override
  void dispose() {
    _tglPemeriksaanCtrl.dispose(); _namaBayiCtrl.dispose();
    _tglLahirCtrl.dispose(); _bbCtrl.dispose(); _tbCtrl.dispose();
    _namaIbuCtrl.dispose(); _umurIbuCtrl.dispose();
    _pendidikanCtrl.dispose(); _pekerjaanCtrl.dispose();
    _jumlahAnakCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(TextEditingController ctrl) async {
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
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final bayi = BayiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaBayi: _namaBayiCtrl.text.trim(),
      tanggalLahir: _tglLahirCtrl.text.trim(),
      jenisKelamin: _jenisKelamin,
      beratBadan: double.tryParse(_bbCtrl.text) ?? 0,
      tinggiBadan: double.tryParse(_tbCtrl.text) ?? 0,
      namaIbu: _namaIbuCtrl.text.trim(),
      umurIbu: _umurIbuCtrl.text.trim(),
      pendidikanIbu: _pendidikanCtrl.text.trim(),
      pekerjaanIbu: _pekerjaanCtrl.text.trim(),
      jumlahAnak: int.tryParse(_jumlahAnakCtrl.text) ?? 1,
      tanggalPemeriksaan: _tglPemeriksaanCtrl.text.trim(),
    );

    // Hitung status awal
    BayiService().updatePemeriksaan(
      bayi.id,
      tanggalPemeriksaan: bayi.tanggalPemeriksaan,
      beratBadan: bayi.beratBadan,
      tinggiBadan: bayi.tinggiBadan,
    );
    // Tambah dulu baru update
    BayiService().tambahBayi(bayi);
    // Update status
    BayiService().updatePemeriksaan(
      bayi.id,
      tanggalPemeriksaan: bayi.tanggalPemeriksaan,
      beratBadan: bayi.beratBadan,
      tinggiBadan: bayi.tinggiBadan,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data bayi berhasil ditambahkan!',
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
            Text('Tambah Bayi', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.pinkDark)),
            Text('Isi data bayi baru', style: GoogleFonts.poppins(
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
              _sectionHeader('Tanggal Pemeriksaan', Icons.calendar_today_rounded),
              const SizedBox(height: 12),
              _dateField(_tglPemeriksaanCtrl, 'Masukkan Tanggal Pemeriksaan'),
              const SizedBox(height: 24),

              _sectionHeader('Identitas Bayi', Icons.child_care_rounded),
              const SizedBox(height: 12),
              _inputField(_namaBayiCtrl, 'Nama Bayi', 'Masukkan Nama Bayi'),
              const SizedBox(height: 12),
              _dateField(_tglLahirCtrl, 'Masukkan Tanggal Lahir Bayi'),
              const SizedBox(height: 12),
              _jenisKelaminField(),
              const SizedBox(height: 12),
              _numberField(_bbCtrl, 'Berat Badan (kg)', 'Masukkan Berat Badan Bayi'),
              const SizedBox(height: 12),
              _numberField(_tbCtrl, 'Tinggi Badan (cm)', 'Masukkan Tinggi Badan Bayi'),
              const SizedBox(height: 24),

              _sectionHeader('Identitas Ibu', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _inputField(_namaIbuCtrl, 'Nama Ibu', 'Masukkan Nama Ibu'),
              const SizedBox(height: 12),
              _numberField(_umurIbuCtrl, 'Umur Ibu', 'Masukkan Umur Ibu'),
              const SizedBox(height: 12),
              _inputField(_pendidikanCtrl, 'Pendidikan Terakhir',
                  'Masukkan Pendidikan Terakhir Ibu'),
              const SizedBox(height: 12),
              _inputField(_pekerjaanCtrl, 'Pekerjaan Ibu',
                  'Masukkan Pekerjaan Ibu'),
              const SizedBox(height: 12),
              _numberField(_jumlahAnakCtrl, 'Jumlah Anak',
                  'Masukkan Jumlah Anak'),
              const SizedBox(height: 32),

              // Tombol simpan
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
                            Text('Tambah Anak',
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

  Widget _sectionHeader(String title, IconData icon) => Row(children: [
    Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.pinkPale, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: AppColors.pinkDark),
    ),
    const SizedBox(width: 8),
    Text(title, style: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
  ]);

  Widget _inputField(TextEditingController ctrl, String label, String hint,
      {bool required = true}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(hintText: hint),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
              : null,
        ),
      ]);

  Widget _numberField(TextEditingController ctrl, String label, String hint) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 14),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: InputDecoration(hintText: hint),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      ]);

  Widget _dateField(TextEditingController ctrl, String hint) =>
      TextFormField(
        controller: ctrl,
        readOnly: true,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.calendar_today_rounded,
              size: 18, color: AppColors.textLight),
        ),
        onTap: () => _pilihTanggal(ctrl),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Tanggal wajib diisi' : null,
      );

  Widget _jenisKelaminField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Jenis Kelamin', style: GoogleFonts.poppins(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
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
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
          items: ['Laki-laki', 'Perempuan'].map((v) =>
              DropdownMenuItem(value: v,
                  child: Text(v, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _jenisKelamin = v!),
        ),
      ),
    ),
  ]);
}
