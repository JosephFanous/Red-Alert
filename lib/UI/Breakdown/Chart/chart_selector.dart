import 'package:flutter/material.dart';

import '../breakdown_func.dart';

import 'province_chart.dart';
import 'month_chart.dart';
import 'city_chart.dart';
import 'year_chart.dart';

class ChartSelector extends StatelessWidget {
  final BreakdownFunc _breakdownFunc;

  ChartSelector(this._breakdownFunc);

  @override
  Widget build(BuildContext context) {
    if (_breakdownFunc.currentTable == 'Province') {
      return ProvinceBarChart(_breakdownFunc.byProvince);
    } else if (_breakdownFunc.currentTable == 'City') {
      return CityBarChart(
        _breakdownFunc.byCity,
        _breakdownFunc.provinces,
      );
    } else if (_breakdownFunc.currentTable == 'Year') {
      return YearTimeChart(_breakdownFunc.byYear);
    } else if (_breakdownFunc.currentTable == 'Month') {
      List sorted = _breakdownFunc.years.toList()..sort();
      return MonthTimeChart(
        _breakdownFunc.byMonth,
        sorted.reversed.toList(),
      );
    }

    return Text("ERROR: No Chart");
  }
}
