import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calendar.dart';
import 'missing_person_list.dart';

import '../Settings/settings_btn.dart';
import '../drawer.dart';
import '../Search Bar/search_bar.dart';
import '../are_you_sure_you_want_to_exit.dart';
import '../Tutorials/tutorial.dart';

import '../Notifications/notification.dart';

import '../../Database/saved_people_database.dart';
import '../../Database/selected_item_model.dart';
import '../../Database/tutorial_database.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

class NotificationsNum {
  int num = 0;
}

// Missing Person Initial Page
class MissingPerson extends StatelessWidget {
  final Notifications _notifications = Notifications();
  final NotificationsNum notificationsNum = NotificationsNum();
  final TutorialModel tutorialModel = TutorialModel();

  void _tutorial(BuildContext context) async {
    bool showTutorial =
        await tutorialModel.getTutorialSettingFor("missingPersonPage");
    if (showTutorial) {
      await showDialog(
        context: context,
        child: TutorialDialog("missingPersonPage"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _notifications.init(scaffoldContext: context);
    _tutorial(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "drawer.missing_persons")),
        actions: [
          savedButton(),
          SettingsBtn(),
        ],
      ),
      drawer: DrawerMenu(),
      backgroundColor: Colors.brown[900],
      body: _areYourSureYouWantToExitWarpper(),
    );
  }

  Widget _areYourSureYouWantToExitWarpper() => Builder(
    builder: (context) => WillPopScope(
        child: _body(),
        onWillPop: () async {
          bool value = await showDialog<bool>(
              context: context, builder: (context) => ExitDialog());
          return value;
        }
      )
    );

  Widget _body() => Column(
    children: [
      Row(children: [
        SearchBar(),
        Calendar(),
      ]),
      MissingPersonList(
        _notifications,
        notificationsNum,
      ),
    ],);

  // ------------------------------------------------------------

  // Save button for saving people to local list
  Widget savedButton() => Builder(builder: (context) {
    final SavedPeopleModel savedPeopleModel =
        Provider.of<SavedPeopleModel>(context);
    final SelectedPeopleModel selectedPeopleModel =
        Provider.of<SelectedPeopleModel>(context);

    return IconButton(
      icon: Icon(Icons.save),
      tooltip: "Settings",
      onPressed: () async {
        var snackBar =
            SnackBar(content: Text('Please first click on someone'));
        List<String> ids = selectedPeopleModel.getDocIds();

        if (ids.length > 0) {
          snackBar = SnackBar(content: Text('Saved'));

          for (String id in ids) {
            SavedPerson person = SavedPerson(id);
            var result = await savedPeopleModel.insertPeople(person);

            if (result != null) {
              snackBar = SnackBar(
                  content: Text('One Of The Item Is Already Saved'));
            }
          }
          selectedPeopleModel.resetDocIds();
        }
        Scaffold.of(context).showSnackBar(snackBar);
      },
    );
  });
}
