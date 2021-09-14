import 'package:flutter/material.dart';

// Wrapper for each page exit
// Helping the user from accidentally pressing the back button and exiting the app
class ExitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _dialogTitle(),
      actions: [
        _noBtn(),
        _yesBtn(),
      ],
      backgroundColor: Colors.brown,
    );
  }

  Widget _dialogTitle() => Text(
    'Are you sure you want to exit?',
    style: TextStyle(color: Colors.white),
  );

  Widget _noBtn() => Builder(
    builder: (context) => FlatButton(
      child: Text(
        'No',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.of(context).pop(false),
    ),
  );

  Widget _yesBtn() => Builder(
    builder: (context) => FlatButton(
      child: Text(
        'Yes, exit',
        style: TextStyle(color: Colors.red[400]),
      ),
      onPressed: () => Navigator.of(context).pop(true),
    )
  );
}
