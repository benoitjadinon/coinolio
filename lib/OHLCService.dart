import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';


// https://min-api.cryptocompare.com/
class OHLCService
{
  Future<List<dynamic>> getCoinDataHours(Pair selectedCoin, [int limit=24]) async
  {
    Response response =
    await get('https://min-api.cryptocompare.com/data/histohour?fsym=${selectedCoin.coin.symbol}&tsym=${selectedCoin.base}&limit=${limit.toString()}&aggregate=3&e=CCCAGG',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }
    );

    Map<String, dynamic> resp = json.decode(response.body);

    //var res = OHLCVResponse.fromJson(resp);

    return resp["Data"];
  }

  Future<List<Coin>> getCoins() async
  {
    Response response = await get('https://min-api.cryptocompare.com/data/all/coinlist',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }
    );

    Map<String, dynamic> resp = json.decode(response.body);

    var res = mapMap<Coin>(resp["Data"], (key, obj) => Coin.fromJson(obj));
    res.sort((a,b) => a.sortOrder.compareTo(b.sortOrder));
    return res;
  }
}


class Pair
{
  Coin coin;
  String base;

  Pair(this.coin, [this.base="USD"]);
}


class Coin
{
  String id;        //  "716725"
  //String url;     //  "/coins/zil/overview"
  String imageUrl;  //  "/media/27010464/zil.png"
  String name;      //  "ZIL"
  String symbol;    //  "ZIL"
  String coinName;  //  "Zilliqa"
  String fullName;  //  "Zilliqa (ZIL)"
  String algorithm; //  "N/A"
  String proofType; //  "N/A"
  String fullyPremined;   //  "0"
  String totalCoinSupply; //  "12600000000"
  String preMinedValue;   //  "N/A"
  String totalCoinsFreeFloat;//  "N/A"
  int sortOrder;          //  "2152"
  //bool sponsored;       // false
  bool isTrading;         // true

  Coin(this.id, this.name);

  Coin.fromJson(Map<String, dynamic> json) :
        id = json["Id"],
        imageUrl = json["ImageUrl"],
        name = json["Name"],
        symbol = json["Symbol"],
        coinName = json["CoinName"],
        fullName = json["FullName"],
    // ...
        sortOrder = int.parse(json["SortOrder"])
  ;
}

/*
class OHLCVResponse
{
  List<OHLCVItem> Data;

  OHLCVResponse.fromJson(Map<String, dynamic> json)
      : Data = map<OHLCVItem>((json['Data'])/*.cast<List<dynamic>>()*/, (line) => OHLCVItem.fromJson(line));
}

class OHLCVItem
{
  //num time;//: 1526176800
  num close;//: 8421.96
  num high;//: 8448.33
  num low;//: 8386.37
  num open;//: 8447.71
  num volumeFrom;//: 2669.79
  num volumeTo;//: 22480267.83

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
*/

List<T> map<T>(List list, converter(x)) {
  final List<T> result = [];
  for (final x in list) {
    result.add(converter(x));
  }
  return result;
}

List<T> mapMap<T>(Map<String, dynamic> map, converter(x, y)) {
  final List<T> result = [];
  void iterateMapEntry(key, value) {
    //map[key] = value;
    //print('$key:$value');//string interpolation in action
    result.add(converter(key, value));
  }
  map.forEach(iterateMapEntry);
  return result;
}