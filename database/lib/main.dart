import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'databaseHelper.dart';
import 'taskData.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DataBaseDemo(),
    );
  }
}

class DataBaseDemo extends StatefulWidget {
  @override
  _DataBaseDemoState createState() => _DataBaseDemoState();
}

class _DataBaseDemoState extends State<DataBaseDemo> {
  final textEditingController = TextEditingController();
  List<TaskData> task = <TaskData>[];
  final DatabaseHelper databaseHelper = DatabaseHelper();
  int currentId;
  int updateNo;
  bool isUpdating;
  String name;

  @override
  void initState() {
    super.initState();
    isUpdating = false;
  }

  Future<List<TaskData>> testTask() async {
    await databaseHelper.initDatabase();
    List<TaskData> list = await databaseHelper.getAllData();
    task = list;
    return task;
  }

  refreshList() async {
    List<TaskData> list = await databaseHelper.getAllData();
    setState(() {
      task = list;
    });

    return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          child: Column(
            children: <Widget>[
              TextField(
                controller: textEditingController,
                onChanged: (val) => name = val,
              ),
              FlatButton(
                color: Colors.blue,
                onPressed: () async {
                  if (isUpdating) {
                    TaskData data = TaskData(id: updateNo, name: name);
                    databaseHelper.update(data);
                    textEditingController.clear();
                    isUpdating = false;
                    refreshList();
                  } else {
                    TaskData data = TaskData(name: textEditingController.text);
                    databaseHelper.insertData(data);
                    List<TaskData> list = await databaseHelper.getAllData();
                    setState(() {
                      task = list;
                      isUpdating = false;
                      textEditingController.clear();
                    });
                  }
                },
                child: !isUpdating ? Text("Insert name") : Text("update name"),
              ),
              listSample(),
            ],
          ),
        ),
      ),
    );
  }

  Widget listSample() {
    return FutureBuilder<List<TaskData>>(
      future: testTask(),
      builder: (BuildContext context, AsyncSnapshot<List<TaskData>> snapshot) {
        if (snapshot.hasData) {
          return list(context);
        } else {
          Text("Data not found");
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget list(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: task.length,
        itemBuilder: (context, index) {
          return Dismissible(
            background: Container(color: Colors.red[300]),
            key: Key(task[index].id.toString()),
            direction: DismissDirection.endToStart,
            child: ListTile(
              onLongPress: () {
                setState(() {
                  isUpdating = true;
                  textEditingController.text = task[index].name;
                  updateNo = task[index].id;
                });
              },
              leading: Text("${index + 1}"),
              title: Text(task[index].name),
            ),
            onDismissed: (direction) {
              currentId = task[index].id;
              print("Delete No $currentId");
              databaseHelper.delete(currentId);
              refreshList();
            },
          );
        },
      ),
    );
  }
}
