import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Database/saved_people_database.dart';
import '../../Database/missing_person_database.dart';

import 'saved_person_list_tile.dart';

class SavedPersonList extends StatelessWidget {
  final MissingPeopleModel missingPeople = MissingPeopleModel();

  @override
  Widget build(BuildContext context) {
    final SavedPeopleModel savedPeopleModel = context.watch<SavedPeopleModel>();

    return FutureBuilder(
      future: savedPeopleModel.getAllSavedPeople(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Set<String> peopleIds = snapshot.data
            .map((e) => e['id'].toString())
            .toSet()
            .cast<String>();

          return savedPersonListView(peopleIds);
        } else {
          return _loadingStatus(snapshot.connectionState);
        }
      },
    );
  }

  // --------------------------------------------------------------

  Widget savedPersonListView(Set<String> peopleIds) => FutureBuilder(
    future: missingPeople.getPeopleFromIds(peopleIds),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return _savePersonListViewBuilder(snapshot.data);
      } else {
        return _loadingStatus(snapshot.connectionState);
      }
    }
  );

  Widget _savePersonListViewBuilder(List people) => Expanded(
    child: ListView.builder(
      itemCount: people.length,
      itemBuilder: (BuildContext context, int index) =>
          SavedPersonTile(people[index]),
    ),
  );

  // --------------------------------------------------------------

  Widget _loadingStatus(ConnectionState connectionState) {
    if (connectionState == ConnectionState.waiting)
      return Center(child: CircularProgressIndicator());
    else
      return Text("No One Was Found");
  }
}
