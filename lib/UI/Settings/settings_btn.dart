import 'package:flutter/material.dart';

class SettingsBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings),
      tooltip: "Settings",
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/settings');
      },
    );
  }
}
