import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'package:api/Model/OHLCService.dart';
import 'package:http/http.dart';
import '../Model/model.dart';

/// v1 : https://coinigy.docs.apiary.io/#reference/market-data/list-exchanges/exchanges
/// TODO v2 : https://api.coinigy.com/api/v2/docs/#/User32Settings321243232Subscription32info4432activity4432settings4432referrals4432API32keys4432etc32
class CoinigyService extends BaseOHLCService with AuthorizableServiceMixin
{
  final Client _http;

  String _serverRoot;

  Map<dynamic, dynamic> getSecureJSONHeaders()
  {
    var map = Map<String,String>.from(defaultJSONHeaders);
    map.addAll({
      'X-API-KEY': this.apiKey,
      'X-API-SECRET': this.apiSecret
    });
    return map;
  }

  CoinigyService(this._http, [String apiKey = null, String apiSecret = null, this._serverRoot = 'https://api.coinigy.com/api/v1/'])
  {
    this.apiKey = apiKey;
    this.apiSecret = apiSecret;
  }

  @override
  Future<List<OHLCVItem>> getPairOHLC(Pair pair, Duration interval, [DateTime from = null, DateTime to = null]) async {
    //var interval = 60; //in minutes

    to = to ?? DateTime.now();
    from = from ?? to.subtract(Duration(days: 30));

    var startDate = from.microsecondsSinceEpoch.toString().substring(0,10); //"1536657971";
    var endDate = to.microsecondsSinceEpoch.toString().substring(0,10); //"1541842031";

    // https://www.coinigy.com/getjson/chart_feed/BTRX/ADA/USDT/60/1536657971/1541842031
    var path = "https://www.coinigy.com/getjson/"
        "chart_feed"
        "/${pair.exchange.code}"
        "/${pair.coin.symbol}"
        "/${pair.base.symbol}"
        "/${interval.inMinutes}"
        "/$startDate"
        "/$endDate";

    Response response = await _http.get(path, headers: defaultJSONHeaders);

    var arr = jsonDecode(response.body);

    // [
    // 1541840400,      0 start epoch
    // "0.0748076200",  1 o
    // "0.0752920000",  2 h
    // "0.0748076100",  3 la
    // "0.0752920000",  4 c
    // "240.0000000000",5 volume
    // 1541842415       6 end epoch
    // ]

    var lst = List<OHLCVItem>();
    for(int i = arr.length-1; i >= 0; i--) {
      var it = arr[i];
      lst.add(OHLCVItem()
        ..open = num.parse(it[1])
        ..high = num.parse(it[2])
        ..low  = num.parse(it[3])
        ..close = num.parse(it[4])
        ..volume = num.parse(it[5])
        //..volumeFrom = num.parse(it[5])
      );
    }
    return lst;
  }

  @override
  Future<List> getPairOHLCDynamic(Pair pair, Duration interval, [DateTime from = null, DateTime to = null]) {
    // TODO: implement getPairOHLCDynamic
    return getPairOHLC(pair, interval, from , to);
  }

  @override
  Future<List<Exchange>> getExchanges() async {
    Response response = await _http.post("${_serverRoot}exchanges", headers: getSecureJSONHeaders());
    var arr = jsonDecode(response.body);
    //if (arr["err_msg"])
    var exs = arr["data"];
    var lst = List<Exchange>();
    for (var value in exs) {
      lst.add(_ExchangeDTO.fromJson(value));
    }
    return lst;
  }

  @override
  Future<List<Pair>> getUserPairs([Exchange exchange]) async {
    Response response = await _http.post("${_serverRoot}userWatchList", headers: getSecureJSONHeaders());
    var arr = jsonDecode(response.body);

    List<Exchange> exchanges;
    if (exchange == null)
      exchanges = await getExchanges();
    else exchanges = [exchange];

    var exs = arr["data"];
    var lst = List<Pair>();
    for (var value in exs) {
      var pair = _PairDTO.fromJson(value);
      var exch = exchanges.firstWhere((e) => e.code == pair.exch_code);
      if (exch != null){
        var pairz = pair.mkt_name.split('/');
        lst.add(Pair(exchanges.firstWhere((e) => e.code == exch.code), Coin(pairz.first), Coin(pairz.last)));
      }
    }

    return lst;
  }
}

class _ExchangeDTO extends Exchange
{
  num exch_id;
  //String exch_name;
  //String exch_code;
  //num exch_fee;
  //bool exch_trade_enabled;
  //bool exch_balance_enabled;
  //String exch_url;

  _ExchangeDTO.fromJson(Map<dynamic, dynamic> json)
  {
    exch_id = num.parse(json['exch_id']);
    name = json['exch_name'];
    code = json['exch_code'];
  }
}

class _PairDTO extends Pair
{
  String exch_code;
  String mkt_name;

  /*
  exchmkt_id: number;
  mkt_name: string;
  exch_code: string;
  exch_name: string;
  primary_currency_name: string;
  secondary_currency_name: string;
  //server_time: Date;
  last_price: number;
  prev_price: number;
  high_trade: number;
  low_trade: number;
  current_volume: number;
  fiat_market: boolean;
  btc_volume: number;
  */

  _PairDTO.fromJson(Map<dynamic, dynamic> json)
      : super(null, null, null)
  {
    mkt_name = json['mkt_name'];
    exch_code = json['exch_code'];
  }
}

