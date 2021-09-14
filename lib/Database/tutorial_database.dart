import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TutorialModel {
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    await _database.execute('''
      INSERT INTO tutorial
      VALUES (1, 1, 1, 1, 1);
    ''');
    return _database;
  }

  initDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'tutorial.db'),
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tutorial (
          syncPage BOOL,
          missingPersonPage BOOL,
          savedPersonPage BOOL,
          mapPage BOOL,
          breakdownPage BOOL
        )
        ''');
    }, version: 1);
  }

  // ---------------------------------------------------------------------

  Future getTutorialSettingFor(String page) async {
    String query = '''
    SELECT $page
    FROM tutorial
    ''';
    final db = await database;
    var res = await db.rawQuery(query);
    return res[0][page] == 1;
  }

  void turnOffTutorialSettingFor(String page) async {
    String query = '''
    UPDATE tutorial
    SET $page = 0
    ''';
    final db = await database;
    await db.rawUpdate(query);
  }

  void turnOffAllTutorials() async {
    String query = '''
    UPDATE tutorial
    SET syncPage = 0, 
        missingPersonPage = 0,
        savedPersonPage = 0,
        mapPage = 0,
        breakdownPage = 0
    ''';
    final db = await database;
    await db.rawUpdate(query);
  }

  void turnOnAllTutorials() async {
    String query = '''
    UPDATE tutorial
    SET syncPage = 1, 
        missingPersonPage = 1,
        savedPersonPage = 1,
        mapPage = 1,
        breakdownPage = 1
    ''';
    final db = await database;
    await db.rawUpdate(query);
  }
}
