import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'model.dart';


abstract class BaseOHLCService
{
  Future<List<Exchange>> getExchanges();
  Future<List<OHLCVItem>> getCoinDataHours(Pair coin, [int limit=48]);
  Future<List<dynamic>> getCoinDataHoursDynamic(Pair coin, [int limit=48]);
  Future<List<Coin>> getAllCoins();
}

class OHLCFakeService extends BaseOHLCService
{
  @override
  Future<List<Coin>> getAllCoins() async {
    return [
      Coin("BTC")..name="BTC",
      Coin("ETH")..name="ETH",
    ];
  }

  @override
  Future<List<OHLCVItem>> getCoinDataHours(Pair coin, [int limit = 48]) {
    return Future.delayed(Duration(seconds: 2), () => [
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
    ]);
  }

  @override
  Future<List> getCoinDataHoursDynamic(Pair coin, [int limit = 48]) {
    return getCoinDataHours(coin, limit);
  }

  @override
  Future<List<Exchange>> getExchanges() {
    return Future(() => [
      Exchange()..name="Binance"
    ]);
  }
}


// https://min-api.cryptocompare.com/
class OHLCService extends BaseOHLCService
{
  String _serverRoot = 'https://min-api.cryptocompare.com/data/';

  final Client _http;

  OHLCService(this._http){}

  var _defaultJSONHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<List<Exchange>> getExchanges() async
  {
    Response response = await _http.get(
        '$_serverRoot'
        'all/exchanges',
        headers: _defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    var res = mapToMap<_ExchangeDTO>(resp, (key, obj) => _ExchangeDTO.fromJson(key, obj));
    return res.cast<Exchange>();
  }

  Future<List<OHLCVItem>> getCoinDataHours(Pair coin, [int limit=48]) async
    => OHLCVResponse.fromJson(await getCoinDataHoursDynamic(coin, limit)).data;

  Future<List<dynamic>> getCoinDataHoursDynamic(Pair coin, [int limit=48]) async
  {
    Response response = await _http.get(
        '$_serverRoot'
        'histohour'
        '?fsym=${coin.symbol}'
        '&tsym=${coin.base.symbol}'
        '&limit=${limit.toString()}'
        '&aggregate=3'
        '&e=${coin.exchange?.name ?? 'CCCAGG'}',
        headers: _defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    return resp["Data"];
  }

  Future<List<Coin>> getAllCoins() async
  {
    Response response = await _http.get(
        '$_serverRoot'
        'all/coinlist',
        headers: _defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    var res = mapToMap<_CoinDTO>(resp["Data"], (key, obj) => _CoinDTO.fromJson(obj));
    res.sort((a,b) => a.sortOrder.compareTo(b.sortOrder));
    return res.cast<Coin>();
  }
}


class _ExchangeDTO extends Exchange
{
  _ExchangeDTO.fromJson(String exchangeName, Map<String, dynamic> json) {
    name = exchangeName;
    pairs = List<Pair>();
    json.forEach((coin,v) =>
        v.forEach((base) =>
            pairs.add(Pair(this, Coin(coin), base))));
  }
}

class _CoinDTO extends Coin
{
  String url;       // "/coins/zil/overview"
  bool sponsored;   // false
  int sortOrder;    // "2152"
  bool isTrading;   // true

  _CoinDTO.fromJson(Map<String, dynamic> json) {
        id = json["Id"];
        name = json["Name"];
        url = /*'https://www.cryptocompare.com' +*/ json["Url"];
        imageUrl = 'https://www.cryptocompare.com${json["ImageUrl"].toString()}';
        symbol = json["Symbol"];
        coinName = json["CoinName"];
        fullName = json["FullName"];
        algorithm = json["Algorithm"];
        proofType = json["ProofType"];
        fullyPreMined = json["FullyPremined"];
        totalCoinSupply = json["TotalCoinSupply"];
        preMinedValue = json["PreMinedValue"];
        totalCoinsFreeFloat = json["TotalCoinsFreeFloat"];
        sponsored = json["Sponsored"];
        sortOrder = int.parse(json["SortOrder"]);
        isTrading = json["IsTrading"];
    }
}


class OHLCVResponse
{
  List<OHLCVItem> data;

  OHLCVResponse.fromJson(List<dynamic> json)
      : data = mapToList<OHLCVItem>(json, (line) => OHLCVItem.fromJson(line));
}

class OHLCVItem
{
  //num time;     //: 1526176800
  num close;      //: 8421.96
  num high;       //: 8448.33
  num low;        //: 8386.37
  num open;       //: 8447.71
  num volumeFrom; //: 2669.79
  num volumeTo;   //: 22480267.83

  OHLCVItem.fromJson(Map<dynamic, dynamic> json)
      : //time = json['time'],
        close = json['close'],
        high = json['high'],
        low = json['low'],
        open = json['open'],
        volumeFrom = json['volumefrom'],
        volumeTo = json['volumeto']
    ;

  OHLCVItem.fromClose(double this.close) {
    high = close+1;
    low = close-2;
    open = close-1;
    volumeFrom = 1;
    volumeTo = 1;
  }

  Map<dynamic, dynamic> toMap ()
  {
    return new Map()
      ..["close"] = close
      ..["high"] = high
      ..["low"] = low
      ..["open"] = open
      ..["volumefrom"] = volumeFrom
      ..["volumeto"] = volumeTo
    ;
  }
}


List<T> mapToList<T>(List list, converter(x)) {
  final List<T> result = [];
  for (final x in list) {
    result.add(converter(x));
  }
  return result;
}

List<T> mapToMap<T>(Map<String, dynamic> map, converter(x, y)) {
  final List<T> result = [];
  void iterateMapEntry(key, value) {
    result.add(converter(key, value));
  }
  map.forEach(iterateMapEntry);
  return result;
}