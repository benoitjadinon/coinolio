import 'dart:async';

import 'package:api/Model/Indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import '../Services/OHLCService.dart';
import 'model.dart';

class CoinsBloc
{
  final OHLCService _dataService;
  final _rsiIndicator = RSIIndicator(14);

  Stream<List<OHLCVItem>> _coinChartData;
  Stream<List<OHLCVItem>> get coinChartData => _coinChartData;

  ReplaySubject<Coin> _selectedCoin = ReplaySubject(maxSize: 1);
  Stream<Coin> get selectedCoin => _selectedCoin;
  Sink<Coin> get selectCoin => _selectedCoin;

  Stream<List<Coin>> _coins;
  Stream<List<Coin>> get coins => _coins;

  Stream<List<double>> _coinRsi;
  Stream<List<double>> get coinRsi => _coinRsi;

  StreamSubscription<Coin> _subs;


  CoinsBloc(this._dataService)
  {
    _coins = Observable.fromFuture(_dataService.getAllCoins())
      .map((l) =>
      l.sublist(0, 20))
      .asBroadcastStream();

    _coinChartData = _selectedCoin
      .asyncMap((c) => _dataService.getCoinDataHours(Pair(null /* TODO */, c, Coin.dollar /* TODO */)))
      .asBroadcastStream();

    _coinRsi = _coinChartData
      /*.map((_) => [
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
      ])*/
      .map(_rsiIndicator.calculate);

    _subs = _coins
      .map((cs) => cs[0])
      .listen(_selectedCoin.add);
  }

  void dispose(){
    _subs.cancel();
    selectCoin.close();
    _selectedCoin.close();
  }
}
