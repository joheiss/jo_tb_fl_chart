import 'package:intl/intl.dart';

import '../diagram_datapoint_model.dart';
import '../diagram_interval_model.dart';

class JODiagramController {
  JODiagramTimeInterval interval;
  List<JODataPoint> allDatapoints;
  List<JODataPoint> datapoints;
  final double lowerBound;
  final double upperBound;

  JODiagramController(this.datapoints, this.lowerBound, this.upperBound, int size) {
    _init(datapoints, lowerBound, upperBound, size);
  }

  static List<int> sizes = [
    JODiagramTimeInterval.hour,
    JODiagramTimeInterval.six_hours,
    JODiagramTimeInterval.twelve_hours,
    JODiagramTimeInterval.day,
    JODiagramTimeInterval.week,
    JODiagramTimeInterval.day * 30,
  ];

  static List<JODataPoint> buildFixedDataPoints(JODiagramTimeInterval interval) {
    final step = JODiagramController.getStepSize(interval.size);
    List<JODataPoint> datapoints = <JODataPoint>[];
    for (var t = interval.from; t < interval.to + step; t += step) {
      datapoints.insert(0, JODataPoint(t, 0));
    }
    return datapoints;
  }

  static bool checkToShowTitle(minValue, maxValue, sideTitles, appliedInterval, value) {
    if ((maxValue + 1 - minValue) % appliedInterval == 0) {
      return true;
    }
    return value != maxValue;
  }

  static double getEfficientInterval(JODiagramController controller) {
    return JODiagramController.getStepSize(controller.interval.size).toDouble() * 2;
  }

  static int getStepSize(int size) {
    int step = 1440;
    if (size == JODiagramTimeInterval.hour) step = 5;
    if (size == JODiagramTimeInterval.six_hours) step = 30;
    if (size == JODiagramTimeInterval.twelve_hours) step = 30;
    if (size == JODiagramTimeInterval.day) step = 60;
    if (size == JODiagramTimeInterval.week) step = 1440;
    return step * 60 * 1000;
  }

  static String mapChartLegend(JODiagramTimeInterval interval) {
    var legend = '';
    final startDate = DateTime.fromMillisecondsSinceEpoch(interval.from);
    final endDate = DateTime.fromMillisecondsSinceEpoch(interval.to);
    final formattedStartDate = DateFormat('dd.MM.yyyy kk:mm').format(startDate).replaceFirst('24:00', '00:00');
    final formattedEndDate = DateFormat('dd.MM.yyyy kk:mm').format(endDate);

    if (startDate.day == endDate.day && startDate.month == endDate.month && startDate.year == endDate.year) {
      legend = formattedStartDate + ' bis ' + formattedEndDate.substring(11);
    } else {
      legend = formattedStartDate + ' bis ' + formattedEndDate;
    }
    return legend;
  }

  static String mapTimeToLabel(JODiagramController controller, double value) {
    final step = JODiagramController.getStepSize(controller.interval.size);
    final time = value.toInt();
    return JODiagramController.mapTimeToPointLabel(time, step);
  }

  static String mapTimeToPointLabel(int t, int step) {
    final date = DateTime.fromMillisecondsSinceEpoch(t);
    final formatted = DateFormat('dd.MM.yyyy kk:mm').format(date).replaceFirst('24:00', '00:00');
    if (step < JODiagramTimeInterval.hour) return formatted.substring(11);
    if (step >= JODiagramTimeInterval.hour && step < JODiagramTimeInterval.day) return formatted.substring(11);
    if (step >= JODiagramTimeInterval.day) return formatted.substring(0, 2);
    return '';
  }

  void resizeInterval(int size) {
    final now = DateTime.now();
    interval.size = size;
    if (interval.size == JODiagramTimeInterval.hour) {
      interval.to = JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 5);
      interval.from = interval.to - interval.size + 1;
    }
    if (interval.size == JODiagramTimeInterval.six_hours) {
      interval.to = JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 15);
      interval.from = interval.to - interval.size + 1;
    }
    if (interval.size == JODiagramTimeInterval.twelve_hours) {
      interval.to = JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 30);
      interval.from = interval.to - interval.size + 1;
    }
    if (interval.size == JODiagramTimeInterval.day) {
      interval.to = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
      interval.from = DateTime(now.year, now.month, now.day, 0, 0, 0, 0).millisecondsSinceEpoch;
    }
    if (interval.size == JODiagramTimeInterval.week) {
      var date = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + (7 - now.weekday) * JODiagramTimeInterval.day);
      interval.to = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
      interval.from = DateTime(date.year, date.month, date.day - 6, 0, 0, 0, 0).millisecondsSinceEpoch;
    }
    if (interval.size > JODiagramTimeInterval.week) {
      interval.to = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
      interval.from = DateTime(now.year, now.month, 1, 0, 0, 0, 0).millisecondsSinceEpoch;
    }
    datapoints = _selectDataPointsForInterval();
  }

  void scrollDiagram(String direction) {
    if (direction == 'forward') interval = JODiagramTimeInterval.next(interval);
    if (direction == 'back') interval = JODiagramTimeInterval.previous(interval);
    datapoints = _selectDataPointsForInterval();
  }

  void _init(List<JODataPoint> datapoints, double lowerBound, double upperBound, int size) {
    interval = JODiagramTimeInterval(
      from: JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 5) -
          JODiagramTimeInterval.hour +
          1,
      to: JODiagramTimeInterval.justifyToMinutes(DateTime.now().millisecondsSinceEpoch, 5),
      size: size,
    );
    allDatapoints = datapoints;
    datapoints = allDatapoints.length > 0 ? _selectDataPointsForInterval() : <JODataPoint>[];
    lowerBound = lowerBound;
    upperBound = upperBound;
  }

  List<JODataPoint> _selectDataPointsForInterval() {
    // print('(TRACE) all datapoints: ${allDatapoints.length}');
    List<JODataPoint> selected =
        this.allDatapoints.where((m) => m.time >= interval.from && m.time <= interval.to).toList();
    // selected.forEach((d) => print('(TRACE) initially selected datapoints: ${d.time}, ${d.value}'));
    List<JODataPoint> elements = JODiagramController.buildFixedDataPoints(interval);
    int step = JODiagramController.getStepSize(interval.size);
    elements.forEach((d) {
      List<JODataPoint> inStep = selected.where((m) => d.time <= m.time && m.time <= d.time + step).toList();
      // print('(TRACE) Values in step: ${inStep.length}');
      int value = 0;
      inStep.forEach((m) => value += m.value);
      if (value > 0) value = value ~/ inStep.length;
      d.value = value;
      // print('(TRACE) Datapoint in selected interval: ${DateTime.fromMillisecondsSinceEpoch(d.time)}, ${d.value}');
    });
    // print('(TRACE) selected datapoints for interval: ${elements.length}');
    return elements;
  }
}
