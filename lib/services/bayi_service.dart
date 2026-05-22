// lib/services/bayi_service.dart
// Data disimpan sementara di memori (cache)

import '../models/bayi_model.dart';

class BayiService {
  static final BayiService _instance = BayiService._internal();
  factory BayiService() => _instance;
  BayiService._internal();

  final List<BayiModel> _dataBayi = [];

  List<BayiModel> get dataBayi => List.unmodifiable(_dataBayi);

  int get totalBayi => _dataBayi.length;

  int get totalStunting => _dataBayi
      .where((b) => b.statusStunting.toLowerCase().contains('stunting'))
      .length;

  void tambahBayi(BayiModel bayi) {
    _dataBayi.add(bayi);
  }

  void updatePemeriksaan(String id, {
    required String tanggalPemeriksaan,
    required double beratBadan,
    required double tinggiBadan,
  }) {
    final idx = _dataBayi.indexWhere((b) => b.id == id);
    if (idx == -1) return;

    final bayi = _dataBayi[idx];

    // Simpan riwayat lama
    final riwayat = List<Map<String, dynamic>>.from(bayi.riwayatPemeriksaan);
    riwayat.add({
      'tanggal': bayi.tanggalPemeriksaan,
      'beratBadan': bayi.beratBadan,
      'tinggiBadan': bayi.tinggiBadan,
      'statusGizi': bayi.statusGizi,
      'statusStunting': bayi.statusStunting,
    });

    // Hitung status baru
    final zScore = _hitungZScore(bayi.umurBulan, tinggiBadan, bayi.jenisKelamin);
    final statusGizi = _tentukanStatusGizi(zScore);
    final statusStunting = _tentukanStatusStunting(zScore);

    bayi.beratBadan = beratBadan;
    bayi.tinggiBadan = tinggiBadan;
    bayi.tanggalPemeriksaan = tanggalPemeriksaan;
    bayi.statusGizi = statusGizi;
    bayi.statusStunting = statusStunting;
    bayi.riwayatPemeriksaan = riwayat;
  }

