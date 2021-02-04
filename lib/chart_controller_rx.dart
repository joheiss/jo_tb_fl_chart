import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:rxdart/rxdart.dart';

import 'diagram_interval_model.dart';

class JODataPoint {
  final int time;
  double value;

  JODataPoint(this.time, this.value);
}

class JOChartControllerRx {
  List<JODataPoint> _allDatapoints;
  List<JODataPoint> _datapoints;
  int _start;
  int _end;
  int _size;
  double _lowerBound;
  double _upperBound;
  String _legend;

  final _hasChanged = BehaviorSubject<bool>();

  JOChartControllerRx(
      {List<JODataPoint> datapoints,
      int size = 0,
      int start = 0,
      int end = 0,
      double lowerBound = 0.0,
      double upperBound}) {
    _allDatapoints = datapoints;
    _start = start;
    _end = end;
    _size = size;
    _lowerBound = lowerBound;
    _upperBound = upperBound;

    if (_size == 0) _size = 60 * 60 * 1000; // 1 hour
    if (_end == 0) _end = DateTime.now().millisecondsSinceEpoch;
    if (_start == 0) _start = _end - _size + 1;
    // print('(TRACE) JOChartController --> size: $_size, start: $_start, end: $_end');
    _datapoints = _allDatapoints.length > 0 ? _selectDataPointsForInterval() : <JODataPoint>[];
  }

  Stream<bool> get hasChanged => _hasChanged;

  int get size => _size;
  set size(int milliseconds) {
    _size = milliseconds;
    _start = _end - _size + 1;
    _resizeInterval();
  }

  int get start => _start;
  set start(int milliseconds) {
    _start = milliseconds;
    _end = _start + _size;
  }

  int get end => _end;
  set end(int milliseconds) {
    _end = milliseconds;
    _start = _end - _size + 1;
  }

  double get lowerBound => _lowerBound;
  double get upperBound => _upperBound;
  String get legend => _legend;

  bool checkToShowTitle(minValue, maxValue, sideTitles, appliedInterval, value) {
    if ((maxValue + 1 - minValue) % appliedInterval == 0) {
      return true;
    }
    return value != maxValue;
  }

  double getEfficientInterval() {
    return _getStepSize().toDouble() * 2;
  }

  String _mapChartLegend() {
    var legend = '';
    final startDate = DateTime.fromMillisecondsSinceEpoch(_start);
    final endDate = DateTime.fromMillisecondsSinceEpoch(_end);
    final formattedStartDate = DateFormat('dd.MM.yyyy kk:mm').format(startDate).replaceFirst('24:00', '00:00');
    final formattedEndDate = DateFormat('dd.MM.yyyy kk:mm').format(endDate);

    if (startDate.day == endDate.day && startDate.month == endDate.month && startDate.year == endDate.year) {
      legend = formattedStartDate + ' bis ' + formattedEndDate.substring(11);
    } else {
      legend = formattedStartDate + ' bis ' + formattedEndDate;
    }
    return legend;
  }

  String mapTimeToLabel(double value) {
    final step = _getStepSize();
    final time = value.toInt();
    return _mapTimeToPointLabel(time, step);
  }

  List<FlSpot> mapDataPointsToSpots() {
    // print('(TRACE) Map datapoints to spots: ${_controller.datapoints.length}');
    // _controller.datapoints.forEach((d) => print('TRACE) ${DateTime.fromMillisecondsSinceEpoch(d.time)}, ${d.value}'));
    return _datapoints.map((d) => FlSpot(d.time.toDouble(), d.value)).toList();
  }

  void scrollDiagram(String direction) {
    if (direction == 'forward') _next();
    if (direction == 'back') _previous();
    _datapoints = _selectDataPointsForInterval();
  }

  List<JODataPoint> _buildFixedDataPoints() {
    final step = _getStepSize();
    List<JODataPoint> datapoints = <JODataPoint>[];
    for (var t = _start; t < _end + step; t += step) {
      datapoints.insert(0, JODataPoint(t, 0.0));
    }
    return datapoints;
  }

