// lib/screens/kader/dashboard_kader_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../services/bayi_service.dart';
import '../../services/auth_service.dart';
import 'dart:ui' as ui;
import 'dart:async';

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
  String _namaKader = '';
  String _namaPosyandu = 'Posyandu Terpadu';
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
    _namaKader = widget.namaKader;
    _namaPosyandu = widget.namaPosyandu.isNotEmpty
        ? widget.namaPosyandu
        : 'Posyandu Terpadu';
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
    final profile = await AuthService().getCurrentUserProfile(AuthRole.kader);
    if (profile != null && mounted) {
      setState(() {
        _namaKader = profile['namaLengkap'] ?? widget.namaKader;
        _nik = profile['nik'] ?? '';
        _nomorHp = profile['nomorHp'] ?? profile['hp'] ?? '';
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
    final s = status.toLowerCase();
    if (s.contains('sangat pendek')) return const Color(0xFFE53935);
    if (s.contains('pendek')) return Colors.orange;
    return AppColors.success;
  }

  Widget _buildDashboardBody(BayiService svc) {
    return Column(children: [
      _buildHeader(),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => svc.refreshData(),
          color: AppColors.pinkDark,
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
                _buildKalkulatorCard(),
                const SizedBox(height: 16),
                _buildDataBayiSection(svc),
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
      TambahBayiScreen(
        showBackButton: false,
        onSuccess: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const RiwayatKaderScreen(showBackButton: false),
      ProfilKaderScreen(
        namaKader: _namaKader,
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
        gradient: AppColors.kaderGradient,
        image: DecorationImage(
          image: AssetImage('assets/images/header_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(AppColors.pink, BlendMode.multiply),
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
                                color: AppColors.pinkDark)),
                        Text('Posyandu Digital Terpadu',
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.pinkDark.withOpacity(0.7))),
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
                        Text('Keluar',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.pinkDark, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            _namaKader.isEmpty
                                ? 'Kader Posyandu'
                                : 'Halo, $_namaKader',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          const SizedBox(height: 2),
                          Text('Kader Posyandu Terpadu',
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
                                  color: AppColors.pinkDark)),
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

  Widget _buildStatCards(BayiService svc) {
    final currentKader = AuthService.currentUsername;
    final totalBayi = svc.getTotalBayiByKader(currentKader);
    final totalStunting = svc.getTotalStuntingByKader(currentKader);
    return Row(children: [
      Expanded(
          child: _StatCard(
        label: 'Total Bayi',
        value: totalBayi == 0 ? '-' : '$totalBayi',
        icon: Icons.child_care_rounded,
        iconColor: AppColors.blueDark,
        iconBg: AppColors.blue,
      )),
      const SizedBox(width: 12),
      Expanded(
          child: _StatCard(
        label: 'Stunting/Pendek',
        value: totalBayi == 0 ? '-' : '$totalStunting',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFE57373),
        iconBg: const Color(0xFFFFEBEE),
      )),
    ]);
  }

  Widget _buildKalkulatorCard() => GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
              context,
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
            boxShadow: [
              BoxShadow(
                  color: AppColors.blue.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.calculate_rounded,
                  color: AppColors.blueDark, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Kalkulator Stunting',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blueDark)),
                  Text('Analisis pertumbuhan anak',
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

  Widget _buildDataBayiSection(BayiService svc) {
    final currentKader = AuthService.currentUsername;
    final dataBayi = svc.getBayiByKader(currentKader);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Data Bayi',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        if (dataBayi.isNotEmpty)
          GestureDetector(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DataBayiScreen()));
              if (mounted) setState(() {});
            },
            child: Text('Lihat Semua',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
            Text('Belum ada data bayi',
                style: GoogleFonts.poppins(
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
              final result = await Navigator.push(
                  context,
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
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
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
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(bayi.namaBayi,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text('${bayi.umurBulan} bln · Ibu: ${bayi.namaIbu}',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textMedium)),
                    ])),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(bayi.statusStunting).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(bayi.statusStunting,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pinkDark)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.pinkDark, size: 16),
            ]),
          ),
        ),
    ]);
  }

  Widget _buildNavBar() => Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.pinkDark.withOpacity(0.15),
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
                          activeColor: AppColors.pinkDark,
                        ),
                        _NavItem(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Tambah Bayi',
                          index: 1,
                          current: _currentIndex,
                          onTap: _onNavTap,
                          activeColor: AppColors.pinkDark,
                        ),
                        _NavItem(
                          icon: Icons.history_rounded,
                          label: 'Riwayat Bayi',
                          index: 2,
                          current: _currentIndex,
                          onTap: _onNavTap,
                          activeColor: AppColors.pinkDark,
                        ),
                        _NavItem(
                          icon: Icons.person_rounded,
                          label: 'Profil',
                          index: 3,
                          current: _currentIndex,
                          onTap: _onNavTap,
                          activeColor: AppColors.pinkDark,
                        ),
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
            '• Baca angka dan catat hingga satu desimal (contoh: 75,3 cm).\n\n'
            'Usia ≥ 2 Tahun (Tinggi Badan – Posisi Berdiri)\n'
            '• Pasang stadiometer pada dinding atau gunakan stadiometer portable.\n'
            '• Minta anak berdiri tanpa alas kaki dengan punggung, bokong, dan tumit menempel pada papan/dinding.\n'
            '• Posisi kepala menghadap ke depan (garis Frankfurt plane horizontal).\n'
            '• Turunkan headboard hingga menyentuh puncak kepala dengan tekanan ringan.\n'
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
              size: 26, color: active ? activeColor : AppColors.textLight),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? activeColor : AppColors.textLight)),
        ]),
      ),
    );
  }
}
