class TaskData {
  final String name;
  int id;
  TaskData({this.name, this.id});

  Map<String, dynamic> toMap() {
    return {"name": this.name};
  }
}
