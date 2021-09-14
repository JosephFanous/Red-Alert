import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/tutorial_database.dart';

class TutorialActions extends StatelessWidget {
  final TutorialModel tutorialModel = TutorialModel();
  final String parentScreen;

  TutorialActions(this.parentScreen);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _turnOnAllTutorialBtn(),
        _turnOffThisTutorialBtn(),
        _exitBtn(),
      ],
    );
  }

  // --------------------------------------------------------------

  Widget _turnOnAllTutorialBtn() => Builder(
    builder: (context) => TextButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          tutorialModel.turnOffAllTutorials();
          prefs.setBool("tutorial_on", false);
          Navigator.pop(context);
        },
        child: Row(children: [
          Icon(
            Icons.not_interested,
            color: Colors.red[900],
          ),
          Text(" All",
            style: TextStyle(
              color: Colors.white,
            )
          ),
        ]
      )
    )
  );

  Widget _turnOffThisTutorialBtn() => Builder(
    builder: (context) => TextButton(
        onPressed: () {
          tutorialModel.turnOffTutorialSettingFor(parentScreen);
          Navigator.pop(context);
        },
        child: Row(children: [
          Icon(
            Icons.not_interested,
            color: Colors.red[900],
          ),
          Text(" This",
            style: TextStyle(
              color: Colors.white,
            )
          ),
        ]
      )
    )
  );

  Widget _exitBtn() => Builder(
    builder: (context) => TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        "Skip",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    )
  );
}
