import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserPomodoro {
  int? id;
  String? date;
  int? count;
  UserPomodoro({this.id, required this.date, required this.count});
  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'count': count,
    };
  }

  UserPomodoro.fromMap(Map<dynamic, dynamic>? map) {
    date = map?['date'];
    count = map?['count'];
  }
}

class UserPomodoroProvider {
  late Database _database;
  Future<Database?> get datebase async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'pomodoro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE UserPomodoro(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            date TEXT,
            count INTEGER NOT NULL)
          )
          ''');
      },
    );
  }

  Future<List<UserPomodoro>> getTodos() async {
    List<UserPomodoro> userpomodoros = [];
    List<Map> maps =
        await _database.query('UserPomodoro', columns: ['id', 'date', 'count']);
    for (var map in maps) {
      userpomodoros.add(UserPomodoro.fromMap(map));
    }
    return userpomodoros;
  }
  
}
