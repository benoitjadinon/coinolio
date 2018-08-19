import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';

class TappableOHLCVGraph extends StatefulWidget
{
  final List _coinChartData;
  TappableOHLCVGraph(this._coinChartData);

  @override
  ActivityState createState() => new ActivityState(_coinChartData);
}

class ActivityState extends State<TappableOHLCVGraph>
{
  List _coinChartData;

  double _min;
  double _max;
  //double _maxVolume;

  ActivityState(this._coinChartData){
    _min = double.infinity;
    _max = -double.infinity;
    //_maxVolume = -double.infinity;
    for (var i in _coinChartData) {
      if (i["high"] > _max) {
        _max = i["high"].toDouble();
      }
      if (i["low"] < _min) {
        _min = i["low"].toDouble();
      }
      //if (i["volumeto"] > _maxVolume) {
      //  _maxVolume = i["volumeto"].toDouble();
      //}
    }
  }

  @override
  Widget build(BuildContext context)
  {
    OHLCVGraph graph;
    double _lastPrice;

    return GestureDetector(
      onTapDown: (a) {
        RenderBox getBox = context.findRenderObject();
        var local = getBox.globalToLocal(a.globalPosition);
        _lastPrice = calculatePrice(local.dy, graph.volumeProp, getBox.paintBounds);
      },
      onLongPress: () {
        //setState(() {  });
        print(_lastPrice);
      },
      child: new Container(
        height: 300.0,
        color: new Color.fromARGB(255, 45, 45, 45),
        child: (
          graph = OHLCVGraph(
            data: _coinChartData,
            enableGridLines: true,
            volumeProp: 15/100,
            labelPrefix: "\$",
            gridLineAmount: 10,
            gridLineWidth: 0.0,
            gridLineColor: Colors.grey[300],
            gridLineLabelColor: Colors.grey,
            decreasePaint: new Paint()
              ..color = Colors.red
              ..strokeWidth = 1.0
              ..style = PaintingStyle.fill
            ,
            increasePaint: new Paint()
              ..color = Colors.green
              ..strokeWidth = 1.0
              ..style = PaintingStyle.fill
            ,
            volumePaint: new Paint()
              ..color = new Color.fromARGB(15, 255, 255, 255)
              ..style = PaintingStyle.fill,
            candleSpacing: 1.2,
          )),
      ),
    );
  }

  double calculatePrice(double y, double perc, Rect paintBounds)
  {
    var h = (paintBounds.height -(paintBounds.height * perc));
    var posPerc = (y / h);
    return ((_max - _min) * (1-posPerc)) + _min;
  }
}