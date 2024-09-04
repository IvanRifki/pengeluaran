import 'dart:io';

import 'package:intl/intl.dart';
// import 'package:pengeluaran/model/pengeluaran_m.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static const _databaseName = 'pengeluaran.db';
  static const _databaseVersion = 1;
  static const table = 'pengeluaran';
  static const columnId = 'id';
  static const columnPengeluaran = 'pengeluaran';
  static const columnNominal = 'nominal';
  static const columnWaktu = 'waktu';
  static const columnTipe = 'tipe';

  static final DatabaseHelper instance = DatabaseHelper._private();
  Database? _database;

  DatabaseHelper._private();

  Future<Database> get database async {
    // if (_database != null) return _database!;
    // _database = await _initDatabase();
    // return _database!;
    if (_database != null) {
      return _database!;
    }
    if (Platform.isWindows) {
      _database = await iniWinDB();
    } else {
      _database = await _initDatabase();
    }

    return _database!;
  }

  Future<Database> iniWinDB() async {
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;
    return await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          onCreate: _onCreate,
          version: _databaseVersion,
        ));
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPengeluaran TEXT NOT NULL,
        $columnNominal INTEGER NOT NULL,
        $columnWaktu DATE NOT NULL,
        $columnTipe TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(
      table,
      columns: [
        columnId,
        columnPengeluaran,
        columnNominal,
        columnWaktu,
        columnTipe
      ],
      orderBy: '$columnId DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryAllByPengeluaran(
      namaPengeluaran) async {
    Database db = await instance.database;
    return await db.query(
      table,
      columns: [
        columnId,
        columnPengeluaran,
        columnNominal,
        columnWaktu,
        columnTipe
      ],
      orderBy: '$columnWaktu DESC',
      where: '$columnPengeluaran LIKE ?',
      whereArgs: ['%${namaPengeluaran}%'],
    );
  }

  Future<List<Map<String, dynamic>>> queryPieChartByType(waktu) async {
    DateTime Bulan = DateTime(1, waktu, 1);
    String Bulannya = DateFormat('MMMM').format(Bulan);

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
        'Select $columnTipe, SUM(CAST(REPLACE($columnNominal, "Rp ", "") AS INTEGER)) as nominal, $columnWaktu FROM $table WHERE $columnWaktu LIKE "%$Bulannya%" GROUP BY $columnTipe');

    return results;
  }

  Future<List<Map<String, dynamic>>> queryLineChartPengeluaran(bulan) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
        'Select SUM(CAST(REPLACE($columnNominal, "Rp ", "") AS INTEGER)) as TotalPengeluaran, $columnWaktu FROM $table WHERE $columnWaktu LIKE "% $bulan %" group by $columnWaktu ');

    print('ini resultnya $results');
    return results;
  }

  Future<int> update(int id, Map<String, dynamic> row) async {
    Database db = await database;

    return await db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [row[columnId]],
    );
  }

  Future<int> updatePengeluaran(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    final query =
        await db.update(table, row, where: '$id = ?', whereArgs: [id]);
    return query;
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
