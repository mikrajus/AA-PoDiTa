import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bayi_model.dart';

class BayiService extends ChangeNotifier {
  static final BayiService _instance = BayiService._internal();
  factory BayiService() => _instance;
  BayiService._internal();

  final List<BayiModel> _dataBayi = [];
  final List<Map<String, String>> _dataKader = [
    {
      'nama': 'Siti Aminah',
      'username': 'kader_siti',
      'nik': '3201234567890001',
      'hp': '08123456789'
    },
    {
      'nama': 'Sri Wahyuni',
      'username': 'kader_sri',
      'nik': '3201234567890002',
      'hp': '08123456790'
    },
    {
      'nama': 'Dewi Lestari',
      'username': 'kader_dewi',
      'nik': '3201234567890003',
      'hp': '08123456791'
    },
    {
      'nama': 'Rinaawati',
      'username': 'kader_rina',
      'nik': '3201234567890004',
      'hp': '08123456792'
    },
  ];

  bool get _isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> initLocalDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Kader
      final kaderJson = prefs.getString('cache_kader');
      if (kaderJson != null) {
        final List<dynamic> decoded = json.decode(kaderJson);
        _dataKader.clear();
        for (var k in decoded) {
          _dataKader.add(Map<String, String>.from(k));
        }
      }

      // Load Bayi
      final bayiJson = prefs.getString('cache_bayi');
      if (bayiJson != null) {
        final List<dynamic> decoded = json.decode(bayiJson);
        _dataBayi.clear();
        for (var b in decoded) {
          _dataBayi.add(BayiModel.fromMap(b));
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat database lokal: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final kaderStr = json.encode(_dataKader);
      await prefs.setString('cache_kader', kaderStr);

      final bayiList = _dataBayi.map((b) => b.toMap()).toList();
      final bayiStr = json.encode(bayiList);
      await prefs.setString('cache_bayi', bayiStr);
    } catch (e) {
      debugPrint('Gagal menyimpan ke database lokal: $e');
    }
  }

