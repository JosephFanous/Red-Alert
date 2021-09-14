import 'package:flutter/material.dart';

import '../breakdown_func.dart';
import 'data_table_source.dart';

class BreakdownTable extends StatefulWidget {
  final BreakdownFunc _breakdownFunc;
  final DataSource _dataSource = DataSource();

  BreakdownTable(this._breakdownFunc) {
    _dataSource.setSource(
      _breakdownFunc.byProvince.entries.toList(), "Province", "Location");
  }

  @override
  _BreakdownTableState createState() => _BreakdownTableState();
}

class _BreakdownTableState extends State<BreakdownTable> {
  bool _sortAscending = false;
  int _sortColumnIndex = 0;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  List<String> _locSources = ["Province", "City"];
  List<String> _dateSources = ["Year", "Month"];
  List<String> _category = ["Location", "Date"];

  void sort(int index, String colName, bool ascending) {
    setState(() {
      _sortColumnIndex = index;
      _sortAscending = ascending;
    });

    widget._dataSource.sort(colName, ascending);
  }

  void _onRowsPerPageChanged(r) => setState(() {
    _rowsPerPage = r;
  });

  void _categorySelector() => setState(() {
    _sortColumnIndex = 0;
    String _newSourceBy;
    String _curCategory = widget._dataSource.category == _category[0]
        ? _category[1]
        : _category[0];

    List breakdown;
    if (_curCategory == _category[0]) {
      _newSourceBy = _locSources[0];
      breakdown = widget._breakdownFunc.byProvince.entries.toList();
    } else {
      _newSourceBy = _dateSources[0];
      breakdown = widget._breakdownFunc.byYear.entries.toList();
    }

    widget._dataSource.setSource(breakdown, _newSourceBy, _curCategory);
  });

  void _sourceSelector() => setState(() {
    _sortColumnIndex = 0;
    String _newSourceBy;

    if (widget._dataSource.category == _category[0]) {
      _newSourceBy = widget._dataSource.sourceBy == _locSources[0]
          ? _locSources[1]
          : _locSources[0];
    } else if (widget._dataSource.category == _category[1]) {
      _newSourceBy = widget._dataSource.sourceBy == _dateSources[0]
          ? _dateSources[1]
          : _dateSources[0];
    }

    List breakdown;
    if (_newSourceBy == _locSources[0]) {
      breakdown = widget._breakdownFunc.byProvince.entries.toList();
    } else if (_newSourceBy == _locSources[1]) {
      breakdown = widget._breakdownFunc.byCity.entries.toList();
    } else if (_newSourceBy == _dateSources[0]) {
      breakdown = widget._breakdownFunc.byYear.entries.toList();
    } else if (_newSourceBy == _dateSources[1]) {
      breakdown = widget._breakdownFunc.byMonth.entries.toList();
    }

    widget._dataSource
        .setSource(breakdown, _newSourceBy, widget._dataSource.category);
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _dataTable(),
    );
  }

  Widget _dataTable() => PaginatedDataTable(
    header: Row(children: [
      Text("Under"),
      _categoryBtn(),
      Text("Show"),
      _sourceBtn(),
    ]),
    columns: widget._dataSource.category == _category[0]
        ? (widget._dataSource.sourceBy == _locSources[1]
            ? _provinceAndCityColumn()
            : _provineColumn())
        : (widget._dataSource.sourceBy == _dateSources[1]
            ? _yearAndMonthColumn()
            : _yearColumn()),
    source: widget._dataSource,
    onRowsPerPageChanged: _onRowsPerPageChanged,
    rowsPerPage: _rowsPerPage,
    sortAscending: _sortAscending,
    sortColumnIndex: _sortColumnIndex,
    columnSpacing: 0,
  );

  Widget _categoryBtn() => TextButton(
        onPressed: () => _categorySelector(),
        child: Text(widget._dataSource.category, textScaleFactor: 1.7),
      );

  Widget _sourceBtn() => TextButton(
        onPressed: () => _sourceSelector(),
        child: Text(widget._dataSource.sourceBy, textScaleFactor: 1.7),
      );

  List<DataColumn> _provinceAndCityColumn() => [
        _columnText("Province"),
        _columnText("City"),
        _columnNumber(),
      ];

  List<DataColumn> _provineColumn() => [
        _columnText("Province"),
        _columnNumber(),
      ];

  List<DataColumn> _yearAndMonthColumn() => [
        _columnText("Year"),
        _columnText("Month"),
        _columnNumber(),
      ];

  List<DataColumn> _yearColumn() => [
        _columnText("Year"),
        _columnNumber(),
      ];

  DataColumn _columnText(String cell) => DataColumn(
      label: Text(cell),
      onSort: (index, ascending) {
        sort(index, cell, ascending);
      });

  DataColumn _columnNumber() => DataColumn(
      label: Icon(Icons.people),
      numeric: true,
      onSort: (index, ascending) {
        sort(index, "Number", ascending);
      });
}
