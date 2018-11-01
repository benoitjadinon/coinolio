import 'dart:async';

import 'package:api/Features/Chart/Indicators.dart';
import 'package:rxdart/rxdart.dart';

import 'package:api/Model/OHLCService.dart';
import '../../Model/model.dart';
import 'package:bloc/bloc.dart';

// EVENTS
abstract class HomeEvent {}
class HomeSelectCoinEvent extends HomeEvent {
  Coin coin;
  HomeSelectCoinEvent(this.coin);
}

// STATES
abstract class HomeState {
  String title;
  HomeState([this.title = "Coinolio"]){}
}
class HomeEmptyState extends HomeState {}
class HomeLoadingState extends HomeState {}
class HomeSelectedCoinState extends HomeState {
  Coin selectedCoin;
  List<OHLCVItem> ohlc;
  List<double> rsi;
  HomeSelectedCoinState(this.selectedCoin, this.ohlc, this.rsi)
      : super(/*super.title +" "+*/ selectedCoin.name);
}

// BLOC
class CoinsBloc extends EventStateBloc<HomeEvent, HomeState>
{
  final BaseOHLCService _dataService;
  final _rsiIndicator = RSIIndicator(14);

  Observable<List<Coin>> _coins;
  Stream<List<Coin>> get coins => _coins;

  CoinsBloc(this._dataService)
  {
    _coins = Observable.fromFuture(_dataService.getAllCoins())
      .map((l) => l.length > 20 ? l.sublist(0, 20) : l)
      .asBroadcastStream()
    ;

    var onSelectedCoin = Observable.merge([
      onEvent<HomeSelectCoinEvent>()
          .map((evt) => evt.event.coin),
      _coins
          .where((lst) => lst.isNotEmpty)
          .map((lst) => lst.first),
      ])
      .asBroadcastStream()
      ;

    var selectedCoinOHLCVData = onSelectedCoin
      .asyncMap((coin) {
        var r = _dataService.getCoinDataHours(Pair(null /* TODO */, coin, Coin.dollar /* TODO */));
        return r;
      })
      .asBroadcastStream();

    var coinRsi = selectedCoinOHLCVData
      .map(_rsiIndicator.calculate);
    /*
    var _subs = _coins
      .map((cs) => cs[0])
      .listen(_selectedCoin.add);
      */

    disposeWhenDone(
      //this.disposables.add()
      Observable.merge([
        onSelectedCoin.map((_) => HomeLoadingState() as HomeState),
        Observable.combineLatest3(
          onSelectedCoin,
          selectedCoinOHLCVData,
          coinRsi,
          (coin, ohlc, rsi) => HomeSelectedCoinState(coin, ohlc, rsi) //TODO
        ).cast<HomeState>(),
        ]
      )
      .startWith(HomeEmptyState())
      .listen(setState)
    );
  }

  @override
  void setState(HomeState state) {
    super.setState(state);
  }

  void dispose(){
    //_subs.cancel();
    super.dispose();
  }
}