  int _getStepSize() {
    int step = 1440 * 60 * 1000;
    if (_size <= JODiagramTimeInterval.second)
      step = 50;
    else if (_size <= JODiagramTimeInterval.minute)
      step = 5 * 1000;
    else if (_size <= JODiagramTimeInterval.hour)
      step = 5 * 60 * 1000;
    else if (_size <= JODiagramTimeInterval.six_hours)
      step = 30 * 60 * 1000;
    else if (_size <= JODiagramTimeInterval.twelve_hours)
      step = 30 * 60 * 1000;
    else if (_size <= JODiagramTimeInterval.day)
      step = 60 * 60 * 1000;
    else if (_size <= JODiagramTimeInterval.week) step = 1440 * 60 * 1000;
    // else if (_size <=  JODiagramTimeInterval.month) step = 1440 * 60 * 1000;
    // else if (_size <=  JODiagramTimeInterval.year) step = 31 * 1440 * 60 * 1000;
    return step;
  }

  String _mapTimeToPointLabel(int t, int step) {
    final date = DateTime.fromMillisecondsSinceEpoch(t);
    final formatted = DateFormat('dd.MM.yyyy kk:mm:ss.SSS').format(date).replaceFirst('24:00', '00:00');
    if (step < JODiagramTimeInterval.second)
      return formatted.substring(20, 23);
    else if (step < JODiagramTimeInterval.minute)
      return formatted.substring(17, 19);
    else if (step <= JODiagramTimeInterval.hour)
      return formatted.substring(11, 16);
    else if (step >= JODiagramTimeInterval.day) return formatted.substring(0, 2);
    return '';
  }

  void _next() {
    if (_size <= JODiagramTimeInterval.week) {
      _start = _start + _size;
      _end = _end + _size;
    } else {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(_start);
      _start = DateTime(date.year, date.month + 1, 1).millisecondsSinceEpoch;
      _end = DateTime(date.year, date.month + 1, 0).millisecondsSinceEpoch;
    }
  }

  void _previous() {
    if (_size <= JODiagramTimeInterval.week) {
      _start = _start - _size;
      _end = _end - _size;
    } else {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(_start);
      _start = DateTime(date.year, date.month - 1, 1).millisecondsSinceEpoch;
      _end = DateTime(date.year, date.month - 1, 0).millisecondsSinceEpoch;
    }
  }

  void _resizeInterval() {
    final now = DateTime.now();
    if (_size <= JODiagramTimeInterval.hour) {
      _end = JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 5);
      _start = _end - _size + 1;
    }
    if (_size == JODiagramTimeInterval.six_hours) {
      _end = JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 15);
      _start = _end - _size + 1;
    }
    if (_size == JODiagramTimeInterval.twelve_hours) {
      _end = JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 30);
      _start = _end - _size + 1;
    }
    if (_size == JODiagramTimeInterval.day) {
      _end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
      _start = DateTime(now.year, now.month, now.day, 0, 0, 0, 0).millisecondsSinceEpoch;
    }
    if (_size == JODiagramTimeInterval.week) {
      var date = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + (7 - now.weekday) * JODiagramTimeInterval.day);
      _end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
      _start = DateTime(date.year, date.month, date.day - 6, 0, 0, 0, 0).millisecondsSinceEpoch;
    }
    if (_size > JODiagramTimeInterval.week) {
      _end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
      _start = DateTime(now.year, now.month, 1, 0, 0, 0, 0).millisecondsSinceEpoch;
    }
    _datapoints = _selectDataPointsForInterval();
  }

  List<JODataPoint> _selectDataPointsForInterval() {
    // print('(TRACE) all datapoints: ${_allDatapoints.length}');
    // print('(TRACE) start: $_start, end: $_end, size: $_size');
    List<JODataPoint> selected = _allDatapoints.where((m) => m.time >= _start && m.time <= _end).toList();
    // selected.forEach((d) => print('(TRACE) initially selected datapoints: ${d.time}, ${d.value}'));
    List<JODataPoint> elements = _buildFixedDataPoints();
    int step = _getStepSize();
    elements.forEach((d) {
      List<JODataPoint> inStep = selected.where((m) => d.time <= m.time && m.time <= d.time + step).toList();
      // print('(TRACE) Values in step: ${inStep.length}');
      double value = 0.0;
      inStep.forEach((m) => value += m.value);
      if (value > 0) value = value / inStep.length;
      d.value = value;
      // print('(TRACE) Datapoint in selected interval: ${DateTime.fromMillisecondsSinceEpoch(d.time)}, ${d.value}');
    });
    _legend = _mapChartLegend();
    // print('(TRACE) selected datapoints for interval: ${elements.length}');
    _hasChanged.add(true);
    return elements;
  }

  void dispose() {
    _hasChanged.close();
  }
}
