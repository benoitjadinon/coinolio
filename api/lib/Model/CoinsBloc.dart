import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import '../Services/OHLCService.dart';
import 'model.dart';

class CoinsBloc
{
  OHLCService _dataService;

  Stream<List<OHLCVItem>> _coinChartData;
  Stream<List<OHLCVItem>> get coinChartData => _coinChartData;

  ReplaySubject<Coin> _selectedCoin = ReplaySubject(maxSize: 1);
  Stream<Coin> get selectedCoin => _selectedCoin;
  Sink<Coin> get selectCoin => _selectedCoin;

  Stream<List<Coin>> _coins;
  Stream<List<Coin>> get coins => _coins;

  StreamSubscription<Coin> _subs;

  CoinsBloc(this._dataService)
  {
    _coins = Observable.fromFuture(_dataService.getAllCoins())
        .map((l) =>
        l.sublist(0, 20))
        .asBroadcastStream()
    ;

    _coinChartData =
      //_selectedCoin.map((_) => null as List<dynamic>) // shows loading ?
      //.mergeWith([
      _selectedCoin.asyncMap((c) => _dataService.getCoinDataHours(Pair(null /* TODO */, c, Coin.dollar /* TODO */)))
      //])
        ;

    _subs = _coins
        .map((cs) =>
    cs[0])
        .listen(_selectedCoin.add);
  }

  void dispose(){
    _subs.cancel();
    selectCoin.close();
    _selectedCoin.close();
  }
}
