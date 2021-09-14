import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class YearTimeChart extends StatelessWidget {
  final Map breakdown;

  YearTimeChart(this.breakdown);

  List<Series<dynamic, DateTime>> _createSeriesData() {
    List sorted = breakdown.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return [
      Series<dynamic, DateTime>(
        id: 'Default',
        measureFn: (var e, _) => e.value,
        data: sorted,
        colorFn: (_, __) => MaterialPalette.red.shadeDefault,
        domainFn: (var e, _) => DateTime(int.parse(e.key)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: TimeSeriesChart(
        _createSeriesData(),
        animate: true,
      ),
    );
  }
}
