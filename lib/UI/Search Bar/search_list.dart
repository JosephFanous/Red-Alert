import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/missing_person_database.dart';
import '../../Database/saved_people_database.dart';

class SearchList extends StatelessWidget {
  final MissingPeopleModel missingPeople = MissingPeopleModel();

  final String name;

  SearchList(this.name);

  // Save person to Saved Person Screen
  void savePerson(
      scaffoldContext, String id, SavedPeopleModel savedPeopleModel) async {
    SavedPerson person = SavedPerson(id);
    await savedPeopleModel.insertPeople(person);

    Navigator.pop(scaffoldContext);
  }

  // --------------------------------------

  @override
  Widget build(BuildContext context) {
    final SavedPeopleModel savedPeopleModel =
        Provider.of<SavedPeopleModel>(context);

    return Container(
      width: double.maxFinite,
      child: FutureBuilder(
        future: missingPeople.getPersonWhereName(name),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return _searchListView(snapshot.data, savedPeopleModel);
            } else {
              return Center(child: Text("No One Was Found"));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      )
    );
  }

  // --------------------------------------

  Widget _searchListView(List people, SavedPeopleModel savedPeopleModel) =>
    ListView.builder(
      itemCount: people.length,
      itemBuilder: (BuildContext context, int index) =>
          seachCard(people[index], savedPeopleModel),
    );

  // Search Cards
  Widget seachCard(Map person, SavedPeopleModel savedPeopleModel) => Card(
    color: Colors.brown,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        searchCardText(person, savedPeopleModel),
      ],
    ),
  );

  // Search Card Text Content
  Widget searchCardText(Map person, SavedPeopleModel savedPeopleModel) =>
    FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Date format depending on the langauge
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
              style: TextStyle(color: Colors.white),),
            trailing:Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () => savePerson(context, id, savedPeopleModel),
              ),
            )
          );
        } else {
          return Text("Loading");
        }
      }
    );
}
