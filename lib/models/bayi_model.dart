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
  final int jumlahAnak;
  String tanggalPemeriksaan;
  String statusGizi;
  String statusStunting;
  List<Map<String, dynamic>> riwayatPemeriksaan;

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
    required this.jumlahAnak,
    required this.tanggalPemeriksaan,
    this.statusGizi = '-',
    this.statusStunting = '-',
    this.riwayatPemeriksaan = const [],
  });

  // Hitung umur dalam bulan dari tanggal lahir
  int get umurBulan {
    try {
      final parts = tanggalLahir.split('-');
      if (parts.length != 3) return 0;
      final lahir = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      return (now.year - lahir.year) * 12 + (now.month - lahir.month);
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
    'jumlahAnak': jumlahAnak,
    'tanggalPemeriksaan': tanggalPemeriksaan,
    'statusGizi': statusGizi,
    'statusStunting': statusStunting,
    'riwayatPemeriksaan': riwayatPemeriksaan,
  };
}
