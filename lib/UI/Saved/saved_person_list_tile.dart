import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../Database/saved_people_database.dart';

import '../Popup Map/popup_map.dart';

// Item Card
class SavedPersonTile extends StatelessWidget {
  final Map person;

  SavedPersonTile(this.person);

  Future _showMapDialog(BuildContext scaffoldContext) async => await showDialog(
    context: scaffoldContext,
    builder: (_) {
      return PopUpMap(
        person['city'],
        person['province'],
        person['image'],
      );
    });

  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final SavedPeopleModel savedPeopleModel =
        Provider.of<SavedPeopleModel>(context);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: personCardImage(),
              subtitle: personCardText(savedPeopleModel)),
        ],
      ),
      color: Colors.brown[400],
    );
  }

  // -------------------------------------------------------------
  // PErson Card Image
  Widget personCardImage() => ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image.network(
      person['image'],
      fit: BoxFit.fill,
      errorBuilder: (_, __, ___) => Icon(Icons.error),
    ),
  );

  // Person Card Text
  Widget personCardText(SavedPeopleModel savedPeopleModel) => Column(children: [
    SizedBox(height: 10),
    _personCardName(),
    SizedBox(height: 10),
    _personCardDate(),
    SizedBox(height: 10),
    _personCardLoc(),
    SizedBox(height: 10),
    delBtn(savedPeopleModel),
  ]);

  // Name
  Widget _personCardName() => Text(
    person['firstName'] + " " + person['lastName'],
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
    textAlign: TextAlign.center,
  );

  // Missing Since
  Widget _personCardDate() => FutureBuilder(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        DateFormat formatter = DateFormat(
            'MMMM dd, yyyy', snapshot.data.getString('language') ?? "en");

        return Text(
          formatter.format(DateTime.parse(person['missingSince'])),
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        );
      } else {
        return Text("loading");
      }
    }
  );

  // Location
  Widget _personCardLoc() => Builder(
    builder: (context) => Row(children: [
      Expanded(
        child: RaisedButton(
          child: Text(
            FlutterI18n.translate(
                    context, "person_dialog.last_location") +
                '${person['city']}, ${person['province']}',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          onPressed: () => _showMapDialog(context),
          color: Colors.brown,
        ),
      ),
    ])
  );

  // Card delete button
  Widget delBtn(SavedPeopleModel savedPeopleModel) => RaisedButton(
    child: Icon(Icons.delete),
    color: Colors.red[200],
    onPressed: () {
      savedPeopleModel.deletePeopleId(person['id'].toString());
    },
  );
}
