import 'package:api/Features/Chart/Indicators.dart';
import 'package:api/Model/model.dart';
import 'package:test/test.dart';
import 'package:api/Model/OHLCService.dart';

void main() {
  group('RSI', () {
    RSIIndicator rsiIndicator;

    setUp(() {
      rsiIndicator = RSIIndicator(14);
    });

    OHLCVItem getFakeItem(double close)
    => OHLCVItem()
      ..high = close+1
      ..low = close-2
      ..open = close-1
      ..volumeFrom = 1
      ..volume = 1;

    test('14th rsi is ok Test', () {

      var data= [
        getFakeItem(46.1250), // 0
        getFakeItem(47.1250), // 1
        getFakeItem(46.4375), // ...
        getFakeItem(46.9375),
        getFakeItem(44.9375),
        getFakeItem(44.2500),
        getFakeItem(44.6250),
        getFakeItem(45.7500),
        getFakeItem(47.8125),
        getFakeItem(47.5625),
        getFakeItem(47.0000),
        getFakeItem(44.5625),
        getFakeItem(46.3125),
        getFakeItem(47.6875),
        getFakeItem(46.6875), // 14
        getFakeItem(45.6875), // 15
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
