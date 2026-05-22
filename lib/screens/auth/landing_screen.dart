// lib/screens/auth/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import 'login_kader_screen.dart';
import 'login_kepala_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _goKepala() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const LoginKepalaScreen()));

  void _goKader() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const LoginKaderScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const Spacer(flex: 2),
                  _buildText(),
                  const Spacer(flex: 2),
                  _buildButtons(),
                  const Spacer(flex: 1),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withOpacity(0.35),
              blurRadius: 24, offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.blue.withOpacity(0.25),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          // ── CARA PASANG LOGO ──────────────────────────────────────────
          // 1. Taruh file logo di: assets/images/logo.png
          // 2. Hapus widget _LogoPlaceholder() di bawah
          // 3. Uncomment baris Image.asset di bawah ini:
          //
          // child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          //
          // ─────────────────────────────────────────────────────────────
          child: const _LogoPlaceholder(),
        ),
      ),
    );
  }

  // ── Teks nama & jargon ──────────────────────────────────────────────────────
  Widget _buildText() {
    return Column(children: [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan('AA-',
              style: GoogleFonts.poppins(
                  fontSize: 34, fontWeight: FontWeight.w800,
                  color: AppColors.pinkDark, letterSpacing: -0.5)),
          TextSpan('PoDiTa',
              style: GoogleFonts.poppins(
                  fontSize: 34, fontWeight: FontWeight.w800,
                  color: AppColors.blueDark, letterSpacing: -0.5)),
        ]),
      ),
      const SizedBox(height: 6),
      Text(
        AppConstants.appFullName,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 13, color: AppColors.textMedium,
            fontWeight: FontWeight.w500, height: 1.4),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pinkPale,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.pink),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_rounded, size: 14, color: AppColors.pinkDark),
          const SizedBox(width: 6),
          Text(AppConstants.appJargon,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.pinkDark)),
        ]),
      ),
    ]);
  }

  // ── Tombol ──────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Column(children: [
      _LandingButton(
        label: 'Masuk sebagai Kepala Puskesmas',
        icon: Icons.admin_panel_settings_rounded,
        bgColor: AppColors.blue,
        textColor: AppColors.blueDark,
        onTap: _goKepala,
      ),
      const SizedBox(height: 14),
      _LandingButton(
        label: 'Masuk sebagai Kader',
        icon: Icons.people_alt_rounded,
        bgColor: AppColors.pink,
        textColor: AppColors.pinkDark,
        onTap: _goKader,
      ),
    ]);
  }

  Widget _buildFooter() => Text(
    'Dinas Kesehatan · Sistem Posyandu Digital',
    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
  );
}

// ── Logo placeholder ─────────────────────────────────────────────────────────
class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pink, AppColors.blue],
        ),
      ),
      child: Center(
        child: Text('AA',
            style: GoogleFonts.poppins(
                fontSize: 40, fontWeight: FontWeight.w900,
                color: Colors.white, letterSpacing: -1)),
      ),
    );
  }
}

// ── Tombol landing ───────────────────────────────────────────────────────────
class _LandingButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _LandingButton({
    required this.label, required this.icon,
    required this.bgColor, required this.textColor,
    required this.onTap,
  });

  @override
  State<_LandingButton> createState() => _LandingButtonState();
}

class _LandingButtonState extends State<_LandingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity, height: 58,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.bgColor.withOpacity(0.4),
                blurRadius: 14, offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.textColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(widget.label,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: widget.textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
