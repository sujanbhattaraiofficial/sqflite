import 'package:databaase/databaseCreator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DataUi(),
    );
  }
}

class DataUi extends StatefulWidget {
  @override
  _DataUiState createState() => _DataUiState();
}

class _DataUiState extends State<DataUi> {
  final texteditingController = TextEditingController();
  List<TaskData> task = <TaskData>[];
  final Todohelper todoHelper = Todohelper();
  int currentId;
  bool isUpdating = false;
  int updateNo;
  String name;

  @override
  void initState() {
    super.initState();
    isUpdating = false;
  }

  Future<List<TaskData>> testFunction() async {
    await todoHelper.initDatabase();
    List<TaskData> list = await todoHelper.getAllTask();
    task = list;
    return task;
  }

  refreshList() async {
    List<TaskData> list = await todoHelper.getAllTask();
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
                controller: texteditingController,
                onChanged: (val) => name = val,
              ),
              FlatButton(
                color: Colors.blue,
                onPressed: () async {
                  if (isUpdating) {
                    TaskData model = TaskData(id: updateNo, name: name);
                    todoHelper.update(model);
                    refreshList();
                    isUpdating = false;
                    texteditingController.clear();
                  } else {
                    TaskData taskModel =
                        TaskData(name: texteditingController.text);
                    todoHelper.insertTask(taskModel);
                    List<TaskData> list = await todoHelper.getAllTask();
                    setState(() {
                      task = list;
                      isUpdating = false;
                      texteditingController.clear();
                    });
                  }
                },
                child: !isUpdating ? Text("InsertData") : Text("Update"),
              ),
              listSample()
            ],
          ),
        ),
      ),
    );
  }

  Widget listSample() {
    return FutureBuilder<List<TaskData>>(
      future: testFunction(),
      builder: (BuildContext context, AsyncSnapshot<List<TaskData>> snapshot) {
        if (snapshot.hasData) {
          return list(context);
        } else {
          Text("Data Not found");
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
              background: Container(
                color: Colors.red,
              ),
              key: Key(task[index].id.toString()),
              direction: DismissDirection.endToStart,
              child: ListTile(
                onLongPress: () {
                  setState(() {
                    isUpdating = true;
                    texteditingController.text =
                        task[index].name; // to show text initially
                    updateNo = task[index].id; // getting id of the row
                  });
                },
                leading: Text("${index + 1}"),
                title: Text(task[index].name),
              ),
              onDismissed: (direction) {
                currentId = task[index].id;
                print("Delete No $currentId");
                todoHelper.delete(currentId);
                refreshList();
              },
            );
          }),
    );
  }
}
