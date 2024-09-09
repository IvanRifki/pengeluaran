import 'dart:io';
import 'package:intl/intl.dart';
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

  Future<List<Map<String, dynamic>>> queryAll(tipenya, sort) async {
    if (sort == 'A - Z') {
      sort = 'ASC';
    } else if (sort == 'Z - A') {
      sort = 'DESC';
    } else {
      sort = '';
    }

    Database db = await instance.database;

    if (tipenya == '') {
      return await db.query(
        table,
        columns: [
          columnId,
          columnPengeluaran,
          columnNominal,
          columnWaktu,
          columnTipe
        ],
        orderBy: '$columnId $sort',
      );
    } else {
      return await db.query(
        table,
        columns: [
          columnId,
          columnPengeluaran,
          columnNominal,
          columnWaktu,
          columnTipe
        ],
        where: '$columnTipe = ?',
        whereArgs: ['$tipenya'],
        orderBy: '$columnId $sort',
      );
    }
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
      whereArgs: ['%$namaPengeluaran%'],
    );
  }

  Future<List<Map<String, dynamic>>> queryPieChartByType(DateTime waktu) async {
    DateTime bulan = DateTime(1, waktu.month, 1);
    String bulannya = DateFormat('MMMM').format(bulan);

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
        'Select $columnTipe, SUM(REPLACE(REPLACE($columnNominal, ".", ""), "Rp ","")) as nominal, $columnWaktu FROM $table WHERE $columnWaktu LIKE "%$bulannya%" GROUP BY $columnTipe');
    return results;
  }

  Future<List<Map<String, dynamic>>> queryLineChartPengeluaran(bulan) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> resultsLCP = await db.rawQuery(
        'Select SUM(REPLACE(REPLACE($columnNominal, ".", ""), "Rp ", "")) as TotalPengeluaran, $columnWaktu FROM $table WHERE $columnWaktu LIKE "% $bulan %" group by $columnWaktu ');
    return resultsLCP;
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
