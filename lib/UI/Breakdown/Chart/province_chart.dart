import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class ProvinceBarChart extends StatelessWidget {
  final Map breakdown;

  ProvinceBarChart(this.breakdown);

  List<Series<dynamic, String>> _createSeriesData() {
    return [
      Series<dynamic, String>(
        id: 'Default',
        measureFn: (var e, _) => e.value,
        data: breakdown.entries.toList(),
        colorFn: (_, __) => MaterialPalette.red.shadeDefault,
        domainFn: (var e, _) => e.key,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: BarChart(
        _createSeriesData(),
        animate: true,
        defaultRenderer: new BarRendererConfig(
            groupingType: BarGroupingType.grouped, strokeWidthPx: 2.0),
      ),
    );
  }
}
