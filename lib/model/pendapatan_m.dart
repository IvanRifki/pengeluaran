import 'package:pengeluaran/databasehelper/dbhelper_pendapatan.dart';

class PendapatanM {
  final int? id;
  final String Pendapatan;
  final int nominal;
  final DateTime waktu;

  PendapatanM(this.id, this.Pendapatan, this.nominal, this.waktu);

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelperPendapatan.columnId: id,
      DatabaseHelperPendapatan.columnPendapatan: Pendapatan,
      DatabaseHelperPendapatan.columnNominal: nominal,
      DatabaseHelperPendapatan.columnWaktu: waktu,
    };
  }
}
