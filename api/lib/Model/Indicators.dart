import 'dart:math' as math;

import 'package:api/Services/OHLCService.dart';

// TODO verify 14 vs 15 with test cases from table inside :
// http://cns.bu.edu/~gsc/CN710/fincast/Technical%20_indicators/Relative%20Strength%20Index%20(RSI).htm
class RSIIndicator
{
  var n;

  double averageGain;
  double averageLoss;

  RSIIndicator([this.n = 14]);

  List<double> calculate(List<OHLCVItem> data)
  {
    var res = <double>[];

    for(int i = 0; i < data.length; i++) {
      if (i < n)
        res.add(double.nan);
      else if (i == n)
      {
        /*var tuple = */_calculateRsi(data.skip(0).take(n+1), n);
        var relativeStrength = averageGain / averageLoss;
        res.add(100.0 - (100.0 / (1 + relativeStrength)));
      }
      else
      {
        var periodPrices = data.skip(i-1).take(2);
        var smoothedRS = _calculatePeriod(periodPrices, i, n);
        res.add(100.0 - (100.0 / (1 + smoothedRS)));

        _calculateRsi(data.take(i+1), i);
      }
    }

    return res;
  }

  void _calculateRsi(Iterable<OHLCVItem> closePrices, [n = 14])
  {
    double sumGain = 0.0;
    double sumLoss = 0.0;

    for (int i = 1; i <= n; i++)
    {
      var difference = closePrices.elementAt(i).close - closePrices.elementAt(i - 1).close;
      if (difference > 0)
        sumGain += difference;
      else
        sumLoss += difference.abs();
    }

    averageGain = sumGain / n;
    averageLoss = sumLoss / n;
  }

  double _calculatePeriod(Iterable<OHLCVItem> closePrices, int i, [n = 14])
  {
    double sumGain = 0.0;
    double sumLoss = 0.0;

    for (int i = 1; i < 2; i++)
    {
      var difference = closePrices.elementAt(i).close - closePrices.elementAt(i - 1).close;
      if (difference > 0)
        sumGain = difference;
      else
        sumLoss = difference.abs();
    }

    return ((averageGain * (i-2) + sumGain) / (i-1)) /
           ((averageLoss * (i-2) + sumLoss) / (i-1));
  }
}