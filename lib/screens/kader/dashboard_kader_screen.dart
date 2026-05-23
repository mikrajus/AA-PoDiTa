// lib/screens/kader/dashboard_kader_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../models/bayi_model.dart';
import 'riwayat_kader_screen.dart';
import 'profil_kader_screen.dart';
import 'tambah_bayi_screen.dart';
import 'kalkulator_stunting_screen.dart';
import 'data_bayi_screen.dart';
import 'detail_bayi_screen.dart';

class DashboardKaderScreen extends StatefulWidget {
  final String namaKader;
  final String namaPosyandu;
  final String namaPuskesmas;

  const DashboardKaderScreen({
    super.key,
    this.namaKader = '',
    this.namaPosyandu = '',
    this.namaPuskesmas = '',
  });

  @override
  State<DashboardKaderScreen> createState() => _DashboardKaderScreenState();
}

class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
  int _currentIndex = 0;

  // Navigasi dengan refresh state setelah kembali
  void _onNavTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    if (i == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RiwayatKaderScreen()))
          .then((_) => setState(() => _currentIndex = 0));
    } else if (i == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProfilKaderScreen(
            namaKader: widget.namaKader,
            namaPosyandu: widget.namaPosyandu,
            namaPuskesmas: widget.namaPuskesmas,
          ))).then((_) => setState(() => _currentIndex = 0));
    }
  }

  Future<void> _tambahBayi() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const TambahBayiScreen()));
    // Refresh dashboard agar Total Bayi langsung update
    if (result == true && mounted) setState(() {});
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
                style: GoogleFonts.poppins(color: AppColors.textMedium))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Keluar',
                style: GoogleFonts.poppins(
                    color: AppColors.pinkDark, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('sangat')) return const Color(0xFFE53935);
    if (status.toLowerCase().contains('pendek')) return const Color(0xFFE57373);
    if (status.toLowerCase().contains('risiko')) return Colors.orange;
    return AppColors.success;
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
                _buildKalkulatorCard(),
                const SizedBox(height: 16),
                _buildDataBayiSection(svc),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ]),
      bottomNavigationBar: _buildNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahBayi,
        backgroundColor: AppColors.pinkDark,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.kaderHeader,
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
                child: Center(child: Text('AA', style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: AppColors.pinkDark))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AA-PoDiTa', style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.pinkDark)),
                Text('Posyandu Digital Terpadu', style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.pinkDark.withOpacity(0.7))),
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
                        color: AppColors.pinkDark, size: 16),
                    const SizedBox(width: 5),
                    Text('Keluar', style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.pinkDark)),
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
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.pinkDark, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    widget.namaKader.isEmpty
                        ? 'Kader Posyandu'
                        : 'Halo, ${widget.namaKader}',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(widget.namaPosyandu.isEmpty ? '-' : widget.namaPosyandu,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMedium)),
                  Text(widget.namaPuskesmas.isEmpty ? '-' : widget.namaPuskesmas,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMedium)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_getHari(), style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textMedium)),
                  Text(_getTanggal(), style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.pinkDark)),
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
      iconColor: AppColors.blueDark,
      iconBg: AppColors.blue,
    )),
    const SizedBox(width: 12),
    Expanded(child: _StatCard(
      label: 'Stunting/Pendek',
      value: svc.totalBayi == 0 ? '-' : '${svc.totalStunting}',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFE57373),
      iconBg: const Color(0xFFFFEBEE),
    )),
  ]);

  Widget _buildKalkulatorCard() => GestureDetector(
    onTap: () async {
      final result = await Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => const KalkulatorStuntingScreen()));
      // Refresh jika kalkulator menyimpan pemeriksaan baru
      if (result == true && mounted) setState(() {});
    },
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
          child: const Icon(Icons.calculate_rounded,
              color: AppColors.blueDark, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kalkulator Stunting', style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.blueDark)),
          Text('Analisis pertumbuhan anak', style: GoogleFonts.poppins(
              fontSize: 12, color: AppColors.blueDark.withOpacity(0.7))),
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

  Widget _buildDataBayiSection(BayiService svc) {
    final dataBayi = svc.dataBayi;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Data Bayi', style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.textDark)),
        if (dataBayi.isNotEmpty)
          GestureDetector(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DataBayiScreen()));
              if (mounted) setState(() {});
            },
            child: Text('Lihat Semua', style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.pinkDark)),
          ),
      ]),
      const SizedBox(height: 10),
      if (dataBayi.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(children: [
            const Icon(Icons.folder_open_rounded,
                size: 40, color: AppColors.textLight),
            const SizedBox(height: 8),
            Text('Belum ada data bayi', style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textMedium)),
            const SizedBox(height: 4),
            Text('Tekan tombol + untuk menambah',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight)),
          ]),
        )
      else
        // Tampil maksimal 3 bayi di dashboard
        ...dataBayi.take(3).map((bayi) {
          final isLaki = bayi.jenisKelamin.toLowerCase().contains('laki');
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => DetailBayiScreen(bayi: bayi)));
              if (result == true && mounted) setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: isLaki ? AppColors.blue : AppColors.pink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLaki ? Icons.boy_rounded : Icons.girl_rounded,
                    color: isLaki ? AppColors.blueDark : AppColors.pinkDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bayi.namaBayi, style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
                  Text('${bayi.umurBulan} bln · Ibu: ${bayi.namaIbu}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMedium)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(bayi.statusStunting).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(bayi.statusStunting,
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: _statusColor(bayi.statusStunting))),
                ),
              ]),
            ),
          );
        }),
      // Tombol lihat semua kalau lebih dari 3
      if (dataBayi.length > 3)
        GestureDetector(
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DataBayiScreen()));
            if (mounted) setState(() {});
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.pinkPale,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pink),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Lihat ${dataBayi.length - 3} bayi lainnya',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.pinkDark)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.pinkDark, size: 16),
            ]),
          ),
        ),
    ]);
  }

  Widget _buildNavBar() => BottomAppBar(
    color: AppColors.white,
    elevation: 8,
    notchMargin: 8,
    shape: const CircularNotchedRectangle(),
    child: SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Beranda',
              index: 0, current: _currentIndex,
              onTap: _onNavTap, activeColor: AppColors.pinkDark),
          _NavItem(icon: Icons.history_rounded, label: 'Riwayat',
              index: 1, current: _currentIndex,
              onTap: _onNavTap, activeColor: AppColors.pinkDark),
          const SizedBox(width: 48),
          _NavItem(icon: Icons.person_rounded, label: 'Profil',
              index: 2, current: _currentIndex,
              onTap: _onNavTap, activeColor: AppColors.pinkDark),
        ],
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
        width: 72,
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
