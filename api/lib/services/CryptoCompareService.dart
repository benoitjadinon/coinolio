import 'dart:async';
import 'dart:convert';

import 'package:api/Model/OHLCService.dart';
import 'package:http/http.dart';

import '../Model/model.dart';

// https://min-api.cryptocompare.com/
class CryptoCompareService extends BaseOHLCService
{
  String _serverRoot;

  final Client _http;

  CryptoCompareService(this._http, [this._serverRoot = 'https://min-api.cryptocompare.com/data/']){}

  Future<List<_ExchangeDTO>> getExchanges() async
  {
    Response response = await _http.get(
        '$_serverRoot'
            'all/exchanges',
        headers: defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    var res = _mapToMap<_ExchangeDTO>(resp, (key, obj) => _ExchangeDTO.fromJson(key, obj));
    var exchanges = res.cast<Exchange>();

    //var coins = _getAllCoins();

    return exchanges;
  }

  Future<List<_OHLCVItem>> getPairOHLC(Pair coin, Duration interval, [DateTime from = null, DateTime to = null]) async
    => _OHLCVResponse.fromJson(await getPairOHLCDynamic(coin, interval, from, to)).data;

  Future<List<dynamic>> getPairOHLCDynamic(Pair coin, Duration interval, [DateTime from = null, DateTime to = null]) async
  {
    Response response = await _http.get(
        '$_serverRoot'
            'histohour'
            '?fsym=${coin.symbol}'
            '&tsym=${coin.base.symbol}'
            '&limit=${interval.inMinutes.toString()}'
            '&aggregate=3'
            '&e=${coin.exchange?.code ?? 'CCCAGG'}',
        headers: defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    return resp["Data"];
  }

  Future<List<Coin>> _getAllCoins() async
  {
    Response response = await _http.get(
        '{$_serverRoot}all/coinlist',
        headers: defaultJSONHeaders
    );

    Map<String, dynamic> resp = json.decode(response.body);

    var res = _mapToMap<_CoinDTO>(resp["Data"], (key, obj) => _CoinDTO.fromJson(obj));
    res.sort((a,b) => a.sortOrder.compareTo(b.sortOrder));
    return res.cast<Coin>();
  }

  @override
  Future<List<Pair>> getUserPairs([Exchange exchange]) async {
    var exchanges = await getExchanges();
    var res = List<Pair>();
    exchanges.forEach((e) => res.addAll(e.pairs));
    return res;
  }
}


class _ExchangeDTO extends Exchange
{
  List<Pair> pairs;

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


class _OHLCVResponse
{
  List<_OHLCVItem> data;

  _OHLCVResponse.fromJson(List<dynamic> json)
      : data = _mapToList<_OHLCVItem>(json, (line) => _OHLCVItem.fromJson(line));
}


class _OHLCVItem extends OHLCVItem
{
  _OHLCVItem.fromJson(Map<dynamic, dynamic> json)
  {
    //time = json['time'];
    close = json['close'];
    high = json['high'];
    low = json['low'];
    open = json['open'];
    volumeFrom = json['volumefrom'];
    volume = json['volumeto'];
  }
}


List<T> _mapToList<T>(List list, converter(x)) {
  final List<T> result = [];
  for (final x in list) {
    result.add(converter(x));
  }
  return result;
}

List<T> _mapToMap<T>(Map<String, dynamic> map, converter(x, y)) {
  final List<T> result = [];
  void iterateMapEntry(key, value) {
    result.add(converter(key, value));
  }
  map.forEach(iterateMapEntry);
  return result;
}