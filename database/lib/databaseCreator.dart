import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskData {
  final String name;
  int id;

  TaskData({this.name, this.id});

  Map<String, dynamic> toMap() {
    return {"friendsName": this.name};
  }
}

class Todohelper {
  Database db;
  final String tabaleName = "todo";
  final String columnId = "id";
  final String columnName = "friendsName";

  Todohelper() {
    //initDatabase();
  }
  Future<void> initDatabase() async {
    db = await openDatabase(join(await getDatabasesPath(), "dataSujan.db"),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE $tabaleName($columnId INTEGER PRIMARY KEY AUTOINCREMENT ,$columnName TEXT)");
    }, version: 1);
  }

  Future<void> insertTask(TaskData model) async {
    try {
      db.insert(tabaleName, model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (_) {
      print(_);
    }
  }

  Future getAllTask() async {
    final List<Map<String, dynamic>> task = await db.query(tabaleName);
    return List.generate(task.length, (i) {
      return TaskData(name: task[i][columnName], id: task[i][columnId]);
    });
  }

  Future<int> delete(int id) async {
    return await db.delete(tabaleName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(TaskData model) async {
    return await db.update(tabaleName, model.toMap(),
        where: '$columnId = ?', whereArgs: [model.id]);
  }


}