  Future<void> initFirebaseSync() async {
    if (!_isFirebaseInitialized) return;
    try {
      // Initial fetch to avoid empty state on startup
      final bayiSnapshot =
          await FirebaseFirestore.instance.collection('bayi').get();
      _parseBayiSnapshot(bayiSnapshot);

      final kaderSnapshot =
          await FirebaseFirestore.instance.collection('kader').get();
      _parseKaderSnapshot(kaderSnapshot, isInitial: true);

      // Setup real-time listeners for subsequent changes
      FirebaseFirestore.instance
          .collection('bayi')
          .snapshots()
          .listen((snapshot) {
        _parseBayiSnapshot(snapshot);
        notifyListeners();
      });

      FirebaseFirestore.instance
          .collection('kader')
          .snapshots()
          .listen((snapshot) {
        _parseKaderSnapshot(snapshot, isInitial: false);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Gagal inisialisasi sinkronisasi Firebase: $e');
    }
  }

  Future<void> refreshData() async {
    if (!_isFirebaseInitialized) return;
    try {
      final bayiSnapshot =
          await FirebaseFirestore.instance.collection('bayi').get();
      _parseBayiSnapshot(bayiSnapshot);

      final kaderSnapshot =
          await FirebaseFirestore.instance.collection('kader').get();
      _parseKaderSnapshot(kaderSnapshot, isInitial: false);

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal refresh data Firebase: $e');
    }
  }

  void _parseBayiSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docs.isNotEmpty) {
      _dataBayi.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Helper to migrate old strings to new PMK standards
        String migrateStunting(String s) {
          if (s == 'Sangat Pendek' || s == 'Stunting Berat')
            return 'Sangat Pendek (Stunting)';
          if (s == 'Pendek' || s == 'Stunting')
            return 'Pendek (Risiko Stunting)';
          return s;
        }

        String migrateGizi(String s) {
          if (s == 'BB Normal') return 'BB Normal (Risiko Gemuk)';
          if (s == 'Risiko BB Lebih') return 'Risiko BB Lebih (Gemuk)';
          return s;
        }

        final riwayatList =
            List<Map<String, dynamic>>.from(data['riwayatPemeriksaan'] ?? [])
                .map((r) {
          final mapped = Map<String, dynamic>.from(r);
          if (mapped['statusGizi'] != null)
            mapped['statusGizi'] = migrateGizi(mapped['statusGizi']);
          if (mapped['statusStunting'] != null)
            mapped['statusStunting'] =
                migrateStunting(mapped['statusStunting']);
          return mapped;
        }).toList();

        _dataBayi.add(BayiModel(
          id: doc.id,
          namaBayi: data['namaBayi'] ?? '',
          tanggalLahir: data['tanggalLahir'] ?? '',
          jenisKelamin: data['jenisKelamin'] ?? '',
          beratBadan: double.tryParse(data['beratBadan'].toString()) ?? 0.0,
          tinggiBadan: double.tryParse(data['tinggiBadan'].toString()) ?? 0.0,
          namaIbu: data['namaIbu'] ?? '',
          umurIbu: data['umurIbu'] ?? '',
          pendidikanIbu: data['pendidikanIbu'] ?? '',
          pekerjaanIbu: data['pekerjaanIbu'] ?? '',
          noHpIbu: data['noHpIbu'] ?? '-',
          desa: data['desa'] ?? 'Blang Teue',
          anakKe: int.tryParse(data['anakKe']?.toString() ?? '1') ?? 1,
          jumlahAnak: int.tryParse(data['jumlahAnak'].toString()) ?? 1,
          tanggalPemeriksaan: data['tanggalPemeriksaan'] ?? '',
          statusGizi: migrateGizi(data['statusGizi'] ?? ''),
          statusStunting: migrateStunting(data['statusStunting'] ?? ''),
          riwayatPemeriksaan: riwayatList,
          createdBy: data['createdBy'] ?? '',
        ));
      }
    } else {
      _dataBayi.clear();
    }
    _saveToLocal();
  }

  void _parseKaderSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot,
      {bool isInitial = false}) {
    if (snapshot.docs.isNotEmpty) {
      _dataKader.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _dataKader.add({
          'nama': data['namaLengkap'] ?? data['nama'] ?? '',
          'username': data['username'] ?? '',
          'nik': data['nik'] ?? '',
          'hp': data['nomorHp'] ?? data['hp'] ?? '',
          'password': data['password'] ?? '',
        });
      }
    } else {
      _dataKader.clear();
      if (isInitial) {
        // Seed default kaders to firestore only on initial if absolutely empty
        for (var kader in _dataKader) {
          FirebaseFirestore.instance.collection('kader').add(kader);
        }
      }
    }
    _saveToLocal();
  }

  List<BayiModel> get dataBayi => List.unmodifiable(_dataBayi);
  List<Map<String, String>> get dataKader => List.unmodifiable(_dataKader);
  int get totalBayi => _dataBayi.length;
  int get totalKader => _dataKader.length;

  List<BayiModel> getBayiByKader(String username) {
    return _dataBayi
        .where((b) => b.createdBy == username || b.createdBy.isEmpty)
        .toList();
  }

  int getTotalBayiByKader(String username) {
    return getBayiByKader(username).length;
  }

  int getTotalStuntingByKader(String username) {
    return getBayiByKader(username)
        .where((b) =>
            b.statusStunting.toLowerCase().contains('pendek') ||
            b.statusStunting.toLowerCase().contains('stunting'))
        .length;
  }

  void tambahKader(Map<String, String> kader,
      {bool syncToFirestore = true}) async {
    _dataKader.add(kader);
    _saveToLocal();
    if (syncToFirestore && _isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('kader').add(kader);
      } catch (e) {
        debugPrint("Gagal menyimpan kader ke Firestore: $e");
      }
    }
  }

  int get totalStunting => _dataBayi
      .where((b) =>
          b.statusStunting.toLowerCase().contains('pendek') ||
          b.statusStunting.toLowerCase().contains('stunting'))
      .length;

  void tambahBayi(BayiModel bayi) {
    _dataBayi.add(bayi);
    _saveToLocal();
    if (_isFirebaseInitialized) {
      FirebaseFirestore.instance
          .collection('bayi')
          .doc(bayi.id)
          .set(bayi.toMap())
          .catchError((e) {
        debugPrint("Gagal menyimpan bayi ke Firestore: $e");
      });
    }
  }

  void updateBayi(BayiModel updatedBayi) {
    final idx = _dataBayi.indexWhere((b) => b.id == updatedBayi.id);
    if (idx != -1) {
      _dataBayi[idx] = updatedBayi;
      _saveToLocal();
    }
    if (_isFirebaseInitialized) {
      FirebaseFirestore.instance
          .collection('bayi')
          .doc(updatedBayi.id)
          .set(updatedBayi.toMap())
          .catchError((e) {
        debugPrint("Gagal mengupdate bayi ke Firestore: $e");
      });
    }
  }

  bool hapusBayi(String id) {
    final idx = _dataBayi.indexWhere((b) => b.id == id);
    if (idx == -1) return false;
    _dataBayi.removeAt(idx);
    if (_isFirebaseInitialized) {
      FirebaseFirestore.instance
          .collection('bayi')
          .doc(id)
          .delete()
          .catchError((e) {
        debugPrint("Gagal menghapus bayi dari Firestore: $e");
      });
    }
    return true;
  }

  BayiModel? getBayiById(String id) {
    try {
      return _dataBayi.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Update pemeriksaan & simpan ke riwayat ───────────────────────────────
  void updatePemeriksaan(
    String id, {
    required String tanggalPemeriksaan,
    required double beratBadan,
    required double tinggiBadan,
  }) {
    final idx = _dataBayi.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final bayi = _dataBayi[idx];

    if (bayi.tanggalPemeriksaan.isNotEmpty && bayi.tanggalPemeriksaan != '-') {
      final riwayat = List<Map<String, dynamic>>.from(bayi.riwayatPemeriksaan);
      riwayat.add({
        'tanggal': bayi.tanggalPemeriksaan,
        'beratBadan': bayi.beratBadan,
        'tinggiBadan': bayi.tinggiBadan,
        'statusGizi': bayi.statusGizi,
        'statusStunting': bayi.statusStunting,
      });
      bayi.riwayatPemeriksaan = riwayat;
    }

    bayi.beratBadan = beratBadan;
    bayi.tinggiBadan = tinggiBadan;
    bayi.tanggalPemeriksaan = tanggalPemeriksaan;

    final zBBU = hitungZScoreBBU(bayi.umurBulan, beratBadan, bayi.jenisKelamin);
    final zTBU =
        hitungZScoreTBU(bayi.umurBulan, tinggiBadan, bayi.jenisKelamin);
    bayi.statusGizi = tentukanStatusGiziBBU(zBBU); // BB/U
    bayi.statusStunting = tentukanStatusStuntingTBU(zTBU); // TB/U

    if (_isFirebaseInitialized) {
      FirebaseFirestore.instance
          .collection('bayi')
          .doc(id)
          .set(bayi.toMap())
          .catchError((e) {
        debugPrint("Gagal menyimpan pemeriksaan ke Firestore: $e");
      });
    }
  }

  // ── Hitung z-score pertama kali (saat tambah bayi) ──────────────────────
  void hitungStatusAwal(BayiModel bayi) {
    final zBBU =
        hitungZScoreBBU(bayi.umurBulan, bayi.beratBadan, bayi.jenisKelamin);
    final zTBU =
        hitungZScoreTBU(bayi.umurBulan, bayi.tinggiBadan, bayi.jenisKelamin);
    bayi.statusGizi = tentukanStatusGiziBBU(zBBU);
    bayi.statusStunting = tentukanStatusStuntingTBU(zTBU);
  }

  // ── Kalkulator standalone ─────────────────────────────────────────────────
  Map<String, dynamic> kalkulasiStunting({
    required int umurBulan,
    required double beratBadan,
    required double tinggiBadan,
    required String jenisKelamin,
  }) {
    final zBBU = hitungZScoreBBU(umurBulan, beratBadan, jenisKelamin);
    final zTBU = hitungZScoreTBU(umurBulan, tinggiBadan, jenisKelamin);
    return {
      'zScoreBBU': zBBU,
      'zScoreTBU': zTBU,
      'statusGizi': tentukanStatusGiziBBU(zBBU),
      'statusStunting': tentukanStatusStuntingTBU(zTBU),
    };
  }

  // ── Z-Score BB/U ─────────────────────────────────────────────────────────
  double hitungZScoreBBU(int umurBulan, double bb, String jenisKelamin) {
    final bool isMale = jenisKelamin.toLowerCase().contains('laki');
    final data = isMale ? _tabelBBULakiLaki : _tabelBBUPerempuan;
    final row = data[umurBulan.clamp(0, data.length - 1)];
    final double median = row[0];
    final double sd1Neg = row[1];
    final double sd1Pos = row[2];
    return bb < median
        ? (bb - median) / (median - sd1Neg)
        : (bb - median) / (sd1Pos - median);
  }

  // ── Z-Score TB/U ─────────────────────────────────────────────────────────
  double hitungZScoreTBU(int umurBulan, double tb, String jenisKelamin, {String? caraUkur}) {
    // Kompensasi TB berdasarkan cara ukur (Permenkes)
    double nilaiUkur = tb;
    if (caraUkur != null && caraUkur.isNotEmpty) {
      if (umurBulan < 24 && caraUkur.toLowerCase() == 'berdiri') {
        nilaiUkur += 0.7;
      } else if (umurBulan >= 24 && caraUkur.toLowerCase() == 'telentang') {
        nilaiUkur -= 0.7;
      }
    }

    final bool isMale = jenisKelamin.toLowerCase().contains('laki');
    final data = isMale ? _tabelTBULakiLaki : _tabelTBUPerempuan;
    final row = data[umurBulan.clamp(0, data.length - 1)];
    final double median = row[0];
    final double sd1Neg = row[1];
    final double sd1Pos = row[2];

    return nilaiUkur < median
        ? (nilaiUkur - median) / (median - sd1Neg)
        : (nilaiUkur - median) / (sd1Pos - median);
  }

  // ── Kategori BB/U (PMK No.2 Tahun 2020) ─────────────────────────────────
  String tentukanStatusGiziBBU(double z) {
    if (z < -3.0) return 'Berat badan sangat kurang (severely underweight)';
    if (z < -2.0) return 'Berat badan kurang (underweight)';
    if (z <= 1.0) return 'Berat badan normal';
    return 'Risiko berat badan lebih';
  }

  // ── Kategori TB/U (PMK No.2 Tahun 2020) ─────────────────────────────────
  String tentukanStatusStuntingTBU(double z) {
    if (z < -3.0) return 'Sangat pendek (severely stunted)';
    if (z < -2.0) return 'Pendek (stunted)';
    if (z <= 3.0) return 'Normal';
    return 'Tinggi';
  }

  // ── Expose tabel ─────────────────────────────────────────────────────────
  static List<List<double>> get tabelTBULakiLaki => _tabelTBULakiLaki;
  static List<List<double>> get tabelTBUPerempuan => _tabelTBUPerempuan;
  static List<List<double>> get tabelBBULakiLaki => _tabelBBULakiLaki;
  static List<List<double>> get tabelBBUPerempuan => _tabelBBUPerempuan;

  // ── Helper Curve KMS ─────────────────────────────────────────────────────
  Map<String, double> getZScoreCurve(int umurBulan, bool isMale, bool isBBU) {
    final dataList = isBBU
        ? (isMale ? _tabelBBULakiLaki : _tabelBBUPerempuan)
        : (isMale ? _tabelTBULakiLaki : _tabelTBUPerempuan);

    final row = dataList[umurBulan.clamp(0, dataList.length - 1)];
    final double median = row[0];
    final double sd1Neg = row[1];
    final double sd1Pos = row[2];

    final double posDist = sd1Pos - median;
    final double negDist = median - sd1Neg;

    return {
      '3': median + (3 * posDist),
      '2': median + (2 * posDist),
      '0': median,
      '-2': median - (2 * negDist),
      '-3': median - (3 * negDist),
    };
  }

  // ════════════════════════════════════════════════════════════════════════
  // TABEL BB/U WHO — [median, -1SD, +1SD] per bulan (Laki-laki 0-60 bln)
  // ════════════════════════════════════════════════════════════════════════
  static const List<List<double>> _tabelBBULakiLaki = [
    [3.3, 2.9, 3.9],
    [4.5, 3.9, 5.1],
    [5.6, 4.9, 6.3],
    [6.4, 5.7, 7.2],
    [7.0, 6.2, 7.8],
    [7.5, 6.7, 8.4],
    [7.9, 7.1, 8.8],
    [8.3, 7.4, 9.2],
    [8.6, 7.7, 9.6],
    [8.9, 8.0, 9.9],
    [9.2, 8.2, 10.2],
    [9.4, 8.4, 10.5],
    [9.6, 8.6, 10.8],
    [9.9, 8.8, 11.0],
    [10.1, 9.0, 11.3],
    [10.3, 9.2, 11.5],
    [10.5, 9.4, 11.7],
    [10.7, 9.5, 12.0],
    [10.9, 9.7, 12.2],
    [11.1, 9.9, 12.5],
    [11.3, 10.1, 12.7],
    [11.5, 10.2, 12.9],
    [11.8, 10.4, 13.2],
    [12.0, 10.6, 13.5],
    [12.2, 10.8, 13.7],
    [12.4, 11.0, 14.0],
    [12.5, 11.1, 14.2],
    [12.7, 11.3, 14.4],
    [12.9, 11.4, 14.7],
    [13.1, 11.6, 14.9],
    [13.3, 11.8, 15.1],
    [13.5, 12.0, 15.4],
    [13.7, 12.1, 15.6],
    [13.8, 12.3, 15.8],
    [14.0, 12.4, 16.0],
    [14.2, 12.6, 16.3],
    [14.3, 12.7, 16.5],
    [14.5, 12.9, 16.7],
    [14.7, 13.0, 16.9],
    [14.8, 13.1, 17.1],
    [15.0, 13.3, 17.4],
    [15.2, 13.4, 17.6],
    [15.3, 13.6, 17.8],
    [15.5, 13.7, 18.1],
    [15.7, 13.8, 18.3],
    [15.8, 14.0, 18.5],
    [16.0, 14.1, 18.7],
    [16.2, 14.3, 19.0],
    [16.3, 14.4, 19.2],
    [16.5, 14.5, 19.4],
    [16.6, 14.7, 19.6],
    [16.8, 14.8, 19.9],
    [17.0, 15.0, 20.1],
    [17.1, 15.1, 20.3],
    [17.3, 15.2, 20.6],
    [17.5, 15.4, 20.8],
    [17.6, 15.5, 21.0],
    [17.8, 15.7, 21.3],
    [18.0, 15.8, 21.5],
    [18.1, 16.0, 21.8],
    [18.3, 16.1, 22.0],
  ];

  // TABEL BB/U WHO — Perempuan 0-60 bulan
  static const List<List<double>> _tabelBBUPerempuan = [
    [3.2, 2.8, 3.7],
    [4.2, 3.6, 4.8],
    [5.1, 4.5, 5.8],
    [5.8, 5.2, 6.6],
    [6.4, 5.7, 7.3],
    [6.9, 6.1, 7.8],
    [7.3, 6.5, 8.2],
    [7.6, 6.8, 8.6],
    [7.9, 7.0, 9.0],
    [8.2, 7.3, 9.3],
    [8.5, 7.5, 9.6],
    [8.7, 7.7, 9.9],
    [8.9, 7.9, 10.1],
    [9.2, 8.1, 10.4],
    [9.4, 8.3, 10.6],
    [9.6, 8.5, 10.9],
    [9.8, 8.7, 11.1],
    [10.0, 8.9, 11.4],
    [10.2, 9.0, 11.6],
    [10.4, 9.2, 11.8],
    [10.6, 9.4, 12.1],
    [10.9, 9.6, 12.3],
    [11.1, 9.8, 12.5],
    [11.3, 10.0, 12.8],
    [11.5, 10.2, 13.0],
    [11.7, 10.3, 13.2],
    [11.9, 10.5, 13.5],
    [12.1, 10.7, 13.7],
    [12.3, 10.8, 14.0],
    [12.5, 11.0, 14.2],
    [12.7, 11.2, 14.4],
    [12.9, 11.3, 14.7],
    [13.1, 11.5, 14.9],
    [13.3, 11.7, 15.2],
    [13.5, 11.8, 15.4],
    [13.7, 12.0, 15.7],
    [13.9, 12.2, 15.9],
    [14.0, 12.3, 16.1],
    [14.2, 12.5, 16.4],
    [14.4, 12.6, 16.6],
    [14.6, 12.8, 16.9],
    [14.8, 12.9, 17.1],
    [15.0, 13.1, 17.4],
    [15.2, 13.2, 17.6],
    [15.3, 13.4, 17.9],
    [15.5, 13.5, 18.1],
    [15.7, 13.7, 18.4],
    [15.9, 13.8, 18.6],
    [16.1, 14.0, 18.9],
    [16.3, 14.1, 19.1],
    [16.4, 14.3, 19.4],
    [16.6, 14.4, 19.6],
    [16.8, 14.6, 19.9],
    [17.0, 14.7, 20.1],
    [17.2, 14.9, 20.4],
    [17.3, 15.0, 20.6],
    [17.5, 15.2, 20.9],
    [17.7, 15.3, 21.1],
    [17.9, 15.5, 21.4],
    [18.1, 15.6, 21.7],
    [18.3, 15.8, 22.0],
  ];

  // TABEL TB/U WHO — Laki-laki 0-60 bulan
  static const List<List<double>> _tabelTBULakiLaki = [
    [49.9, 47.4, 52.4],
    [54.7, 52.1, 57.3],
    [58.4, 55.6, 61.2],
    [61.4, 58.5, 64.3],
    [63.9, 60.9, 66.9],
    [65.9, 62.9, 68.9],
    [67.6, 64.5, 70.7],
    [69.2, 66.0, 72.4],
    [70.6, 67.3, 73.9],
    [72.0, 68.7, 75.3],
    [73.3, 69.9, 76.7],
    [74.5, 71.1, 78.0],
    [75.7, 72.2, 79.3],
    [76.9, 73.3, 80.6],
    [78.0, 74.3, 81.8],
    [79.1, 75.4, 82.9],
    [80.2, 76.3, 84.1],
    [81.2, 77.3, 85.2],
    [82.3, 78.3, 86.3],
    [83.2, 79.2, 87.3],
    [84.2, 80.1, 88.3],
    [85.1, 81.0, 89.3],
    [86.0, 81.8, 90.3],
    [86.9, 82.7, 91.2],
    [87.8, 83.5, 92.2],
    [88.8, 84.3, 93.3],
    [89.6, 85.1, 94.2],
    [90.4, 85.8, 95.1],
    [91.2, 86.6, 95.9],
    [92.0, 87.4, 96.7],
    [92.7, 88.1, 97.5],
    [93.5, 88.8, 98.2],
    [94.2, 89.5, 99.0],
    [94.9, 90.2, 99.7],
    [95.6, 90.9, 100.4],
    [96.4, 91.6, 101.1],
    [97.0, 92.2, 101.8],
    [97.6, 92.7, 102.5],
    [98.2, 93.3, 103.2],
    [98.8, 93.8, 103.8],
    [99.4, 94.4, 104.5],
    [100.0, 95.0, 105.1],
    [100.6, 95.5, 105.7],
    [101.1, 96.0, 106.3],
    [101.7, 96.5, 106.9],
    [102.2, 97.0, 107.5],
    [102.8, 97.5, 108.1],
    [103.3, 98.0, 108.7],
    [103.9, 98.4, 109.3],
    [104.4, 98.9, 109.9],
    [104.9, 99.3, 110.5],
    [105.4, 99.8, 111.1],
    [105.9, 100.2, 111.7],
    [106.5, 100.7, 112.3],
    [107.0, 101.1, 112.9],
    [107.5, 101.5, 113.5],
    [108.0, 102.0, 114.1],
    [108.5, 102.4, 114.7],
    [109.0, 102.8, 115.3],
    [109.4, 103.2, 115.8],
    [109.9, 103.6, 116.4],
  ];

  // TABEL TB/U WHO — Perempuan 0-60 bulan
  static const List<List<double>> _tabelTBUPerempuan = [
    [49.1, 46.7, 51.6],
    [53.7, 51.1, 56.3],
    [57.1, 54.4, 59.9],
    [59.8, 57.0, 62.7],
    [62.1, 59.2, 65.0],
    [64.0, 61.1, 66.9],
    [65.7, 62.8, 68.7],
    [67.3, 64.3, 70.3],
    [68.7, 65.7, 71.8],
    [70.1, 67.0, 73.2],
    [71.5, 68.3, 74.7],
    [72.8, 69.6, 76.0],
    [74.0, 70.7, 77.4],
    [75.2, 71.8, 78.7],
    [76.4, 72.9, 79.9],
    [77.5, 73.9, 81.1],
    [78.6, 74.9, 82.3],
    [79.7, 75.9, 83.5],
    [80.7, 76.8, 84.6],
    [81.7, 77.7, 85.7],
    [82.7, 78.6, 86.8],
    [83.7, 79.5, 87.9],
    [84.6, 80.4, 88.9],
    [85.5, 81.2, 89.9],
    [86.4, 82.1, 90.9],
    [87.3, 82.9, 91.8],
    [88.2, 83.7, 92.7],
    [89.0, 84.5, 93.6],
    [89.8, 85.3, 94.5],
    [90.7, 86.1, 95.4],
    [91.4, 86.8, 96.2],
    [92.2, 87.6, 97.1],
    [93.0, 88.3, 97.9],
    [93.8, 89.0, 98.7],
    [94.5, 89.7, 99.5],
    [95.2, 90.4, 100.2],
    [95.9, 91.1, 101.0],
    [96.6, 91.7, 101.7],
    [97.3, 92.4, 102.5],
    [98.0, 93.1, 103.2],
    [98.7, 93.7, 103.9],
    [99.3, 94.3, 104.6],
    [100.0, 94.9, 105.4],
    [100.6, 95.5, 106.1],
    [101.3, 96.1, 106.8],
    [101.9, 96.7, 107.5],
    [102.5, 97.3, 108.2],
    [103.1, 97.9, 108.9],
    [103.8, 98.5, 109.5],
    [104.4, 99.0, 110.2],
    [105.0, 99.6, 110.9],
    [105.6, 100.1, 111.6],
    [106.2, 100.7, 112.2],
    [106.7, 101.2, 112.9],
    [107.3, 101.7, 113.5],
    [107.9, 102.2, 114.2],
    [108.5, 102.7, 114.8],
    [109.0, 103.2, 115.5],
    [109.6, 103.7, 116.1],
    [110.2, 104.2, 116.8],
    [110.7, 104.7, 117.4],
  ];
}
