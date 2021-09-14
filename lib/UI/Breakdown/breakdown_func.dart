class BreakdownFunc {
  List people;
  Set<String> provinces = Set();
  Set<String> years = Set();

  String currentTable;

  Map<String, int> _ctiyStat = {};
  Map<String, int> _provinceStat = {};
  Map<String, int> _yearStat = {};
  Map<String, int> _monthStat = {};

  BreakdownFunc({this.people});

  // ----------------------------------------

  Map<String, int> get byCity {
    currentTable = 'City';

    if (_ctiyStat.isEmpty) {
      _ctiyStat = _getByCity();
    }
    return _ctiyStat;
  }

  Map<String, int> get byProvince {
    currentTable = 'Province';

    if (_provinceStat.isEmpty) {
      _provinceStat = _getByProvince();
    }
    return _provinceStat;
  }

  Map<String, int> get byYear {
    currentTable = 'Year';

    if (_yearStat.isEmpty) {
      _yearStat = _getByYear();
    }
    return _yearStat;
  }

  Map<String, int> get byMonth {
    currentTable = 'Month';

    if (_monthStat.isEmpty) {
      _monthStat = _getByMonth();
    }
    return _monthStat;
  }

  // ----------------------------------------

  Map<String, int> _getByCity() {
    Map<String, int> breakdown = {};

    for (Map person in people) {
      String location = person['province'] + "*" + person['city'];

      provinces.add(person['province']);

      if (!breakdown.containsKey(location)) {
        breakdown[location] = 0;
      }
      breakdown[location] += 1;
    }
    return breakdown;
  }

  Map<String, int> _getByProvince() {
    Map<String, int> breakdown = {};

    for (Map person in people) {
      String location = person['province'];

      if (!breakdown.containsKey(location)) {
        breakdown[location] = 0;
      }
      breakdown[location] += 1;
    }
    return breakdown;
  }

  Map<String, int> _getByYear() {
    Map<String, int> breakdown = {};

    for (Map person in people) {
      DateTime dateTime = DateTime.parse(person['missingSince']);
      String year = dateTime.year.toString();

      if (!breakdown.containsKey(year)) {
        breakdown[year] = 0;
      }
      breakdown[year] += 1;
    }
    return breakdown;
  }

  Map<String, int> _getByMonth() {
    Map<String, int> breakdown = {};

    for (Map person in people) {
      DateTime dateTime = DateTime.parse(person['missingSince']);
      String date = dateTime.year.toString() + "*" + dateTime.month.toString();

      years.add(dateTime.year.toString());

      if (!breakdown.containsKey(date)) {
        breakdown[date] = 0;
      }
      breakdown[date] += 1;
    }
    return breakdown;
  }
}
