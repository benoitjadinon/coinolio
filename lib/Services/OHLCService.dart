import 'dart:async';
import 'dart:convert';

import 'package:coinolio/Model/model.dart';
import 'package:http/http.dart';


// https://min-api.cryptocompare.com/
class OHLCService
{
  String _serverRoot = 'https://min-api.cryptocompare.com/data/';

  var _defaultJSONHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<List<Exchange>> getExchanges() async
  {
    Response response = await get(
        '$_serverRoot'
        'all/exchanges',
        headers: _defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    var res = mapToMap<_ExchangeDTO>(resp, (key, obj) => _ExchangeDTO.fromJson(key, obj));
    return res.cast<Exchange>();
  }

  Future<List<OHLCVItem>> getCoinDataHours(Pair coin, [int limit=24]) async
    => OHLCVResponse.fromJson(await getCoinDataHoursDynamic(coin, limit)).Data;

  Future<List<dynamic>> getCoinDataHoursDynamic(Pair coin, [int limit=24]) async
  {
    Response response = await get(
        '$_serverRoot'
        'histohour'
        '?fsym=${coin.symbol}'
        '&tsym=${coin.base}'
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
    Response response = await get(
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
            pairs.add(Pair(this, Coin()..name=coin, base))));
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
  List<OHLCVItem> Data;

  OHLCVResponse.fromJson(List<dynamic> json)
      : Data = mapToList<OHLCVItem>(json, (line) => OHLCVItem.fromJson(line));
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