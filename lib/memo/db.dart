import 'package:memo/memo/memo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "memo.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE memo(
          id TEXT PRIMARY KEY,
          text TEXT,
          date TEXT
        )
      ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database db = await initDatabase();
    return await db.query('memo');
  }

  Future<List<Memo>> getMemos() async {
    final Database db = await initDatabase();
    final List<Map<String, dynamic>> maps =  await db.query('memo');
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        text: maps[i]['text'],
        date: maps[i]['date'],
      );
    });
  }

  Future<void> insertMemo({required Memo memo}) async {
    final Database db = await initDatabase();
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}