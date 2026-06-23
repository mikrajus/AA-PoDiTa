// lib/models/bayi_model.dart

class BayiModel {
  final String id;
  final String namaBayi;
  final String tanggalLahir;
  final String jenisKelamin;
  double beratBadan;
  double tinggiBadan;
  final String namaIbu;
  final String umurIbu;
  final String pendidikanIbu;
  final String pekerjaanIbu;
  final String noHpIbu;
  final String desa;
  final int anakKe;
  final int jumlahAnak;
  String tanggalPemeriksaan;
  String statusGizi;
  String statusStunting;
  List<Map<String, dynamic>> riwayatPemeriksaan;
  final String createdBy;

  BayiModel({
    required this.id,
    required this.namaBayi,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.namaIbu,
    required this.umurIbu,
    required this.pendidikanIbu,
    required this.pekerjaanIbu,
    required this.noHpIbu,
    required this.desa,
    required this.anakKe,
    required this.jumlahAnak,
    required this.tanggalPemeriksaan,
    this.statusGizi = '-',
    this.statusStunting = '-',
    this.riwayatPemeriksaan = const [],
    this.createdBy = '',
  });

  // Hitung umur dalam bulan dari tanggal lahir
  int get umurBulan {
    try {
      final parts = tanggalLahir.split('-');
      if (parts.length != 3) return 0;
      final lahir = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

      DateTime targetDate;
      if (tanggalPemeriksaan.isNotEmpty && tanggalPemeriksaan != '-') {
        final pemParts = tanggalPemeriksaan.split('-');
        if (pemParts.length == 3) {
          targetDate = DateTime(int.parse(pemParts[0]), int.parse(pemParts[1]),
              int.parse(pemParts[2]));
        } else {
          targetDate = DateTime.now();
        }
      } else {
        targetDate = DateTime.now();
      }

      int months = (targetDate.year - lahir.year) * 12 + (targetDate.month - lahir.month);
      if (targetDate.day < lahir.day) {
        months--;
      }
      return months < 0 ? 0 : months;
    } catch (_) {
      return 0;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'namaBayi': namaBayi,
        'tanggalLahir': tanggalLahir,
        'jenisKelamin': jenisKelamin,
        'beratBadan': beratBadan,
        'tinggiBadan': tinggiBadan,
        'namaIbu': namaIbu,
        'umurIbu': umurIbu,
        'pendidikanIbu': pendidikanIbu,
        'pekerjaanIbu': pekerjaanIbu,
        'noHpIbu': noHpIbu,
        'desa': desa,
        'anakKe': anakKe,
        'jumlahAnak': jumlahAnak,
        'tanggalPemeriksaan': tanggalPemeriksaan,
        'statusGizi': statusGizi,
        'statusStunting': statusStunting,
        'riwayatPemeriksaan': riwayatPemeriksaan,
        'createdBy': createdBy,
      };

  factory BayiModel.fromMap(Map<String, dynamic> data) {
    return BayiModel(
      id: data['id']?.toString() ?? '',
      namaBayi: data['namaBayi'] ?? '',
      tanggalLahir: data['tanggalLahir'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? '',
      beratBadan: double.tryParse(data['beratBadan']?.toString() ?? '0') ?? 0.0,
      tinggiBadan:
          double.tryParse(data['tinggiBadan']?.toString() ?? '0') ?? 0.0,
      namaIbu: data['namaIbu'] ?? '',
      umurIbu: data['umurIbu'] ?? '',
      pendidikanIbu: data['pendidikanIbu'] ?? '',
      pekerjaanIbu: data['pekerjaanIbu'] ?? '',
      noHpIbu: data['noHpIbu'] ?? '-',
      desa: data['desa'] ?? 'Blang Teue',
      anakKe: int.tryParse(data['anakKe']?.toString() ?? '1') ?? 1,
      jumlahAnak: int.tryParse(data['jumlahAnak']?.toString() ?? '1') ?? 1,
      tanggalPemeriksaan: data['tanggalPemeriksaan'] ?? '',
      statusGizi: data['statusGizi'] ?? '-',
      statusStunting: data['statusStunting'] ?? '-',
      riwayatPemeriksaan:
          List<Map<String, dynamic>>.from(data['riwayatPemeriksaan'] ?? []),
      createdBy: data['createdBy'] ?? '',
    );
  }
}
