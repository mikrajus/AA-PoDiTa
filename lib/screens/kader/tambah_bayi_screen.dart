// lib/screens/kader/tambah_bayi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/bayi_model.dart';
import '../../services/bayi_service.dart';
import '../../services/auth_service.dart';

class TambahBayiScreen extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onSuccess;
  final BayiModel? bayiToEdit;

  const TambahBayiScreen({
    super.key,
    this.showBackButton = true,
    this.onSuccess,
    this.bayiToEdit,
  });

  @override
  State<TambahBayiScreen> createState() => _TambahBayiScreenState();
}

class _TambahBayiScreenState extends State<TambahBayiScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _tglPemeriksaanCtrl = TextEditingController();
  final _namaBayiCtrl = TextEditingController();
  final _tglLahirCtrl = TextEditingController();
  final _bbCtrl = TextEditingController();
  final _tbCtrl = TextEditingController();
  final _namaIbuCtrl = TextEditingController();
  final _umurIbuCtrl = TextEditingController();
  final _pekerjaanCtrl = TextEditingController();
  final _anakKeCtrl = TextEditingController();
  final _jumlahAnakCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  String _jenisKelamin = 'Laki-laki';
  String _pendidikan = 'SMA/SMK';
  String _desa = 'Blang Teue';

  final List<String> _pendidikanOptions = [
    'Tidak Sekolah',
    'SD/Sederajat',
    'SMP/Sederajat',
    'SMA/SMK',
    'Diploma (D1-D4)',
    'Sarjana (S1)',
    'Magister (S2)',
    'Doktor (S3)',
  ];

  String _getValidPendidikan(String val) {
    if (_pendidikanOptions.contains(val)) return val;
    final low = val.toLowerCase();
    if (low.contains('s1') || low.contains('sarjana')) return 'Sarjana (S1)';
    if (low.contains('sma') || low.contains('smk')) return 'SMA/SMK';
    if (low.contains('smp')) return 'SMP/Sederajat';
    if (low.contains('sd')) return 'SD/Sederajat';
    if (low.contains('diploma') || low.contains('d3')) return 'Diploma (D1-D4)';
    if (low.contains('s2')) return 'Magister (S2)';
    if (low.contains('s3')) return 'Doktor (S3)';
    return 'SMA/SMK';
  }

  @override
  void initState() {
    super.initState();
    if (widget.bayiToEdit != null) {
      final b = widget.bayiToEdit!;
      _namaBayiCtrl.text = b.namaBayi;
      _tglLahirCtrl.text = b.tanggalLahir;
      _jenisKelamin = b.jenisKelamin;
      _bbCtrl.text = (b.beratBadan * 1000).toInt().toString();
      _tbCtrl.text = b.tinggiBadan.toString();
      _namaIbuCtrl.text = b.namaIbu;
      _umurIbuCtrl.text = b.umurIbu;
      _pekerjaanCtrl.text = b.pekerjaanIbu;
      _pendidikan = _getValidPendidikan(b.pendidikanIbu);
      _anakKeCtrl.text = b.anakKe.toString();
      _jumlahAnakCtrl.text = b.jumlahAnak.toString();
      _tglPemeriksaanCtrl.text = b.tanggalPemeriksaan;
      _noHpCtrl.text = b.noHpIbu == '-' ? '' : b.noHpIbu;
      _desa = b.desa;
    }
  }

  @override
  void dispose() {
    _tglPemeriksaanCtrl.dispose();
    _namaBayiCtrl.dispose();
    _tglLahirCtrl.dispose();
    _bbCtrl.dispose();
    _tbCtrl.dispose();
    _namaIbuCtrl.dispose();
    _umurIbuCtrl.dispose();
    _pekerjaanCtrl.dispose();
    _anakKeCtrl.dispose();
    _jumlahAnakCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(TextEditingController ctrl,
      {DateTime? firstDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.pinkDark),
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
      id: widget.bayiToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      namaBayi: _namaBayiCtrl.text.trim(),
      tanggalLahir: _tglLahirCtrl.text.trim(),
      jenisKelamin: _jenisKelamin,
      beratBadan: (double.tryParse(_bbCtrl.text) ?? 0) / 1000.0,
      tinggiBadan: double.tryParse(_tbCtrl.text) ?? 0,
      namaIbu: _namaIbuCtrl.text.trim(),
      umurIbu: _umurIbuCtrl.text.trim(),
      pendidikanIbu: _pendidikan,
      pekerjaanIbu: _pekerjaanCtrl.text.trim(),
      noHpIbu: _noHpCtrl.text.trim().isEmpty ? '-' : _noHpCtrl.text.trim(),
      desa: _desa,
      anakKe: int.tryParse(_anakKeCtrl.text) ?? 1,
      jumlahAnak: int.tryParse(_jumlahAnakCtrl.text) ?? 1,
      tanggalPemeriksaan: _tglPemeriksaanCtrl.text.trim(),
      riwayatPemeriksaan: widget.bayiToEdit?.riwayatPemeriksaan ?? const [],
      createdBy: widget.bayiToEdit?.createdBy ?? AuthService.currentUsername,
    );

    // Hitung status awal sebelum tambah/update
    BayiService().hitungStatusAwal(bayi);

    if (widget.bayiToEdit != null) {
      BayiService().updateBayi(bayi);
    } else {
      BayiService().tambahBayi(bayi);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    // Calculate Z-Scores
    final zBBU = BayiService()
        .hitungZScoreBBU(bayi.umurBulan, bayi.beratBadan, bayi.jenisKelamin);
    final zTBU = BayiService()
        .hitungZScoreTBU(bayi.umurBulan, bayi.tinggiBadan, bayi.jenisKelamin);

    await _showResultDialog(context, bayi, zBBU, zTBU);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          widget.bayiToEdit != null
              ? 'Data bayi berhasil diperbarui!'
              : 'Data bayi berhasil ditambahkan!',
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      Navigator.pop(context, true);
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
                    color: AppColors.pinkDark, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.bayiToEdit != null ? 'Edit Bayi' : 'Tambah Bayi',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pinkDark)),
                Text(
                    widget.bayiToEdit != null
                        ? 'Ubah data bayi'
                        : 'Isi data bayi baru',
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionHeader('Tanggal Pemeriksaan', Icons.calendar_today_rounded),
            const SizedBox(height: 12),
            _dateField(_tglPemeriksaanCtrl, 'Pilih Tanggal Pemeriksaan'),
            const SizedBox(height: 24),
            _sectionHeader('Identitas Bayi', Icons.child_care_rounded),
            const SizedBox(height: 12),
            _inputField(_namaBayiCtrl, 'Nama Bayi', 'Masukkan Nama Bayi'),
            const SizedBox(height: 12),
            Text('Tanggal Lahir',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            _dateField(_tglLahirCtrl, 'Masukkan Tanggal Lahir Bayi'),
            const SizedBox(height: 12),
            _jenisKelaminField(),
            const SizedBox(height: 12),
            _numberField(_bbCtrl, 'Berat Badan (gram)', 'Contoh: 9200'),
            const SizedBox(height: 12),
            _numberField(_tbCtrl, 'Tinggi Badan (cm)', 'Contoh: 78.5'),
            const SizedBox(height: 12),
            _numberField(_anakKeCtrl, 'Anak Ke-', 'Contoh: 1'),
            const SizedBox(height: 24),
            _sectionHeader('Identitas Ibu', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _inputField(_namaIbuCtrl, 'Nama Ibu', 'Masukkan Nama Ibu'),
            const SizedBox(height: 12),
            _numberField(_umurIbuCtrl, 'Umur Ibu', 'Contoh: 28'),
            const SizedBox(height: 12),
            _numberField(_noHpCtrl, 'No. HP Ibu', 'Contoh: 081234567890'),
            const SizedBox(height: 12),
            _desaField(),
            const SizedBox(height: 12),
            _pendidikanField(),
            const SizedBox(height: 12),
            _inputField(_pekerjaanCtrl, 'Pekerjaan Ibu', 'Contoh: Guru'),
            const SizedBox(height: 12),
            _numberField(_jumlahAnakCtrl, 'Jumlah Anak', 'Contoh: 2'),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _isLoading ? null : _simpan,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _isLoading
                      ? AppColors.pinkDark.withOpacity(0.5)
                      : AppColors.pinkDark,
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
                          Text(
                              widget.bayiToEdit != null
                                  ? 'Simpan Perubahan'
                                  : 'Tambah Anak',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ]),
                ),
              ),
            ),
            const SizedBox(
                height: 120), // Memberi ruang agar tidak tertutup navbar
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: AppColors.pinkPale,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.pinkDark),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ]);

  Widget _inputField(TextEditingController ctrl, String label, String hint) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(hintText: hint),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      ]);

  Widget _numberField(TextEditingController ctrl, String label, String hint) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 14),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
          ],
          decoration: InputDecoration(hintText: hint),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      ]);

  Widget _dateField(TextEditingController ctrl, String hint) => TextFormField(
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

  Widget _jenisKelaminField() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Jenis Kelamin',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
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
              style:
                  GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
              items: ['Laki-laki', 'Perempuan']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _jenisKelamin = v!),
            ),
          ),
        ),
      ]);

  Widget _pendidikanField() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pendidikan Terakhir',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
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
              value: _pendidikan,
              isExpanded: true,
              style:
                  GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
              items: _pendidikanOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _pendidikan = v!),
            ),
          ),
        ),
      ]);

  Widget _desaField() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Desa',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
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
              value: _desa,
              isExpanded: true,
              style:
                  GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
              items: ['Blang Teue', 'Lain-lain']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _desa = v!),
            ),
          ),
        ),
      ]);

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
              'Hasil Z-Score Bayi',
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
