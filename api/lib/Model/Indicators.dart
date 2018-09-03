import 'dart:math' as math;

import 'package:api/Services/OHLCService.dart';

// TODO verify 14 vs 15 with test cases from table inside :
// http://cns.bu.edu/~gsc/CN710/fincast/Technical%20_indicators/Relative%20Strength%20Index%20(RSI).htm
class RSIIndicator
{
  var n;

  RSIIndicator([this.n = 14]);

  List<double> calculate(List<OHLCVItem> data)
  {
    var res = <double>[];

    for(int i = 0; i < data.length; i++) {
      if (i <= n)
        res.add(double.nan);
      else{
        var periodPrices = data.skip(i-n).take(n);
        res.add(_calculatePeriod(periodPrices));
      }
    }

    return res;
  }

  double _calculatePeriod(Iterable<OHLCVItem> closePrices)
  {
    double sumGain = 0.0;
    double sumLoss = 0.0;
    for (int i = 1; i < closePrices.length; i++)
    {
      var difference = closePrices.elementAt(i).close - closePrices.elementAt(i - 1).close;
      if (difference > 0)
        sumGain += difference;
      else
        sumLoss += difference.abs();
    }

    var averageGain = (sumGain/n);
    var averageLoss = (sumLoss/n);

    var relativeStrength = averageGain / averageLoss;

    return 100.0 - (100.0 / (1 + relativeStrength));
  }
}