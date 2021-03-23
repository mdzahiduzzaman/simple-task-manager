import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:simple_task_manager/models/task.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper dbInstance = DatabaseHelper.instance();
  static Database database;

  DatabaseHelper.instance();
  String TABLE_NAME = 'task_table';
  String ID = 'id';
  String TITLE = 'title';
  String DETAILS = 'details';
  String DUE_DATE = 'dueDate';
  String PRIORITY = 'priority';
  String STATUS = 'status';

  Future<Database> get db async {
    if(database == null) {
      database = await initDb();
    }
    return database;
  }

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'task_list.db';
    final taskListDb = await openDatabase(path, version: 1,  onCreate: createDb);
    return taskListDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $TABLE_NAME($ID INTEGER PRIMARY KEY AUTOINCREMENT, $TITLE TEXT, $DETAILS TEXT, $DUE_DATE TEXT, $PRIORITY TEXT, $STATUS INTEGER)'
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(TABLE_NAME);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.retrieveFromMap(taskMap));
    });
    taskList.sort((task1, task2) => task1.dueDate.compareTo(task2.dueDate));
    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(TABLE_NAME, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      TABLE_NAME,
      task.toMap(),
      where: '$ID = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      TABLE_NAME,
      where: '$ID = ?',
      whereArgs: [id],
    );
    return result;
  }
}