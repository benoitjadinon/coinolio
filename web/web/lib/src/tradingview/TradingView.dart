/// https://www.tradingview.com/widget/advanced-chart/
/// https://github.com/tradingview/charting-library-examples/blob/master/angular5/src/app/tv-chart-container/tv-chart-container.component.ts
/// https://dev.to/graphicbeacon/how-to-use-javascript-libraries-in-your-dart-applications--4mc6
/// 
@JS() //TODO context namespace, defaults to `window` (should be "TradingView" here)
library tv.js;

import "package:js/js.dart";

@JS("TradingView.widget") //TODO can be ommited if name same (and Tradingview is moved above)
class widget {
  external factory widget(WidgetOptions options);
  /*widgetz({String symbol}){ ????
    widget(new WidgetOptions()..symbol=symbol);
  }*/
}

@anonymous
@JS()
class WidgetOptions //TODO rename to ChartingLibraryWidgetOptions
{
  //TODO 
  //external factory WidgetOptions({ symbol, container_id, autosize, interval }); // .widget(WidgetOptions(symbol:'AAPL'))

  external String get symbol;
  external set symbol(String b);

  external String get container_id;
  external set container_id(String b);

  external bool get autosize;
  external set autosize(bool b);

  external String get interval;
  external set interval(String b);
}

class TimeInterval
{
  static const TimeInterval M1 =  const TimeInterval(1);
  static const TimeInterval M3 =  const TimeInterval(3);
  static const TimeInterval M5 =  const TimeInterval(5);
  static const TimeInterval M15 = const TimeInterval(15);
  static const TimeInterval M30 = const TimeInterval(30);
  static const TimeInterval H =   const TimeInterval(60);
  static const TimeInterval H2 =  const TimeInterval(120);
  static const TimeInterval H3 =  const TimeInterval(180);
  static const TimeInterval H4 =  const TimeInterval(240);
  static const TimeInterval D =   const TimeInterval("D");
  static const TimeInterval W =   const TimeInterval("W");

  final dynamic id;

  const TimeInterval(this.id);

  @override
  String toString() => id.toString();
}
