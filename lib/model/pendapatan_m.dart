import 'package:pengeluaran/databasehelper/dbhelper_pendapatan.dart';

class PendapatanM {
  final int? id;
  final String pendapatan;
  final int nominal;
  final DateTime waktu;

  PendapatanM(this.id, this.pendapatan, this.nominal, this.waktu);

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelperPendapatan.columnId: id,
      DatabaseHelperPendapatan.columnPendapatan: pendapatan,
      DatabaseHelperPendapatan.columnNominal: nominal,
      DatabaseHelperPendapatan.columnWaktu: waktu,
    };
  }
}
