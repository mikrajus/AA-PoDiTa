import 'lib/services/bayi_service.dart';

void main() {
  final service = BayiService();

  // 1. Ganti nilai-nilai di bawah ini untuk mencoba!
  int umurBulan = 24; // Umur dalam bulan
  double tinggiAtauPanjang = 78.0; // Tinggi/Panjang badan (cm)
  double beratBadan = 10.0; // Berat badan (kg)
  String kelamin = 'Laki-laki'; // 'Laki-laki' atau 'Perempuan'
  String posisiUkur = ''; // 'Berdiri', 'Telentang', atau kosongkan ''

  print('================================================');
  print('          SIMULASI KALKULATOR STUNTING          ');
  print('================================================');
  print('Data Anak:');
  print('- Kelamin  : $kelamin');
  print('- Umur     : $umurBulan bulan');
  print(
      '- TB/PB    : $tinggiAtauPanjang cm (Diukur: ${posisiUkur.isEmpty ? "Sesuai usia" : posisiUkur})');
  print('- BB       : $beratBadan kg\n');

  // Kalkulasi TB/U (Stunting)
  double zTBU = service.hitungZScoreTBU(umurBulan, tinggiAtauPanjang, kelamin,
      caraUkur: posisiUkur);
  String statusTBU = service.tentukanStatusStuntingTBU(zTBU);
  print('>>> HASIL TB/U (Status Stunting):');
  print('Z-Score : ${zTBU.toStringAsFixed(3)} SD');
  print('Status  : $statusTBU\n');

  // Kalkulasi BB/U (Berat Badan)
  double zBBU = service.hitungZScoreBBU(umurBulan, beratBadan, kelamin);
  String statusBBU = service.tentukanStatusGiziBBU(zBBU);
  print('>>> HASIL BB/U (Status Berat Badan):');
  print('Z-Score : ${zBBU.toStringAsFixed(3)} SD');
  print('Status  : $statusBBU\n');

  print('================================================');
}
