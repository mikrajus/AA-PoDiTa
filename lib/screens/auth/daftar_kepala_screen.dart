// lib/screens/auth/daftar_kepala_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class DaftarKepalaScreen extends StatefulWidget {
  const DaftarKepalaScreen({super.key});
  @override
  State<DaftarKepalaScreen> createState() => _DaftarKepalaScreenState();
}

class _DaftarKepalaScreenState extends State<DaftarKepalaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _namaCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nikCtrl.dispose();
    _hpCtrl.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthService().register(
      username: _usernameCtrl.text.trim(),
      namaLengkap: _namaCtrl.text.trim(),
      password: _passwordCtrl.text,
      nik: _nikCtrl.text.trim(),
      nomorHp: _hpCtrl.text.trim(),
      role: AuthRole.kepala,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result.success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message ?? 'Pendaftaran gagal.',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.blue, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.check_rounded,
                color: AppColors.blueDark, size: 34),
          ),
          const SizedBox(height: 16),
          Text('Pendaftaran Berhasil!',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text('Akun Tenaga Kesehatan Anda telah dibuat. Silakan masuk.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textMedium, height: 1.5)),
          const SizedBox(height: 20),
          GradientButton(
            text: 'Masuk Sekarang',
            gradient: AppColors.kepalaGradient,
            textColor: AppColors.blueDark,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ── HEADER STICKY rata kiri ──
      appBar: AppBar(
        backgroundColor: AppColors.kepalaHeader,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Daftar Akun',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blueDark)),
                Text('Tenaga Kesehatan',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.blueDark.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/header_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Expanded(
                      child: Text(
                        'Username diberikan oleh operator. Pastikan username yang Anda masukkan benar.',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.blueDark,
                            height: 1.5),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                const _SectionLabel(
                    label: 'Data Akun', icon: Icons.manage_accounts_rounded),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Username (dari operator)',
                  hint: 'Masukkan username yang diberikan',
                  prefixIcon: Icons.badge_outlined,
                  controller: _usernameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Username wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Nama Lengkap',
                  hint: 'Nama lengkap sesuai identitas',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _namaCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Password',
                  hint: 'Buat password (min. 6 karakter)',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  controller: _passwordCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  controller: _confirmCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi password wajib';
                    }
                    if (v != _passwordCtrl.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const _SectionLabel(
                    label: 'Data Identitas', icon: Icons.credit_card_rounded),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'NIK',
                  hint: '16 digit nomor NIK',
                  prefixIcon: Icons.fingerprint_rounded,
                  controller: _nikCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 16,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'NIK wajib diisi';
                    if (v.length != 16) return 'NIK harus 16 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Nomor HP',
                  hint: 'Contoh: 08123456789',
                  prefixIcon: Icons.phone_android_rounded,
                  controller: _hpCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 13,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nomor HP wajib diisi';
                    if (v.length < 10) return 'Nomor HP tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                GradientButton(
                  text: 'Daftar Sekarang',
                  gradient: AppColors.kepalaGradient,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _daftar,
                  icon: Icons.how_to_reg_rounded,
                  textColor: AppColors.blueDark,
                ),
                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 13),
                        children: const [
                          TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(color: AppColors.textMedium)),
                          TextSpan(
                              text: 'Masuk',
                              style: TextStyle(
                                  color: AppColors.blueDark,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: AppColors.textMedium),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 0.4)),
      ]);
}
