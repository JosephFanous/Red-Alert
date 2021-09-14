import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/selected_item_model.dart';

import '../Notifications/notification.dart';

import 'missing_person_dialog.dart';
import 'missing_person_bell_btn.dart';

class MissingPersonListTile extends StatefulWidget {
  final Map person;
  final Notifications _notifications;

  MissingPersonListTile(this.person, this._notifications);

  @override
  _MissingPersonListTileState createState() => _MissingPersonListTileState();
}

class _MissingPersonListTileState extends State<MissingPersonListTile> {
  bool _selectedIndex = false;

  void refresh(bool bool) {
    setState(() {
      _selectedIndex = bool;
    });
  }

  void _moreInfo() async {
    await showDialog(
      context: context,
      child: PeopleDialog(widget.person),
    );
  }

  void _tileSelectionHandler(SelectedPeopleModel selectedPeopleModel) =>
    setState(() {
      _selectedIndex = !_selectedIndex;

      if (_selectedIndex) {
        selectedPeopleModel.insertDocId(widget.person['id'].toString());
      } else {
        selectedPeopleModel.removeDocId(widget.person['id'].toString());
      }
    }
  );

  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final SelectedPeopleModel selectedPeopleModel =
        context.watch<SelectedPeopleModel>();

    List<String> selectedPeople = selectedPeopleModel.getDocIds();

    if (selectedPeople.length == 0) {
      // deselect item after saving to local db
      refresh(false);
    } else if (selectedPeople.contains(widget.person['id'].toString())) {
      // select even after item is destroy by ListView
      refresh(true);
    }

    return _personTile(selectedPeopleModel);
  }

  // ---------------------------------------------------------------------
  // Person content
  Widget _personTile(SelectedPeopleModel selectedPeopleModel) => Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: _selectedIndex ? Colors.brown[900] : Colors.brown,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.brown[300], spreadRadius: 3),
      ],
    ),
    margin: EdgeInsets.only(left: 20, right: 20, top: 15),
    child: GestureDetector(
      child: _tileContent(selectedPeopleModel),
      onLongPress: _moreInfo,
    )
  );

  Widget _tileContent(SelectedPeopleModel selectedPeopleModel) => Ink(
    child: ListTile(
      leading: _tileImage(),
      title: _tileTitle(),
      subtitle: _tileSubTitle(),
      trailing: NotifyButton(widget._notifications, widget.person),
      onTap: () => _tileSelectionHandler(selectedPeopleModel),
    ),
  );

  // Person image
  Widget _tileImage() => CircleAvatar(
        backgroundImage: NetworkImage(widget.person['image']),
        radius: 30,
        onBackgroundImageError: (e, stackTrace) => print(e),
      );

  // Person Name
  Widget _tileTitle() => Text(
        widget.person['firstName'] + " " + widget.person['lastName'],
        style: TextStyle(color: Colors.white),
      );

  // Person Missing Since
  Widget _tileSubTitle() => FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DateFormat formatter = DateFormat(
              'MMMM dd, yyyy', snapshot.data.getString('language') ?? "en");
          return Text(
            formatter.format(DateTime.parse(widget.person['missingSince'])),
            style: TextStyle(color: Colors.white),
          );
        } else {
          return Text("Loading");
        }
      });
}
