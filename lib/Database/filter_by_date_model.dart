import 'package:flutter/widgets.dart';

class DateModel with ChangeNotifier {
  DateTime date;

  setDate(DateTime newDate) {
    date = newDate;
    notifyListeners();
  }

  DateTime getDate() {
    return date;
  }
}
