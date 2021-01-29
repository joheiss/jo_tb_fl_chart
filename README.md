# jo_tb_fl_chart

A custom wrapper around a FL line chart to allow time based swiping and interval size changes.

## Features

A simple lightweight widget that wraps an FL line chart and provides additional functionalities
like swipe left and right, and changing the visible time interval for a diagram.


## Getting Started

To use the widget's full functionality, you will have to leverage the chart controller (JOChartControllerRx) and the widget itself (JOTimeBasedSwipingLineChart).

Leverage the widget as shown below:

```dart
  @override
  Widget build(BuildContext context) {
    final data = _generateTestData(10000, 3);
    final datapoints = data.map((d) => JODataPoint(d.time, d.value1.toDouble())).toList();
    final chartController = JOChartControllerRx(datapoints: datapoints, upperBound: 3500.0);
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
      legendTextStyle: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
    );

    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () => chartController.size = 60 * 60 * 1000,
                child: Text('1 hour'),
                color: Colors.purple[200],
              ),
              SizedBox(width: 20.0),
              FlatButton(
                onPressed: () => chartController.size = 24 * 60 * 60 * 1000,
                child: Text('1 day'),
                color: Colors.purple[200],
              ),
              SizedBox(width: 20.0),
              FlatButton(
                onPressed: () => chartController.size = 7 * 24 * 60 * 60 * 1000,
                child: Text('1 week'),
                color: Colors.purple[200],
              ),                
            ],
          ),
          SizedBox(height: 50.0),
          diagram,
        ],
      ),
    );
  }
```

   