  BayiModel? getBayiById(String id) {
    try {
      return _dataBayi.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Z-Score TB/U (WHO PMK No.2 Tahun 2020) ───────────────────────────────
  double _hitungZScore(int umurBulan, double tb, String jenisKelamin) {
    // Tabel median & -1SD berdasarkan umur & jenis kelamin (sampel data WHO)
    final bool isMale = jenisKelamin.toLowerCase().contains('laki');
    final data = isMale ? _tabelLakiLaki : _tabelPerempuan;

    if (umurBulan < 0 || umurBulan > 60) return 0;

    final row = data[umurBulan.clamp(0, data.length - 1)];
    final double median = row[0];
    final double sd1Neg = row[1]; // -1SD
    final double sd1Pos = row[2]; // +1SD

    if (tb < median) {
      return (tb - median) / (median - sd1Neg);
    } else {
      return (tb - median) / (sd1Pos - median);
    }
  }

  String _tentukanStatusGizi(double z) {
    if (z < -3) return 'Sangat Pendek';
    if (z < -2) return 'Pendek';
    if (z <= 2) return 'Normal';
    return 'Tinggi';
  }

  String _tentukanStatusStunting(double z) {
    if (z < -3) return 'Stunting Berat';
    if (z < -2) return 'Stunting';
    if (z < -1) return 'Risiko Stunting';
    return 'Normal';
  }

  // Tabel TB/U Laki-laki WHO: [median, -1SD, +1SD] per bulan (0-60 bulan)
  static List<List<double>> get tabelLakiLaki => _tabelLakiLaki;
  static const List<List<double>> _tabelLakiLaki = [
    [49.9, 47.4, 52.4], // 0
    [54.7, 52.1, 57.3], // 1
    [58.4, 55.6, 61.2], // 2
    [61.4, 58.5, 64.3], // 3
    [63.9, 60.9, 66.9], // 4
    [65.9, 62.9, 68.9], // 5
    [67.6, 64.5, 70.7], // 6
    [69.2, 66.0, 72.4], // 7
    [70.6, 67.3, 73.9], // 8
    [72.0, 68.7, 75.3], // 9
    [73.3, 69.9, 76.7], // 10
    [74.5, 71.1, 78.0], // 11
    [75.7, 72.2, 79.3], // 12
    [76.9, 73.3, 80.6], // 13
    [78.0, 74.3, 81.8], // 14
    [79.1, 75.4, 82.9], // 15
    [80.2, 76.3, 84.1], // 16
    [81.2, 77.3, 85.2], // 17
    [82.3, 78.3, 86.3], // 18
    [83.2, 79.2, 87.3], // 19
    [84.2, 80.1, 88.3], // 20
    [85.1, 81.0, 89.3], // 21
    [86.0, 81.8, 90.3], // 22
    [86.9, 82.7, 91.2], // 23
    [87.8, 83.5, 92.2], // 24
    [88.8, 84.3, 93.3], // 25 ← contoh kasus: 87cm = -0.56 SD
    [89.6, 85.1, 94.2], // 26
    [90.4, 85.8, 95.1], // 27
    [91.2, 86.6, 95.9], // 28
    [92.0, 87.4, 96.7], // 29
    [92.7, 88.1, 97.5], // 30
    [93.5, 88.8, 98.2], // 31
    [94.2, 89.5, 99.0], // 32
    [94.9, 90.2, 99.7], // 33
    [95.6, 90.9, 100.4], // 34
    [96.4, 91.6, 101.1], // 35
    [97.0, 92.2, 101.8], // 36
    [97.6, 92.7, 102.5], // 37
    [98.2, 93.3, 103.2], // 38
    [98.8, 93.8, 103.8], // 39
    [99.4, 94.4, 104.5], // 40
    [100.0, 95.0, 105.1], // 41
    [100.6, 95.5, 105.7], // 42
    [101.1, 96.0, 106.3], // 43
    [101.7, 96.5, 106.9], // 44
    [102.2, 97.0, 107.5], // 45
    [102.8, 97.5, 108.1], // 46
    [103.3, 98.0, 108.7], // 47
    [103.9, 98.4, 109.3], // 48
    [104.4, 98.9, 109.9], // 49
    [104.9, 99.3, 110.5], // 50
    [105.4, 99.8, 111.1], // 51
    [105.9, 100.2, 111.7], // 52
    [106.5, 100.7, 112.3], // 53
    [107.0, 101.1, 112.9], // 54
    [107.5, 101.5, 113.5], // 55
    [108.0, 102.0, 114.1], // 56
    [108.5, 102.4, 114.7], // 57
    [109.0, 102.8, 115.3], // 58
    [109.4, 103.2, 115.8], // 59
    [109.9, 103.6, 116.4], // 60
  ];

  static List<List<double>> get tabelPerempuan => _tabelPerempuan;
  static const List<List<double>> _tabelPerempuan = [
    [49.1, 46.7, 51.6], // 0
    [53.7, 51.1, 56.3], // 1
    [57.1, 54.4, 59.9], // 2
    [59.8, 57.0, 62.7], // 3
    [62.1, 59.2, 65.0], // 4
    [64.0, 61.1, 66.9], // 5
    [65.7, 62.8, 68.7], // 6
    [67.3, 64.3, 70.3], // 7
    [68.7, 65.7, 71.8], // 8
    [70.1, 67.0, 73.2], // 9
    [71.5, 68.3, 74.7], // 10
    [72.8, 69.6, 76.0], // 11
    [74.0, 70.7, 77.4], // 12
    [75.2, 71.8, 78.7], // 13
    [76.4, 72.9, 79.9], // 14
    [77.5, 73.9, 81.1], // 15
    [78.6, 74.9, 82.3], // 16
    [79.7, 75.9, 83.5], // 17
    [80.7, 76.8, 84.6], // 18
    [81.7, 77.7, 85.7], // 19
    [82.7, 78.6, 86.8], // 20
    [83.7, 79.5, 87.9], // 21
    [84.6, 80.4, 88.9], // 22
    [85.5, 81.2, 89.9], // 23
    [86.4, 82.1, 90.9], // 24
    [87.3, 82.9, 91.8], // 25
    [88.2, 83.7, 92.7], // 26
    [89.0, 84.5, 93.6], // 27
    [89.8, 85.3, 94.5], // 28
    [90.7, 86.1, 95.4], // 29
    [91.4, 86.8, 96.2], // 30
    [92.2, 87.6, 97.1], // 31
    [93.0, 88.3, 97.9], // 32
    [93.8, 89.0, 98.7], // 33
    [94.5, 89.7, 99.5], // 34
    [95.2, 90.4, 100.2], // 35
    [95.9, 91.1, 101.0], // 36
    [96.6, 91.7, 101.7], // 37
    [97.3, 92.4, 102.5], // 38
    [98.0, 93.1, 103.2], // 39
    [98.7, 93.7, 103.9], // 40
    [99.3, 94.3, 104.6], // 41
    [100.0, 94.9, 105.4], // 42
    [100.6, 95.5, 106.1], // 43
    [101.3, 96.1, 106.8], // 44
    [101.9, 96.7, 107.5], // 45
    [102.5, 97.3, 108.2], // 46
    [103.1, 97.9, 108.9], // 47
    [103.8, 98.5, 109.5], // 48
    [104.4, 99.0, 110.2], // 49
    [105.0, 99.6, 110.9], // 50
    [105.6, 100.1, 111.6], // 51
    [106.2, 100.7, 112.2], // 52
    [106.7, 101.2, 112.9], // 53
    [107.3, 101.7, 113.5], // 54
    [107.9, 102.2, 114.2], // 55
    [108.5, 102.7, 114.8], // 56
    [109.0, 103.2, 115.5], // 57
    [109.6, 103.7, 116.1], // 58
    [110.2, 104.2, 116.8], // 59
    [110.7, 104.7, 117.4], // 60
  ];
}
