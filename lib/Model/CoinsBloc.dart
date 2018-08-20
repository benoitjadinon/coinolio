import 'dart:async';

import 'package:coinolio/Services/OHLCService.dart';
import 'package:coinolio/Model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class CoinsBloc
{
  OHLCService _dataService;

  Stream<List<dynamic>> _coinChartData;
  Stream<List<dynamic>> get coinChartData => _coinChartData;

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
      _selectedCoin.asyncMap((c) => _dataService.getCoinDataHoursDynamic(Pair(null /* TODO */, c, Coin.dollar /* TODO */)))
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
