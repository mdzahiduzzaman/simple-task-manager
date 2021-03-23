import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_task_manager/helpers/db_helper.dart';
import 'package:simple_task_manager/models/task.dart';

class AddTaskLayout extends StatefulWidget {

  final Function updateTaskList;
  final Task task;
  AddTaskLayout({this.updateTaskList, this.task});

  @override
  AddTaskLayoutState createState() => AddTaskLayoutState();
}

class AddTaskLayoutState extends State<AddTaskLayout> {

  final formKey = GlobalKey<FormState>();
  String title = '';
  String details = '';
  String priority;
  DateTime dueDate = DateTime.now();

  TextEditingController dueDateController = TextEditingController();

  final DateFormat dueDateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    if(widget.task != null) {
      title = widget.task.title;
      details = widget.task.details;
      dueDate = widget.task.dueDate;
      priority = widget.task.priority;
    }

    dueDateController.text = dueDateFormatter.format(dueDate);
  }

  @override
  void dispose() {
    dueDateController.dispose();
    super.dispose();
  }

  openDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if(date != null && date != dueDate) {
      setState(() {
        dueDate = date;
      });
      dueDateController.text = dueDateFormatter.format(date);
    }
  }

  deleteFromList() {
    DatabaseHelper.dbInstance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }
  
  submitToList() {
    if(formKey.currentState.validate()) {
      formKey.currentState.save();

      Task task = Task(title: title, details: details, dueDate: dueDate, priority: priority);
      if(widget.task == null) {
        task.status = 0;
        DatabaseHelper.dbInstance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.dbInstance.updateTask(task);
      }

      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Add New Task' : 'Update Current Task',
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 18.0),
                          ),
                          validator: (input) => input.trim().isEmpty ? 'Enter a task title' : null,
                          onSaved: (input) => title = input,
                          initialValue: title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Details',
                            labelStyle: TextStyle(fontSize: 18.0),
                          ),
                          validator: (input) => details == null ? 'Enter task details' : null,
                          onSaved: (input) => details = input,
                          initialValue: details,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: dueDateController,
                          style: TextStyle(fontSize: 18.0),
                          onTap: openDatePicker,
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            labelStyle: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: DropdownButtonFormField(
                          icon: Icon(Icons.arrow_drop_down_circle_outlined),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: priorities.map((String prior) {
                            return DropdownMenuItem(
                                value: prior,
                                child: Text(
                                  prior,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                )
                            );
                          }).toList(),
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: TextStyle(fontSize: 18.0),
                          ),
                          validator: (input) => priority == null ? 'Select a priority level' : null,
                          onChanged: (value) {
                            setState(() {
                              priority = value;
                            });
                          },
                          value: priority,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextButton(
                          child: Text(
                            widget.task == null ? 'Add Task' : 'Update Task',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0
                            ),
                          ),
                          onPressed: submitToList,
                        ),
                      ),
                      widget.task != null ? Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.red.shade800,
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: TextButton(
                          child: Text(
                            'Delete Task',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0
                            ),
                          ),
                          onPressed: deleteFromList,
                        ),
                      ) : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}