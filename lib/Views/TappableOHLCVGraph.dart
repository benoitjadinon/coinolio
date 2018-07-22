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
        _lastPrice = calcultePrice(local.dy, graph.volumeProp, getBox.paintBounds);
      },
      onLongPress: () {
        //setState(() {  });
        print(_lastPrice);
      },
      child: new Container(
        child: (graph = OHLCVGraph(
        data: _coinChartData,
        enableGridLines: true,
        volumeProp: 15/100,
        labelPrefix: "€",
        gridLineAmount: 10,
        gridLineColor: Colors.grey[300],
        gridLineLabelColor: Colors.grey,
        )),
      ),
    );
  }

  double calcultePrice(double y, double perc, Rect paintBounds)
  {
    var h = (paintBounds.height -(paintBounds.height * perc));
    var posPerc = (y / h);
    return ((_max - _min) * (1-posPerc)) + _min;
  }
}