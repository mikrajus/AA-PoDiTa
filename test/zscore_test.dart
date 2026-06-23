import 'package:flutter_test/flutter_test.dart';
import 'package:aa_podita/services/bayi_service.dart';
import 'package:aa_podita/models/bayi_model.dart';

void main() {
  group('Perhitungan Antropometri Permenkes No. 2 Tahun 2020', () {
    final bayiService = BayiService();

    test('Logika Truncating Umur Bulan', () {
      // Kasus: Tanggal ukur belum melewati tanggal lahir di bulan tersebut
      final bayi = BayiModel(
        id: '1',
        namaBayi: 'Budi',
        tanggalLahir: '2024-01-30',
        jenisKelamin: 'Laki-laki',
        beratBadan: 10,
        tinggiBadan: 80,
        namaIbu: 'Ibu',
        umurIbu: '25',
        pendidikanIbu: 'SMA',
        pekerjaanIbu: 'IRT',
        noHpIbu: '081',
        desa: 'Desa',
        anakKe: 1,
        jumlahAnak: 1,
        tanggalPemeriksaan: '2024-03-01',
      );

      // Harusnya 1 bulan penuh (bukan 2 bulan karena tanggal 1 < tanggal 30)
      expect(bayi.umurBulan, 1);
    });

    test('Kalkulasi Z-Score TB/U Laki-laki 24 Bulan (Extrem Pendek)', () {
      // Skenario: Laki-laki, 24 bulan, Tinggi 78 cm
      int umur = 24;
      double tb = 78.0;
      String gender = 'Laki-laki';

      // 1. Uji tanpa kompensasi (Sesuai usia/Berdiri)
      double zSesuaiUsia = bayiService.hitungZScoreTBU(umur, tb, gender);
      String statusSesuaiUsia = bayiService.tentukanStatusStuntingTBU(zSesuaiUsia);
      
      // Hitungan manual: (78 - 87.8) / (87.8 - 83.5) = -9.8 / 4.3 = -2.279
      expect(zSesuaiUsia, closeTo(-2.279, 0.01));
      expect(statusSesuaiUsia, 'Pendek (stunted)');

      // 2. Uji dengan kompensasi (Diukur Telentang padahal >= 24 bulan)
      // tb harus dikurangi 0.7 menjadi 77.3
      double zTelentang = bayiService.hitungZScoreTBU(umur, tb, gender, caraUkur: 'Telentang');
      String statusTelentang = bayiService.tentukanStatusStuntingTBU(zTelentang);

      // Hitungan manual: (77.3 - 87.8) / 4.3 = -10.5 / 4.3 = -2.441
      expect(zTelentang, closeTo(-2.441, 0.01));
      expect(statusTelentang, 'Pendek (stunted)');
    });

    test('Kalkulasi Z-Score TB/U Laki-laki 24 Bulan (Sangat Pendek)', () {
      // Skenario: Laki-laki, 24 bulan, Tinggi 74 cm
      int umur = 24;
      double tb = 74.0;
      String gender = 'Laki-laki';

      double z = bayiService.hitungZScoreTBU(umur, tb, gender);
      String status = bayiService.tentukanStatusStuntingTBU(z);

      // Hitungan manual: (74 - 87.8) / 4.3 = -13.8 / 4.3 = -3.209
      expect(z, closeTo(-3.209, 0.01));
      expect(status, 'Sangat pendek (severely stunted)');
    });
  });
}
