class Task {
  int id;
  String title;
  String details;
  DateTime dueDate;
  String priority;
  int status;

  Task({this.title, this.details, this.dueDate, this.priority, this.status});
  Task.withId({this.id, this.title, this.details, this.dueDate, this.priority, this.status});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if(id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['details'] = details;
    map['dueDate'] = dueDate.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Task.retrieveFromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      title: map['title'],
      details: map['details'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: map['priority'],
      status: map['status'],
    );
  }
}