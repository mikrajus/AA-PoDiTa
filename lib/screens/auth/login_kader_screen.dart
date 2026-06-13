// lib/screens/auth/login_kader_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import 'login_kepala_screen.dart';
import '../kader/dashboard_kader_screen.dart';
import 'daftar_kader_screen.dart';

class LoginKaderScreen extends StatefulWidget {
  const LoginKaderScreen({super.key});
  @override
  State<LoginKaderScreen> createState() => _LoginKaderScreenState();
}

class _LoginKaderScreenState extends State<LoginKaderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthService().login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: AuthRole.kader,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result.success) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardKaderScreen()));
    } else {
      _showSnack(result.message ?? 'Login gagal.');
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ── HEADER STICKY ──
      appBar: AppBar(
        backgroundColor: AppColors.kaderHeader,
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
                    color: AppColors.pinkDark, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Kader Posyandu',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pinkDark)),
                Text('Masuk ke akun Anda',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.pinkDark.withOpacity(0.7))),
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
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.people_alt_rounded,
                      color: AppColors.pinkDark, size: 36),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Username',
                        hint: 'Masukkan username Anda',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _usernameCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Username wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Masukkan password Anda',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _passwordCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Password wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: 'Masuk',
                        gradient: AppColors.kaderGradient,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _login,
                        icon: Icons.login_rounded,
                        textColor: AppColors.pinkDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _divider(),
                const SizedBox(height: 16),
                _SwitchButton(
                  label: 'Masuk sebagai Kepala Puskesmas',
                  icon: Icons.admin_panel_settings_rounded,
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginKepalaScreen())),
                ),
                const SizedBox(height: 12),
                _OutlineBtn(
                  label: 'Daftar Akun Baru',
                  color: AppColors.pinkDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DaftarKaderScreen())),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Row(children: [
        const Expanded(child: Divider(color: AppColors.cardBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('atau',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textLight)),
        ),
        const Expanded(child: Divider(color: AppColors.cardBorder)),
      ]);
}

class _SwitchButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SwitchButton(
      {required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: AppColors.textMedium),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium)),
          ]),
        ),
      );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn(
      {required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.person_add_alt_1_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );
}
