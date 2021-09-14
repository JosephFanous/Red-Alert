import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class CityBarChart extends StatefulWidget {
  final Map breakdown;
  final Set<String> provinces;

  CityBarChart(this.breakdown, this.provinces);

  @override
  _CityBarChartState createState() => _CityBarChartState();
}

class _CityBarChartState extends State<CityBarChart> {
  String selectedProvince = '';

  List<charts.Series<dynamic, String>> _createSeriesData() {
    return [
      charts.Series<dynamic, String>(
        id: 'Default',
        measureFn: (var e, _) => e.value,
        domainFn: (var e, _) => e.key.split("*")[1],
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        data: widget.breakdown.entries
            .toList()
            .where((e) => e.key.contains(selectedProvince))
            .toList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (selectedProvince.isEmpty) {
      selectedProvince = widget.provinces.first;
    }
    return Column(
      children: [
        _dropDownList(),
        _pieChart(),
      ],
    );
  }

  Widget _dropDownList() => DropdownButton(
    items: widget.provinces
        .map((String e) => DropdownMenuItem(
              child: Text(e),
              value: e,
            ))
        .toList(),
    value: selectedProvince,
    onChanged: (e) => setState(() {
      selectedProvince = e;
    }),
  );

  Widget _pieChart() => Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 1000,
        padding: EdgeInsets.all(8),
        child: charts.PieChart(
          _createSeriesData(),
          animate: true,
          defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 110,
            arcRendererDecorators: [
              new charts.ArcLabelDecorator(
                labelPosition: charts.ArcLabelPosition.outside,
              )
            ],
          ),
        ),
      ),
    )
  );
}
