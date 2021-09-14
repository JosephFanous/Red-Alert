import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class MonthTimeChart extends StatefulWidget {
  final Map breakdown;
  final List<String> years;

  MonthTimeChart(this.breakdown, this.years);

  @override
  _MonthTimeChartState createState() => _MonthTimeChartState();
}

class _MonthTimeChartState extends State<MonthTimeChart> {
  String selectedYear = '';

  List<charts.Series<dynamic, DateTime>> _createSeriesData() {
    List sorted = widget.breakdown.entries
        .toList()
        .where((e) => e.key.contains(selectedYear))
        .toList()
          ..sort((a, b) {
            int monthA = int.parse(a.key.split("*")[1]);
            int monthB = int.parse(b.key.split("*")[1]);

            return monthA.compareTo(monthB);
          });
    return [
      charts.Series<dynamic, DateTime>(
        id: 'Default',
        measureFn: (var e, _) => e.value,
        domainFn: (var e, _) => DateTime(
          int.parse(selectedYear),
          int.parse(e.key.split("*")[1]),
        ),
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        data: sorted,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (selectedYear.isEmpty) {
      selectedYear = widget.years.first;
    }
    return Column(
      children: [
        _dropDownList(),
        _timeChart(),
      ],
    );
  }

  Widget _dropDownList() => DropdownButton(
        items: widget.years
            .map((String e) => DropdownMenuItem(
                  child: Text(e),
                  value: e,
                ))
            .toList(),
        value: selectedYear,
        onChanged: (e) => setState(() {
          selectedYear = e;
        }),
      );

  Widget _timeChart() => Expanded(
          child: charts.TimeSeriesChart(
        _createSeriesData(),
        animate: true,
      ));
}
