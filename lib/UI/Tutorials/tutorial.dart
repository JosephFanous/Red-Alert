import 'package:flutter/material.dart';

import 'tutorial_actions.dart';

// Path for GIFs of how to use each functions in that page
class Paths {
  static Map get img => {
    'missingPersonPage': [
      {
        'name': 'Search Bar',
        'path': 'images/tutorials/missing_person/search.gif'
      },
      {
        'name': 'Calendar',
        'path': 'images/tutorials/missing_person/calendar.gif'
      },
      {
        'name': 'Long Press',
        'path': 'images/tutorials/missing_person/long_press.gif'
      },
      {
        'name': 'Map',
        'path': 'images/tutorials/missing_person/map_distance.gif'
      },
      {
        'name': 'Bell',
        'path': 'images/tutorials/missing_person/notifications.gif'
      },
      {
        'name': 'Save',
        'path': 'images/tutorials/missing_person/save_delete.gif'
      },
      {
        'name': 'About',
        'path': 'images/tutorials/about/about.gif',
      },
    ],
    'syncPage': [
      {
        'name': 'Tutorial',
        'path': 'images/tutorials/sync/sync.gif',
      },
    ],
    'mapPage': [
      {
        'name': 'Map',
        'path': 'images/tutorials/map/map.gif',
      },
    ],
    'breakdownPage': [
      {
        'name': 'Table',
        'path': 'images/tutorials/charts_data_table/data_table.gif'
      },
      {
        'name': 'Table',
        'path': 'images/tutorials/charts_data_table/charts.gif'
      },
    ],
  };
}

class TutorialDialog extends StatefulWidget {
  // parentScreen is the page that call this dialog
  final String parentScreen;
  final Map imgPaths = Paths.img;

  TutorialDialog(this.parentScreen);

  @override
  _TutorialDialogState createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  // the current gif
  double _curSliderVal = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.brown[400],
      title: _dialogTitle(),
      content: _dialogBody(),
      actions: [TutorialActions(widget.parentScreen)],
    );
  }

  // ----------------------------------------------
  // Dialog Tilte and Content
  Widget _dialogTitle() => Text(
      widget.imgPaths[widget.parentScreen][_curSliderVal.toInt()]['name'],
      style: TextStyle(color: Colors.white),
    );

  Widget _dialogBody() => Column(
    children: [
      Expanded(child: _image()),
      _slider(),
    ],
  );

  Widget _image() => Image.asset(
    widget.imgPaths[widget.parentScreen][_curSliderVal.toInt()]['path'],
    fit: BoxFit.cover,
  );

  // The carousel
  Widget _slider() => Slider(
    value: _curSliderVal,
    min: 0,
    max: widget.imgPaths[widget.parentScreen].length.toDouble() - 1,
    divisions: widget.imgPaths[widget.parentScreen].length == 1
        ? 1
        : widget.imgPaths[widget.parentScreen].length - 1,
    label: _curSliderVal.round().toString(),
    onChanged: (value) {
      setState(() {
        _curSliderVal = value;
      });
    },
  );
}
