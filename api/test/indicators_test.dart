import 'package:api/Features/Chart/Indicators.dart';
import 'package:test/test.dart';
import 'package:api/Features/Chart/OHLCService.dart';

void main() {
  group('RSI', () {
    RSIIndicator rsiIndicator;

    setUp(() {
      rsiIndicator = RSIIndicator(14);
    });

    test('14th rsi is ok Test', () {

      var data= [
        OHLCVItem.fromClose(46.1250), // 0
        OHLCVItem.fromClose(47.1250), // 1
        OHLCVItem.fromClose(46.4375), // ...
        OHLCVItem.fromClose(46.9375),
        OHLCVItem.fromClose(44.9375),
        OHLCVItem.fromClose(44.2500),
        OHLCVItem.fromClose(44.6250),
        OHLCVItem.fromClose(45.7500),
        OHLCVItem.fromClose(47.8125),
        OHLCVItem.fromClose(47.5625),
        OHLCVItem.fromClose(47.0000),
        OHLCVItem.fromClose(44.5625),
        OHLCVItem.fromClose(46.3125),
        OHLCVItem.fromClose(47.6875),
        OHLCVItem.fromClose(46.6875), // 14
        OHLCVItem.fromClose(45.6875), // 15
      ];

      var expct = [
        51.779,
        48.477
      ];

      expect(rsiIndicator.calculate(data)[14], expct[0]);
      expect(rsiIndicator.calculate(data).last, expct.last);
    });
  });
}
