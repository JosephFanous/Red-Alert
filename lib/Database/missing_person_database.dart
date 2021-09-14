import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Person {
  DocumentReference reference;
  int id;
  String image;
  String firstName;
  String lastName;
  String city, province;
  DateTime missingSince;

  Person(this.id);

  Map<String, dynamic> toMap() => {
        'id': id,
        'image': image,
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'province': province,
        'missingSince': missingSince
      };

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'image': image,
        'firstName': firstName,
        'lastName': lastName,
        'city': city,
        'province': province,
        'missingSince': missingSince.toString()
      };

  Person.fromMap(Map<String, dynamic> map, {this.reference}) {
    id = map['id'];
    image = map['image'];
    firstName = map['firstName'];
    lastName = map['lastName'];
    Timestamp time = map['missingSince'];
    missingSince = time.toDate();
    city = map['city'];
    province = map['province'];
  }
}

// -------------------------------------------------------------------

class MissingPeopleModel with ChangeNotifier {
  // Local SQL
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
        join(await getDatabasesPath(), 'missing_people.db'),
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE missing_people (
          id INT UNIQUE,
          image STRING,
          firstName STRING,
          lastName STRING,
          city STRING,
          province STRING,
          missingSince STRING
        )
        ''');
    }, version: 1);
  }

  // Firebase
  final people = FirebaseFirestore.instance.collection('persons');

  // -------------------------------------------------------------------

  Future<bool> isDbEmpty() async {
    final db = await database;
    var res = await db.query("missing_people");
    return res.length == 0;
  }

  void refreshLocalDb() async {
    deleteAllPeople();
    downloadAllPeopleToDb();
  }

  void downloadAllPeopleToDb() async {
    final db = await database;
    var res = await db.query("missing_people");

    if (res.length == 0) {
      try {
        QuerySnapshot cloudDb = await _getAllPeopleFromFirebase();
        cloudDb.docs.forEach((DocumentSnapshot element) async {
          Person person = Person.fromMap(element.data());
          await db.insert("missing_people", person.toDbMap());
        });
      } catch (error) {
        print(error);
      }
    }

    notifyListeners();
  }

  Future<List> getAllPeople() async {
    final db = await database;
    var res = await db.query("missing_people");

    if (res.length == 0)
      return null;
    else {
      return res;
    }
  }

  void deleteAllPeople() async {
    final db = await database;
    await db.execute('''
    DELETE FROM missing_people
    ''');
    notifyListeners();
  }

  Future getPeopleFromId(String id) async {
    String query = '''
    SELECT * 
    FROM missing_people
    WHERE id = $id
    ''';
    final db = await database;
    var res = await db.rawQuery(query);
    return res;
  }

  Future getPeopleFromIds(Set<String> id) async {
    String inClause = id.toString();
    inClause = inClause.substring(1, inClause.length - 1);

    String query = '''
    SELECT * 
    FROM missing_people
    WHERE id IN ($inClause)
    ''';
    final db = await database;
    var res = await db.rawQuery(query);
    if (res.length == 0)
      return null;
    else
      return res;
  }

  Future getPersonWhereName(String fullName) async {
    String query = '''
    SELECT * 
    FROM missing_people
    WHERE LOWER(firstName || ' ' || lastName) LIKE '%${fullName.toLowerCase()}%'
    ''';
    final db = await database;
    var res = await db.rawQuery(query);

    return res;
  }

  Future getPersonWhereDate(DateTime date) async {
    DateTime tmrwDate = date.add(Duration(days: 1));
    String query = '''
    SELECT * 
    FROM missing_people
    WHERE missingSince > '${date.toString()}'
    AND missingSince < '${tmrwDate.toString()}'
    ''';
    final db = await database;
    var res = await db.rawQuery(query);
    return res;
  }

  Future getPeopleWhereCityAndProvince(String city, {String province}) async {
    String provinceQuery =
        province.isNotEmpty ? "AND province = '$province'" : '';
    String query = '''
    SELECT * 
    FROM missing_people
    WHERE city = '$city'
    $provinceQuery
    ''';
    final db = await database;
    var res = await db.rawQuery(query);
    return res;
  }

  // -------------------------------------------------------------------

  Future<QuerySnapshot> _getAllPeopleFromFirebase() {
    return people.get();
  }
}
