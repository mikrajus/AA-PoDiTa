// lib/screens/kepala/dashboard_kepala_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../services/auth_service.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'riwayat_kepala_screen.dart';
import '../../models/bayi_model.dart';
import 'profil_kepala_screen.dart';
import 'monitoring_bayi_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _namaKepala = '';
  String _namaPuskesmas = 'Puskesmas Kecamatan';
  String _nik = '';
  String _nomorHp = '';

  final PageController _edukasiPageController =
      PageController(viewportFraction: 0.9);
  Timer? _edukasiTimer;
  int _edukasiCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    _namaKepala = widget.namaKepala;
    _namaPuskesmas = widget.namaPuskesmas.isNotEmpty
        ? widget.namaPuskesmas
        : 'Puskesmas Kecamatan';
    _loadProfile();

    _edukasiTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      // Ada 5 berita edukasi
      if (_edukasiCurrentPage < 4) {
        _edukasiCurrentPage++;
      } else {
        _edukasiCurrentPage = 0;
      }
      if (_edukasiPageController.hasClients) {
        _edukasiPageController.animateToPage(
          _edukasiCurrentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _edukasiTimer?.cancel();
    _edukasiPageController.dispose();
    super.dispose();
  }

  void _loadProfile() async {
    final profile = await AuthService().getCurrentUserProfile(AuthRole.kepala);
    if (profile != null && mounted) {
      setState(() {
        _namaKepala = profile['namaLengkap'] ?? widget.namaKepala;
        _nik = profile['nik'] ?? '';
        _nomorHp = profile['nomorHp'] ?? '';
      });
    }
  }

  void _onNavTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
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

  Widget _buildDashboardBody(BayiService svc) {
    return Column(children: [
      _buildHeader(),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => svc.refreshData(),
          color: AppColors.blueDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildNewsSection(),
                const SizedBox(height: 16),
                _buildStatCards(svc),
                const SizedBox(height: 16),
                _buildKaderMonitoringCard(svc),
                const SizedBox(height: 16),
                _buildAktivitasTerakhir(svc),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final svc = BayiService();
    final List<Widget> pages = [
      _buildDashboardBody(svc),
      const RiwayatKepalaScreen(showBackButton: false),
      ProfilKepalaScreen(
        namaKepala: _namaKepala,
        namaPuskesmas: _namaPuskesmas,
        nik: _nik,
        nomorHp: _nomorHp,
        showBackButton: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: AnimatedBuilder(
        animation: svc,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SizedBox(
            key: ValueKey<int>(_currentIndex),
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.kepalaGradient,
        image: DecorationImage(
          image: AssetImage('assets/images/header_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(AppColors.blue, BlendMode.multiply),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AA-PoDiTa',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blueDark)),
                        Text('Posyandu Digital Terpadu',
                            style: GoogleFonts.poppins(
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
                        Text('Keluar',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.blueDark, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            _namaKepala.isEmpty
                                ? 'Tenaga Kesehatan'
                                : 'Halo, $_namaKepala',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          const SizedBox(height: 2),
                          Text(_namaPuskesmas,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.textMedium)),
                        ])),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_getHari(),
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textMedium)),
                          Text(_getTanggal(),
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blueDark)),
                        ]),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BayiService svc) => Row(children: [
        Expanded(
            child: GestureDetector(
          onTap: () => _showStatusBottomSheet(svc, true),
          child: _StatCard(
            label: 'Status Gizi Bayi',
            value: svc.totalBayi == 0 ? '-' : '${svc.totalBayi}',
            icon: Icons.monitor_weight_rounded,
            iconColor: AppColors.blueDark,
            iconBg: AppColors.blue,
          ),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: GestureDetector(
          onTap: () => _showStatusBottomSheet(svc, false),
          child: _StatCard(
            label: 'Status Tinggi Bayi',
            value: svc.totalStunting == 0 && svc.totalBayi == 0
                ? '-'
                : '${svc.totalStunting}',
            icon: Icons.health_and_safety_rounded,
            iconColor: const Color(0xFFE57373),
            iconBg: const Color(0xFFFFEBEE),
          ),
        )),
      ]);

  Widget _buildKaderMonitoringCard(BayiService svc) => Row(
        children: [
          const Expanded(flex: 1, child: SizedBox.shrink()),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showDaftarKaderBottomSheet(svc),
              child: _StatCard(
                label: 'Kader Terdaftar',
                value: '${svc.totalKader}',
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.pinkDark,
                iconBg: AppColors.pinkPale,
              ),
            ),
          ),
          const Expanded(flex: 1, child: SizedBox.shrink()),
        ],
      );

  void _showDaftarKaderBottomSheet(BayiService svc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Daftar Kader Posyandu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Berikut adalah kader yang telah terdaftar dalam sistem',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: svc.dataKader.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.divider, height: 1),
                  itemBuilder: (context, index) {
                    final kader = svc.dataKader[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: AppColors.pinkPale,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.pinkDark,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kader['nama'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NIK: ${kader['nik'] ?? '-'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                kader['username'] ?? '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pinkDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                kader['hp'] ?? '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusBottomSheet(BayiService svc, bool isGizi) {
    final listBayi = svc.dataBayi;
    final title = isGizi ? 'Status Gizi Para Bayi' : 'Status Tinggi Para Bayi';
    final desc = isGizi
        ? 'Daftar bayi beserta evaluasi status gizinya (BB/U)'
        : 'Daftar bayi beserta evaluasi status tingginya (TB/U)';

    Color getStatusColor(String s) {
      final text = s.toLowerCase();
      // Periksa istilah spesifik (frasa panjang) terlebih dahulu agar tidak tertimpa istilah umum
      if (text.contains('risiko stunting'))
        return Colors.amber.shade600; // Kuning Tua / Amber
      if (text.contains('risiko gemuk'))
        return Colors.purple.shade300; // Ungu Muda
      // Periksa istilah umum
      if (text.contains('sangat kurang') ||
          text.contains('buruk') ||
          text.contains('sangat pendek') ||
          text.contains('stunting')) return const Color(0xFFE53935); // Merah
      if (text.contains('kurang') || text.contains('pendek'))
        return Colors.orange; // Jingga
      if (text.contains('lebih') || text.contains('gemuk'))
        return Colors.blue.shade500; // Biru
      if (text.contains('baik') || text.contains('normal'))
        return AppColors.success; // Hijau
      return AppColors.textMedium; // Abu-abu untuk Belum Diperiksa atau Kosong
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 16),
              listBayi.isEmpty
                  ? Center(
                      child: Text('Belum ada data bayi.',
                          style:
                              GoogleFonts.poppins(color: AppColors.textMedium)))
                  : Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 250,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: () {
                                    Map<String, int> counts = {};
                                    for (var bayi in listBayi) {
                                      String status = isGizi
                                          ? bayi.statusGizi
                                          : bayi.statusStunting;
                                      if (status.isEmpty || status == '-')
                                        status = 'Belum Diperiksa';
                                      counts[status] =
                                          (counts[status] ?? 0) + 1;
                                    }

                                    List<PieChartSectionData> sections = [];
                                    counts.forEach((status, count) {
                                      final color = getStatusColor(status);
                                      final percentage =
                                          (count / listBayi.length) * 100;
                                      sections.add(PieChartSectionData(
                                        color: color,
                                        value: count.toDouble(),
                                        title:
                                            '${percentage.toStringAsFixed(1)}%',
                                        radius: 60,
                                        titleStyle: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ));
                                    });
                                    return sections;
                                  }(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...() {
                              Map<String, int> counts = {};
                              for (var bayi in listBayi) {
                                String status = isGizi
                                    ? bayi.statusGizi
                                    : bayi.statusStunting;
                                if (status.isEmpty || status == '-')
                                  status = 'Belum Diperiksa';
                                counts[status] = (counts[status] ?? 0) + 1;
                              }
                              return counts.entries.map((e) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: getStatusColor(e.key),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(e.key,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: AppColors.textDark)),
                                      ),
                                      Text('${e.value} bayi',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark)),
                                    ],
                                  ),
                                );
                              }).toList();
                            }(),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAktivitasTerakhir(BayiService svc) {
    if (svc.dataBayi.isEmpty) return const SizedBox.shrink();
    final recent = svc.dataBayi.take(4).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Aktivitas Terakhir',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MonitoringBayiScreen())),
          child: Text('Lihat Semua',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueDark)),
        ),
      ]),
      const SizedBox(height: 10),
      ...recent.map((bayi) {
        final s = bayi.statusStunting.toLowerCase();
        Color statusColor = AppColors.success;
        if (s.contains('sangat pendek')) {
          statusColor = const Color(0xFFE53935);
        } else if (s.contains('pendek')) statusColor = Colors.orange;
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.child_care_rounded,
                  color: AppColors.blueDark, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(bayi.namaBayi,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text(bayi.tanggalPemeriksaan,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textLight)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(bayi.statusStunting,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ]),
        );
      }),
    ]);
  }

  Widget _buildNavBar() => Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueDark.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.85),
              child: SafeArea(
                top: false,
                child: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                            icon: Icons.home_rounded,
                            label: 'Beranda',
                            index: 0,
                            current: _currentIndex,
                            onTap: _onNavTap,
                            activeColor: AppColors.blueDark),
                        _NavItem(
                            icon: Icons.history_rounded,
                            label: 'Riwayat',
                            index: 1,
                            current: _currentIndex,
                            onTap: _onNavTap,
                            activeColor: AppColors.blueDark),
                        _NavItem(
                            icon: Icons.person_rounded,
                            label: 'Profil',
                            index: 2,
                            current: _currentIndex,
                            onTap: _onNavTap,
                            activeColor: AppColors.blueDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildNewsSection() {
    final List<Map<String, dynamic>> newsList = [
      {
        'title': 'Tentang AA-PoDiTa',
        'desc':
            'Penjelasan mengenai aplikasi AA-PoDiTa dan fungsinya dalam pemantauan stunting.',
        'content':
            'AA-PoDiTa (Posyandu Digital Terpadu) adalah inovasi digital berbasis aplikasi seluler yang dirancang untuk mendukung tugas kader Posyandu dan tenaga kesehatan (Kepala Posyandu) dalam mencatat, memantau, dan menganalisis status pertumbuhan balita secara lebih efisien dan akurat, khususnya dalam upaya pencegahan stunting.',
        'icon': Icons.info_outline_rounded,
        'color': AppColors.pinkDark,
        'bgColor': AppColors.pinkPale,
        'link':
            'https://drive.google.com/file/d/1yqMxQpY8EQwcNLHcKxgPiZidFq9Lgg_A/view?usp=sharing',
      },
      {
        'title': 'Menu MPASI',
        'desc':
            'Panduan pemberian menu makanan pendamping ASI yang baik setelah usia 6 bulan.',
        'content':
            'Setelah bayi berusia 6 bulan, kebutuhan energi dan zat gizi mikro tidak lagi tercukupi hanya dari ASI saja. Oleh karena itu, diperlukan Makanan Pendamping ASI (MPASI) yang aman, bergizi, dan diberikan secara tepat waktu.\n\nSilakan tekan tombol di bawah ini untuk melihat dokumen panduan lengkap tentang penyusunan Menu MPASI.',
        'icon': Icons.restaurant_menu_rounded,
        'color': AppColors.blueDark,
        'bgColor': AppColors.bluePale,
        'link':
            'https://drive.google.com/file/d/1fAC0hnTC7AYBFQfSHpuzH94WlZdacL-V/view?usp=sharing',
      },
      {
        'title': 'Asi dan Menyusui',
        'desc':
            'Panduan penting tentang pemberian ASI dan posisi serta teknik menyusui yang benar.',
        'content':
            'Menyusui memberikan nutrisi terbaik untuk bayi sekaligus membangun kedekatan emosional. Dokumen ini menjelaskan mengenai cara pemberian ASI, memerah ASI, serta teknik dan posisi menyusui yang tepat.\n\nSilakan tekan tombol di bawah ini untuk membaca panduan selengkapnya.',
        'icon': Icons.pregnant_woman_rounded,
        'color': const Color(0xFFE53935),
        'bgColor': const Color(0xFFFFEBEE),
        'link':
            'https://drive.google.com/file/d/13YewfPt06ai0JUW1v7fBtlNcnptDjzUB/view?usp=sharing',
      },
      {
        'title': 'Asi Eksklusif',
        'desc':
            'Pentingnya pemberian ASI eksklusif untuk perlindungan dan imunitas anak.',
        'content':
            'ASI Eksklusif sangat penting selama 6 bulan pertama kehidupan anak. ASI eksklusif membantu mencegah stunting, meningkatkan imunitas dari berbagai penyakit infeksi, dan mencukupi seluruh kebutuhan nutrisi awal bayi.\n\nSilakan tekan tombol di bawah ini untuk informasi lengkap mengenai ASI Eksklusif.',
        'icon': Icons.water_drop_rounded,
        'color': Colors.teal,
        'bgColor': const Color(0xFFE0F2F1),
        'link':
            'https://drive.google.com/file/d/107WLI-JsT2GOHXQch-yWR4HP5ZNFN7Uc/view?usp=sharing',
      },
      {
        'title': 'Prosedur Pengukuran Bayi',
        'desc':
            'Standar prosedur akurat dalam mengukur berat badan dan tinggi/panjang badan bayi.',
        'content': 'E.1. Pengukuran Berat Badan (BB)\n'
            'Usia 0‑1 Tahun (Menggunakan Timbangan Bayi Digital)\n'
            '• Letakkan timbangan bayi pada permukaan datar dan keras.\n'
            '• Pastikan angka timbangan menunjukkan 0,0 kg (tekan tombol ON/TARE).\n'
            '• Lepas pakaian tebal dan popok bayi.\n'
            '• Letakkan bayi dengan hati-hati di tengah timbangan.\n'
            '• Baca angka ketika display berhenti bergerak dan catat hingga satu desimal (contoh: 7,4 kg).\n'
            '• Lakukan pengukuran 2 kali, ambil rata-rata jika selisih ≤ 0,1 kg.\n'
            '• Jika selisih > 0,1 kg, lakukan pengukuran ketiga dan ambil dua nilai yang paling berdekatan.\n\n'
            'Usia 1‑5 Tahun (Menggunakan Timbangan Berdiri Digital)\n'
            '• Letakkan timbangan pada lantai keras dan datar.\n'
            '• Kalibrasi: injak timbangan tanpa beban hingga menunjukkan 0,0 kg.\n'
            '• Minta anak berdiri di tengah timbangan dengan posisi tegak, tidak bergerak.\n'
            '• Pastikan anak menghadap ke depan, tidak memegang/bersandar pada apapun.\n'
            '• Baca angka dan catat hingga satu desimal.\n\n'
            'E.2. Pengukuran Tinggi/Panjang Badan (TB/PB)\n'
            'Usia < 2 Tahun (Panjang Badan – Posisi Berbaring)\n'
            '• Letakkan papan ukur (infantometer/stadiometer) pada permukaan datar.\n'
            '• Baringkan bayi telentang di tengah papan ukur.\n'
            '• Kepala bayi dipegang oleh asisten/orang tua agar menyentuh ujung papan (posisi Frankfurt plane: garis imajiner dari sudut mata ke liang telinga tegak lurus papan).\n'
            '• Kader pemegang lutut memastikan kedua kaki lurus, telapak kaki menempel tegak lurus pada papan geser.\n'
            '• Baca angka dan catat.',
        'highlight': '✔ STANDAR AKURASI PENGUKURAN\n'
            'Berat Badan: akurasi 0,1 kg  |  Tinggi/Panjang Badan: akurasi 0,1 cm\n'
            'Jika pengukuran pertama dan kedua berbeda > 0,1 kg (BB) atau > 0,5 cm (TB), WAJIB dilakukan pengukuran ulang.',
        'icon': Icons.straighten_rounded,
        'color': Colors.orange,
        'bgColor': const Color(0xFFFFF3E0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berita & Informasi Edukasi',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _edukasiPageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              _edukasiCurrentPage = index;
            },
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return GestureDetector(
                onTap: () => _showNewsDetail(news),
                child: Container(
                  margin: const EdgeInsets.only(right: 12, bottom: 6, top: 4),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        news['color'] as Color,
                        (news['color'] as Color).withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (news['color'] as Color).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -15,
                        bottom: -15,
                        child: Icon(
                          news['icon'] as IconData,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                news['icon'] as IconData,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    news['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    news['desc'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withValues(alpha: 0.95),
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNewsDetail(Map<String, dynamic> news) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: news['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          news['icon'] as IconData,
                          color: news['color'] as Color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          news['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    news['content'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                  ),
                  if (news['highlight'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Colors.deepOrange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              news['highlight'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (news['link'] != null) ...[
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(news['link']);
                        if (!await launchUrl(url,
                            mode: LaunchMode.externalApplication)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Tidak dapat membuka tautan')),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.blueDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Baca Lebih Lanjut',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: news['link'] != null
                            ? AppColors.white
                            : AppColors.pinkDark,
                        border: news['link'] != null
                            ? Border.all(color: AppColors.cardBorder)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Tutup',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: news['link'] != null
                                ? AppColors.textDark
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getHari() {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    return days[DateTime.now().weekday % 7];
  }

  String _getTanggal() {
    final now = DateTime.now();
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, iconBg;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.iconColor,
      required this.iconBg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.poppins(
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
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.index,
      required this.current,
      required this.onTap,
      required this.activeColor});
  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return InkResponse(
      onTap: () => onTap(index),
      radius: 30,
      splashColor: activeColor.withOpacity(0.1),
      highlightColor: activeColor.withOpacity(0.05),
      child: SizedBox(
        width: 80,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              size: 24, color: active ? activeColor : AppColors.textLight),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? activeColor : AppColors.textLight)),
        ]),
      ),
    );
  }
}
