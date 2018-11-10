import 'dart:async';

import 'package:api/Features/Chart/Indicators.dart';
import 'package:api/api_keys.dart';
import 'package:rxdart/rxdart.dart';
import 'package:api/Model/OHLCService.dart';
import 'package:bloc/bloc.dart';

import '../../Model/model.dart';

// EVENTS
abstract class HomeEvent {}
class HomeSelectCoinEvent extends HomeEvent {
  Pair pair;
  HomeSelectCoinEvent(this.pair);
}

// STATES
abstract class HomeState {
  String title;
  HomeState([this.title = "Coinolio"]);
}
class HomeEmptyState extends HomeState {}
class HomeLoadingState extends HomeState {}
class HomeSelectedCoinState extends HomeState {
  Pair selectedCoin;
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

  Observable<List<Pair>> _pairs;
  Stream<List<Pair>> get pairs => _pairs;

  CoinsBloc(this._dataService)
  {
    if (_dataService is AuthorizableServiceMixin &&
        (_dataService as AuthorizableServiceMixin).hasCredentials == false)
      (_dataService as AuthorizableServiceMixin).authorize(api_keys["coinigy"]["key"], api_keys["coinigy"]["secret"]);

    _pairs = Observable.fromFuture(_dataService.getUserPairs())
      //.map((l) => l.length > 20 ? l.sublist(0, 20) : l)
      .asBroadcastStream()
    ;

    var onSelectedPair = Observable.merge([
      onEvent<HomeSelectCoinEvent>()
          .map((evt) => evt.event.pair),
      _pairs
          .where((lst) => lst.isNotEmpty)
          .map((lst) => lst.first),
      ]
    )
    .asBroadcastStream()
    ;

    var selectedPairOHLCVData = onSelectedPair
      .asyncMap((pair) => _dataService.getPairOHLC(pair, Duration(minutes: 60)))
      .asBroadcastStream();

    var selectedPairRsi = selectedPairOHLCVData
      .map(_rsiIndicator.calculate);

    disposeWhenDone(
      Observable.merge([
        onSelectedPair.map((_) => HomeLoadingState()),
        Observable.combineLatest3(
          onSelectedPair,
          selectedPairOHLCVData,
          selectedPairRsi,
          (pair, ohlc, rsi) => HomeSelectedCoinState(pair, ohlc, rsi)
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