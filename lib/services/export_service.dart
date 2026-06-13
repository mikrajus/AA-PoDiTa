import 'dart:typed_data';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:file_saver/file_saver.dart';
import '../models/bayi_model.dart';
import 'bayi_service.dart';

class ExportService {
  static Future<void> exportRiwayatToExcel(
      List<BayiModel> data, String namaFile) async {
    // Buat objek Excel menggunakan Syncfusion
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Riwayat Pemeriksaan';

    // Tulis header
    List<String> headers = [
      'No',
      'Nama Bayi',
      'Nama Ibu',
      'Jenis Kelamin',
      'Tanggal Lahir',
      'Tanggal Pemeriksaan',
      'Usia (Bulan)',
      'Berat Badan (kg)',
      'Tinggi Badan (cm)',
      'Z-Score BB/U',
      'Z-Score TB/U',
      'Status Gizi (BB/U)',
      'Status Stunting (TB/U)',
      'Kader Pemeriksa',
      'Desa'
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
    }

    // Tulis data baris
    int rowCount = 2;
    for (int i = 0; i < data.length; i++) {
      var bayi = data[i];

      // Kumpulkan semua pemeriksaan (riwayat terdahulu + yang terbaru di root)
      List<Map<String, dynamic>> semuaPemeriksaan = [];

      // Tambahkan riwayat terdahulu
      for (var r in bayi.riwayatPemeriksaan) {
        semuaPemeriksaan.add({
          'tanggal': r['tanggal'] ?? r['tanggalPemeriksaan'] ?? '',
          'beratBadan': r['beratBadan'] ?? 0.0,
          'tinggiBadan': r['tinggiBadan'] ?? 0.0,
          'statusGizi': r['statusGizi'] ?? '-',
          'statusStunting': r['statusStunting'] ?? '-',
        });
      }

      // Tambahkan pemeriksaan terbaru (root) jika ada
      if (bayi.tanggalPemeriksaan.isNotEmpty &&
          bayi.tanggalPemeriksaan != '-') {
        semuaPemeriksaan.add({
          'tanggal': bayi.tanggalPemeriksaan,
          'beratBadan': bayi.beratBadan,
          'tinggiBadan': bayi.tinggiBadan,
          'statusGizi': bayi.statusGizi,
          'statusStunting': bayi.statusStunting,
        });
      }

      // Urutkan berdasarkan tanggal (terlama ke terbaru atau sebaliknya)
      // Kita urutkan dari yang terbaru ke terlama untuk tiap bayi
      semuaPemeriksaan.sort(
          (a, b) => (b['tanggal'] as String).compareTo(a['tanggal'] as String));

      for (var pem in semuaPemeriksaan) {
        String tglPem = pem['tanggal'] as String;
        if (tglPem.isEmpty || tglPem == '-') continue;

        // Hitung umur dalam bulan secara manual untuk tanggal pemeriksaan ini
        int umur = 0;
        try {
          final pLahir = bayi.tanggalLahir.split('-');
          final pPem = tglPem.split('-');
          if (pLahir.length == 3 && pPem.length == 3) {
            final lahir = DateTime(int.parse(pLahir[0]), int.parse(pLahir[1]),
                int.parse(pLahir[2]));
            final target = DateTime(
                int.parse(pPem[0]), int.parse(pPem[1]), int.parse(pPem[2]));
            umur = (target.year - lahir.year) * 12 + target.month - lahir.month;
            if (target.day < lahir.day) umur--;
            if (umur < 0) umur = 0;
          }
        } catch (_) {}

        // Hitung z-score
        double zBBU = BayiService().hitungZScoreBBU(
            umur, pem['beratBadan'] as double, bayi.jenisKelamin);
        double zTBU = BayiService().hitungZScoreTBU(
            umur, pem['tinggiBadan'] as double, bayi.jenisKelamin);

        // Tulis row ke Excel (indeks mulai dari 2 karena baris 1 adalah header)
        int colIndex = 1;
        sheet.getRangeByIndex(rowCount, colIndex++).setValue(rowCount - 1);
        sheet.getRangeByIndex(rowCount, colIndex++).setText(bayi.namaBayi);
        sheet.getRangeByIndex(rowCount, colIndex++).setText(bayi.namaIbu);
        sheet.getRangeByIndex(rowCount, colIndex++).setText(bayi.jenisKelamin);
        sheet.getRangeByIndex(rowCount, colIndex++).setText(bayi.tanggalLahir);
        sheet.getRangeByIndex(rowCount, colIndex++).setText(tglPem);
        sheet.getRangeByIndex(rowCount, colIndex++).setNumber(umur.toDouble());
        sheet
            .getRangeByIndex(rowCount, colIndex++)
            .setNumber(pem['beratBadan'] as double);
        sheet
            .getRangeByIndex(rowCount, colIndex++)
            .setNumber(pem['tinggiBadan'] as double);
        sheet.getRangeByIndex(rowCount, colIndex++).setNumber(zBBU);
        sheet.getRangeByIndex(rowCount, colIndex++).setNumber(zTBU);
        sheet
            .getRangeByIndex(rowCount, colIndex++)
            .setText('${pem['statusGizi']}');
        sheet
            .getRangeByIndex(rowCount, colIndex++)
            .setText('${pem['statusStunting']}');
        sheet.getRangeByIndex(rowCount, colIndex++).setText(bayi.createdBy);
        sheet.getRangeByIndex(rowCount, colIndex++).setText(bayi.desa);

        rowCount++;
      }
    }

    // Tambahkan AutoFilter ke seluruh data range (Baris 1 s/d rowCount-1, Kolom 1 s/d headers.length)
    if (rowCount > 1) {
      final String startCell = 'A1';
      final String endCell =
          '${String.fromCharCode(64 + headers.length)}${rowCount - 1}';
      sheet.autoFilters.filterRange =
          sheet.getRangeByName('$startCell:$endCell');
    }

    try {
      // Ambil bytes excel
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      if (bytes.isNotEmpty) {
        // Simpan menggunakan file_saver
        var now = DateTime.now();
        String formattedDate =
            "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";
        String finalFileName =
            '${namaFile}_$formattedDate'; // jangan pakai .xlsx

        await FileSaver.instance.saveAs(
          name: finalFileName,
          bytes: Uint8List.fromList(bytes),
          fileExtension: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
      } else {
        throw Exception("Gagal meng-generate file excel (bytes null)");
      }
    } catch (e) {
      debugPrint('Error Export: $e');
      throw Exception('Terjadi kesalahan saat menyimpan file: $e');
    }
  }
}
