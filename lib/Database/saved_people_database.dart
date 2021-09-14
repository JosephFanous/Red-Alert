import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedPerson {
  String id;

  SavedPerson(this.id);

  Map<String, dynamic> toMap() => {'id': id};

  SavedPerson.fromMap(Map<String, dynamic> map) {
    id = map['id'];
  }
}

class SavedPeopleModel with ChangeNotifier {
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'saved_people.db'),
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE saved_people (
          id STRING UNIQUE
        )
        ''');
    }, version: 1);
  }

  Future<Set> getAllSavedPeople() async {
    final db = await database;
    List temp = await db.query("saved_people");
    Set res = temp.toSet();

    if (res.length == 0)
      return null;
    else {
      return res;
    }
  }

  insertPeople(SavedPerson person) async {
    final db = await database;
    try {
      await db.insert("saved_people", person.toMap());
    } catch (error) {
      return error;
    }

    notifyListeners();
  }

  deletePeopleId(String id) async {
    final db = await database;
    await db.delete(
      "saved_people",
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }
}
