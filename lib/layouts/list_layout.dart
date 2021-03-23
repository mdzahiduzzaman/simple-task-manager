import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_task_manager/helpers/db_helper.dart';
import 'package:simple_task_manager/layouts/add_task_layout.dart';
import 'package:simple_task_manager/models/task.dart';

class ListLayout extends StatefulWidget {
  @override
  ListLayoutState createState() => ListLayoutState();
}

class ListLayoutState extends State<ListLayout> {

  Future<List<Task>> taskList;

  @override
  void initState() {
    super.initState();
    updateTaskList();
  }

  updateTaskList() {
    setState(() {
      taskList = DatabaseHelper.dbInstance.getTaskList();
    });
  }

  final DateFormat dueDateFormatter = DateFormat('MMM dd, yyyy');

  Widget buildListItem(Task task) {
    return Column(
      children: [
        ListTile(
          title: Text(task.title, style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough,
          ),),
          subtitle: Text('${task.details}\n\n${dueDateFormatter.format(task.dueDate)} · ${task.priority}', style: TextStyle(
            fontSize: 15.0,
            decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough,
          ),),isThreeLine: true,
          leading: Checkbox(
            onChanged: (value) {
              task.status = value ? 1 : 0;
              DatabaseHelper.dbInstance.updateTask(task);
              updateTaskList();
            },
            activeColor: Theme.of(context).primaryColor,
            value: task.status == 1 ? true : false,
          ),
          onTap: () => Navigator.push(
            context, MaterialPageRoute(
              builder: (_) => AddTaskLayout(
                updateTaskList: updateTaskList,
                task: task,
              ),
            ),
          ),
        ), Divider()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Task List'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(
            builder: (_) => AddTaskLayout(
              updateTaskList: updateTaskList,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: taskList,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                );
              }
              return buildListItem(snapshot.data[index-1]);
            },
          );
        },
      ),
    );
  }
}