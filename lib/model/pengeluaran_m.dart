import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';

class PengeluaranM {
  final int? id;
  final String pengeluaran;
  final int nominal;
  final DateTime waktu;
  final String tipe;

  PengeluaranM(this.id, this.pengeluaran, this.nominal, this.waktu, this.tipe);

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnPengeluaran: pengeluaran,
      DatabaseHelper.columnNominal: nominal,
      DatabaseHelper.columnWaktu: waktu,
      DatabaseHelper.columnTipe: tipe,
    };
  }
}
