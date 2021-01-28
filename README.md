# jo_tb_fl_chart

A custom wrapper around a FL line chart to allow time based swiping and interval size changes.

## Features

A simple lightweight widget that wraps an FL line chart and provides additional functionalities
like swipe left and right, and changing the visible time interval for a diagram.


## Getting Started

To use the widget's full functionality, you will have to leverage the chart controller (JOChartController) and the widget itself (JOTimeBasedSwipingLineChart).

Leverage the widget as shown below:

```dart
  @override
  Widget build(BuildContext context) {
    final data = _generateTestData(1000, 3);
    // map a time and one value from your datasource to a datapoint
    final datapoints = data.map((d) => JODataPoint(d.time, d.value1)).toList(); 
    // create a chart controller - with all datapoints
    // the widget will select sections of datapoints during scrolling
    final chartController = JOChartController(datapoints: datapoints, upperBound: 3500.0);
    // create the widget
    final diagram = JOTimeBasedSwipingLineChart(
      controller: chartController, // get time and relevant value from ALL your data
      swapAnimationDuration: const Duration(milliseconds: 250),
      lineColors: [Colors.purple],
      belowChartColors: [Colors.purple[200].withOpacity(0.3)],
      backgroundColor: Colors.white,
      axisColor: Colors.black,
      xAxisTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.0),
      yAxisTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
      yAxisLabelStepSize: 500.0,
      showLegend: true, // should display a legend (interval from / to within the diagram
      legendTextStyle: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
    );

    return ChangeNotifierProvider<JOChartController>.value(
      value: chartController, // make sure the widget gets re-built in case the time window is resized
      child: SafeArea(
        child: Column(
          children: [
            FlatButton(
              onPressed: () => chartController.size = 60 * 60 * 1000,
              child: Text('1 hour'),
              color: Colors.orange,
            ),
            FlatButton(
              onPressed: () => chartController.size = 24 * 60 * 60 * 1000,
              child: Text('1 day'),
              color: Colors.orange,
            ),
            SizedBox(height: 50.0),
            diagram, // leverage the widget in your widget tree
          ],
        ),
      ),
    );
```

   
