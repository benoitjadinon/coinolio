import 'dart:async';
import 'model.dart';
import 'package:meta/meta.dart';

abstract class AuthorizableServiceMixin
{
  @protected
  String apiKey, apiSecret;

  bool get hasCredentials => apiKey != null && apiSecret != null;

  void authorize(String apiKey, String secret)
  {
    this.apiKey = apiKey;
    this.apiSecret = secret;
  }
}


abstract class BaseOHLCService
{
  Map<String, String> get defaultJSONHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<List<Exchange>> getExchanges();
  Future<List<Pair>> getUserPairs([Exchange exchange]);
  Future<List<OHLCVItem>> getPairOHLC(Pair pair, Duration interval, [DateTime from = null, DateTime to = null]);
  Future<List<dynamic>> getPairOHLCDynamic(Pair pair, Duration interval, [DateTime from = null, DateTime to = null]);
}


class OHLCFakeService extends BaseOHLCService
{
  @override
  Future<List<OHLCVItem>> getPairOHLC(Pair coin, Duration interval, [DateTime from = null, DateTime to = null]) {
    return Future.delayed(Duration(seconds: 2), () => [
      getFakeItem(46.1250), // 0
      getFakeItem(47.1250), // 1
      getFakeItem(46.4375), // ...
      getFakeItem(46.9375),
      getFakeItem(44.9375),
      getFakeItem(44.2500),
      getFakeItem(44.6250),
      getFakeItem(45.7500),
      getFakeItem(47.8125),
      getFakeItem(47.5625),
      getFakeItem(47.0000),
      getFakeItem(44.5625),
      getFakeItem(46.3125),
      getFakeItem(47.6875),
      getFakeItem(46.6875), // 14
      getFakeItem(45.6875), // 15
    ]);
  }

  @override
  Future<List> getPairOHLCDynamic(Pair coin, Duration interval, [DateTime from = null, DateTime to = null]) {
    return getPairOHLC(coin, interval, from, to);
  }

  @override
  Future<List<Exchange>> getExchanges() {
    return Future(() => [
      Exchange()
        ..name="Bitrex"
        ..code="BTRX"
    ]);
  }

  @protected
  OHLCVItem getFakeItem(double close)
    => OHLCVItem()
    ..high = close+1
    ..low = close-2
    ..open = close-1
    ..volumeFrom = 1
    ..volume = 1;

  @override
  Future<List<Pair>> getUserPairs([Exchange exchange = null]) async {
    var usd = Coin.getFiat("USDT");

    List<Exchange> exchanges;
    if (exchange == null)
      exchanges = await getExchanges();
    else exchanges = [exchange];

    var pairs = List<Pair>();
    exchanges.forEach((exchange) => pairs.addAll([
      Pair(exchange, Coin("BTC")..name="BTC", usd),
      Pair(exchange, Coin("ETH")..name="ETH", usd),
    ]));

    return pairs;
  }
}
