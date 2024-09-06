import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelperPendapatan {
  static const _databaseName = 'pendapatan.db';
  static const _databaseVersion = 1;
  static const table = 'pendapatan';
  static const columnId = 'id';
  static const columnPendapatan = 'pendapatan';
  static const columnNominal = 'nominal';
  static const columnWaktu = 'waktu';

  static final DatabaseHelperPendapatan instance =
      DatabaseHelperPendapatan._private();
  Database? _database;

  DatabaseHelperPendapatan._private();

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
    final path = join(Directory.current.path, _databaseName);
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        onCreate: _onCreate,
        version: _databaseVersion,
      ),
    );
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
        $columnPendapatan TEXT NOT NULL,
        $columnNominal INTEGER NOT NULL,
        $columnWaktu DATE NOT NULL
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
        columnPendapatan,
        columnNominal,
        columnWaktu,
      ],
      orderBy: '$columnId DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryAllByPendapatan(
      namaPengeluaran) async {
    Database db = await instance.database;
    return await db.query(
      table,
      columns: [
        columnId,
        columnPendapatan,
        columnNominal,
        columnWaktu,
      ],
      orderBy: '$columnWaktu DESC',
      where: '$columnPendapatan LIKE ?',
      whereArgs: ['%$namaPengeluaran%'],
    );
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
