import 'package:flutter/widgets.dart';

class SelectedPeopleModel with ChangeNotifier {
  List<String> docIds = [];

  resetDocIds() {
    docIds = [];

    notifyListeners();
  }

  insertDocId(String id) {
    docIds.add(id);
  }

  removeDocId(String id) {
    docIds.remove(id);
  }

  List<String> getDocIds() {
    return docIds;
  }
}
