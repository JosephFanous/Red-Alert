import 'package:Red_Alert/Database/saved_people_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/saved_people_database.dart';

class MapDialog extends StatelessWidget {
  final SavedPeopleModel savedPeopleModel = SavedPeopleModel();
  final List people;

  MapDialog(this.people);

  void savePerson(String id) async {
    SavedPerson person = SavedPerson(id);
    await savedPeopleModel.insertPeople(person);
  }

  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.brown[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text("Missing People (${people.length})"),
      content: _peopleList(),
      actions: [_exitBtn(context)],
    );
  }

  // --------------------------------------------------------------

  Widget _exitBtn(context) => TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Exit"),
      );

  Widget _peopleList() => Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: people.length,
          itemBuilder: (BuildContext context, int index) => _peopleCard(index),
        ),
      );

  // --------------------------------------------------------------

  Widget _peopleCard(int index) => Card(
    color: Colors.brown,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [_peopleCardContent(people[index])],
    ),
  );

  Widget _peopleCardContent(Map person) => FutureBuilder(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        // Date format depending on the language
        DateFormat formatter = DateFormat(
            'MMMM dd, yyyy', snapshot.data.getString('language') ?? "en");

        // Person content
        String url = person['image'];
        String name = person['firstName'] + " " + person['lastName'];
        String date =
            formatter.format(DateTime.parse(person['missingSince']));
        String id = person['id'].toString();

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(url),
            onBackgroundImageError: (_, __) {},),
          title: Text(
            name,
            style: TextStyle(color: Colors.white),),
          subtitle: Text(
            date,
            style: TextStyle(color: Colors.grey),),
          trailing: IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () => savePerson(id),
          )
        );
      } else {
        return Text("Loading");
      }
    }
  );
}
