// lib/screens/kepala/dashboard_kepala_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../models/bayi_model.dart';
import 'riwayat_kepala_screen.dart';
import 'profil_kepala_screen.dart';
import 'monitoring_bayi_screen.dart';

class DashboardKepalaScreen extends StatefulWidget {
  final String namaKepala;
  final String namaPuskesmas;

  const DashboardKepalaScreen({
    super.key,
    this.namaKepala = '',
    this.namaPuskesmas = '',
  });

  @override
  State<DashboardKepalaScreen> createState() => _DashboardKepalaScreenState();
}

class _DashboardKepalaScreenState extends State<DashboardKepalaScreen> {
  int _currentIndex = 0;

  void _onNavTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    if (i == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RiwayatKepalaScreen()))
          .then((_) => setState(() => _currentIndex = 0));
    } else if (i == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProfilKepalaScreen(
            namaKepala: widget.namaKepala,
            namaPuskesmas: widget.namaPuskesmas,
          ))).then((_) => setState(() => _currentIndex = 0));
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin keluar dari akun?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Keluar',
                style: GoogleFonts.poppins(
                    color: AppColors.blueDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = BayiService();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildStatCards(svc),
                const SizedBox(height: 16),
                _buildMonitoringCard(),
                const SizedBox(height: 16),
                _buildRingkasanStunting(svc),
                const SizedBox(height: 16),
                _buildAktivitasTerakhir(svc),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ]),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.kepalaHeader,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(children: [
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('AA',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        color: AppColors.blueDark))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AA-PoDiTa', style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.blueDark)),
                Text('Posyandu Digital Terpadu', style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.blueDark.withOpacity(0.7))),
              ]),
              const Spacer(),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.logout_rounded,
                        color: AppColors.blueDark, size: 16),
                    const SizedBox(width: 5),
                    Text('Keluar', style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.blueDark)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.blueDark, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    widget.namaKepala.isEmpty
                        ? 'Kepala Puskesmas'
                        : 'Halo, ${widget.namaKepala}',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(widget.namaPuskesmas.isEmpty
                      ? '-' : widget.namaPuskesmas,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMedium)),
                  Text('Kepala Puskesmas', style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.blueDark)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_getHari(), style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textMedium)),
                  Text(_getTanggal(), style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.blueDark)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatCards(BayiService svc) => Row(children: [
    Expanded(child: _StatCard(
      label: 'Total Bayi',
      value: svc.totalBayi == 0 ? '-' : '${svc.totalBayi}',
      icon: Icons.child_care_rounded,
      iconColor: AppColors.blueDark, iconBg: AppColors.blue,
    )),
    const SizedBox(width: 12),
    Expanded(child: _StatCard(
      label: 'Bayi Stunting',
      value: svc.totalStunting == 0 && svc.totalBayi == 0
          ? '-' : '${svc.totalStunting}',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFE57373),
      iconBg: const Color(0xFFFFEBEE),
    )),
  ]);

  Widget _buildMonitoringCard() => GestureDetector(
    onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const MonitoringBayiScreen())),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: AppColors.blue.withOpacity(0.4),
            blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.monitor_heart_rounded,
              color: AppColors.blueDark, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Monitoring Bayi', style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.blueDark)),
          Text('Lihat semua data pertumbuhan',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.blueDark.withOpacity(0.7))),
        ])),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.blueDark, size: 14),
        ),
      ]),
    ),
  );

  Widget _buildRingkasanStunting(BayiService svc) {
    if (svc.totalBayi == 0) return const SizedBox.shrink();
    final data = svc.dataBayi;
    final normal = data.where((b) => b.statusStunting == 'Normal').length;
    final risiko = data.where((b) => b.statusStunting == 'Risiko Stunting').length;
    final stunting = data.where((b) => b.statusStunting == 'Stunting').length;
    final berat = data.where((b) => b.statusStunting == 'Stunting Berat').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ringkasan Status Gizi', style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: AppColors.textDark)),
        const SizedBox(height: 14),
        _ringkasanRow('Normal', normal, svc.totalBayi, AppColors.success),
        const SizedBox(height: 8),
        _ringkasanRow('Risiko Stunting', risiko, svc.totalBayi, Colors.orange),
        const SizedBox(height: 8),
        _ringkasanRow('Stunting', stunting, svc.totalBayi,
            const Color(0xFFE57373)),
        const SizedBox(height: 8),
        _ringkasanRow('Stunting Berat', berat, svc.totalBayi,
            const Color(0xFFE53935)),
      ]),
    );
  }

  Widget _ringkasanRow(String label, int count, int total, Color color) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: GoogleFonts.poppins(
            fontSize: 12, color: AppColors.textMedium)),
        const Spacer(),
        Text('$count bayi', style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ),
    ]);
  }

  Widget _buildAktivitasTerakhir(BayiService svc) {
    if (svc.dataBayi.isEmpty) return const SizedBox.shrink();
    final recent = svc.dataBayi.take(4).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Aktivitas Terakhir', style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.textDark)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MonitoringBayiScreen())),
          child: Text('Lihat Semua', style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.blueDark)),
        ),
      ]),
      const SizedBox(height: 10),
      ...recent.map((bayi) {
        final isStunting =
            bayi.statusStunting.toLowerCase().contains('stunting');
        final statusColor =
            isStunting ? const Color(0xFFE57373) : AppColors.success;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.child_care_rounded,
                  color: AppColors.blueDark, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bayi.namaBayi, style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
              Text(bayi.tanggalPemeriksaan, style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textLight)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(bayi.statusStunting, style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: statusColor)),
            ),
          ]),
        );
      }),
    ]);
  }

  Widget _buildNavBar() => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 16, offset: const Offset(0, -4))],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Beranda',
                index: 0, current: _currentIndex,
                onTap: _onNavTap, activeColor: AppColors.blueDark),
            _NavItem(icon: Icons.history_rounded, label: 'Riwayat',
                index: 1, current: _currentIndex,
                onTap: _onNavTap, activeColor: AppColors.blueDark),
            _NavItem(icon: Icons.person_rounded, label: 'Profil',
                index: 2, current: _currentIndex,
                onTap: _onNavTap, activeColor: AppColors.blueDark),
          ],
        ),
      ),
    ),
  );

  String _getHari() {
    final days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    return days[DateTime.now().weekday % 7];
  }

  String _getTanggal() {
    final now = DateTime.now();
    final months = ['','Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, iconBg;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.iconColor, required this.iconBg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      const SizedBox(height: 12),
      Text(value, style: GoogleFonts.poppins(
          fontSize: 26, fontWeight: FontWeight.w800,
          color: AppColors.textDark)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.poppins(
          fontSize: 12, color: AppColors.textMedium)),
    ]),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final Function(int) onTap;
  final Color activeColor;
  const _NavItem({required this.icon, required this.label,
      required this.index, required this.current,
      required this.onTap, required this.activeColor});
  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24,
              color: active ? activeColor : AppColors.textLight),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? activeColor : AppColors.textLight)),
        ]),
      ),
    );
  }
}
