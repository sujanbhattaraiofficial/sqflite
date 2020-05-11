import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'taskData.dart';

class DatabaseHelper {
  Database db;
  final String tableName = "nameTable";
  final String columnId = "id";
  final String columnName = "name";

  Future<void> initDatabase() async {
    db = await openDatabase(join(await getDatabasesPath(), "databaseName"),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY AUTOINCREMENT , $columnName TEXT)");
    }, version: 1);
  }

  Future<void> insertData(TaskData data) async {
    try {
      db.insert(tableName, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (_) {
      print(_);
    }
  }

  Future getAllData() async {
    final List<Map<String, dynamic>> task = await db.query(tableName);
    return List.generate(task.length, (i) {
      return TaskData(name: task[i][columnName], id: task[i][columnId]);
    });
  }

  Future update(TaskData data) async {
    return await db.update(tableName, data.toMap(),
        where: '$columnId = ?', whereArgs: [data.id]);
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }
}
