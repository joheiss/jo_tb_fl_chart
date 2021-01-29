library jo_tb_fl_chart;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:swipe_gesture_recognizer/swipe_gesture_recognizer.dart';
import 'chart_controller_rx.dart';

class JOTimeBasedSwipingLineChart extends StatefulWidget {
  final JOChartControllerRx controller;
  final Duration swapAnimationDuration;
  final List<Color> lineColors;
  final List<Color> belowChartColors;
  final Color backgroundColor;
  final Color axisColor;
  final TextStyle xAxisTextStyle;
  final TextStyle yAxisTextStyle;
  final double yAxisLabelStepSize;
  final bool showLegend;
  final TextStyle legendTextStyle;

  JOTimeBasedSwipingLineChart(
      {@required this.controller,
      this.swapAnimationDuration = const Duration(milliseconds: 0),
      this.lineColors,
      this.belowChartColors,
      this.backgroundColor,
      this.axisColor,
      this.xAxisTextStyle,
      this.yAxisTextStyle,
      this.yAxisLabelStepSize,
      this.showLegend = true,
      this.legendTextStyle})
      : super();

  @override
  _JOTimeBasedSwipingLineChartState createState() => _JOTimeBasedSwipingLineChartState();
}

class _JOTimeBasedSwipingLineChartState extends State<JOTimeBasedSwipingLineChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeGestureRecognizer(
      onSwipeLeft: () {
        setState(() {
          widget.controller.scrollDiagram('forward');
        });
      },
      onSwipeRight: () {
        setState(() {
          widget.controller.scrollDiagram('back');
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: _buildChartContainer(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(BuildContext context) {
    List<Widget> children = <Widget>[];
    children.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 5.0),
              child: StreamBuilder<bool>(
                stream: widget.controller.hasChanged,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  return LineChart(
                    _buildLineChart(context, widget.controller),
                    swapAnimationDuration: widget.swapAnimationDuration,
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.showLegend) {
      children.add(
        StreamBuilder<bool>(
          stream: widget.controller.hasChanged,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return Container(
              margin: EdgeInsets.only(top: 20.0),
              alignment: Alignment.topCenter,
              child: Text(
                widget.controller.legend,
                style: widget.legendTextStyle,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      );
    }
    return Stack(
      children: children,
    );
  }

  LineChartData _buildLineChart(BuildContext context, JOChartControllerRx controller) {
    return LineChartData(
      backgroundColor: widget.backgroundColor,
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: false, // true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: widget.axisColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: widget.axisColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: controller.getEfficientInterval(),
          checkToShowTitle: controller.checkToShowTitle,
          getTextStyles: (value) => widget.xAxisTextStyle,
          getTitles: (value) => controller.mapTimeToLabel(value),
          margin: 8.0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTextStyles: (value) => widget.yAxisTextStyle,
          getTitles: (value) => _mapYAxisLabels(value),
          margin: 8.0,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Color(0xff37434d)),
      ),
      minX: controller.start.toDouble() ?? 0.0,
      maxX: controller.end.toDouble() ?? 0.0,
      minY: controller.lowerBound,
      maxY: controller.upperBound,
      lineBarsData: [
        LineChartBarData(
          spots: controller.mapDataPointsToSpots(),
          isCurved: true,
          colors: widget.lineColors,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: widget.belowChartColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  String _mapYAxisLabels(double value) {
    if (value % widget.yAxisLabelStepSize == 0) return value.toInt().toString();
    return '';
  }
}
