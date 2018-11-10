
class Exchange
{
  String name;
  String code;
}

class Pair
{
  final Exchange exchange;
  final Coin coin;
  final Coin base;

  String get symbol => coin.symbol;
  String get name => "$symbol-${base.symbol} (${exchange.code})";

  Pair(this.exchange, this.coin, this.base);
}

class Coin
{
  String id;            //  "716725"
  String name;          //  "ZIL"
  String imageUrl;      //  "/media/27010464/zil.png" // https://www.cryptocompare.com/media/27...
  String symbol;        //  "ZIL"
  String coinName;      //  "Zilliqa"
  String fullName;      //  "Zilliqa (ZIL)"
  String algorithm;     //  "N/A"
  String proofType;     //  "N/A"
  String fullyPreMined; //  "0"
  String totalCoinSupply;     //  "12600000000"
  String preMinedValue;       //  "N/A"
  String totalCoinsFreeFloat; //  "N/A"

  bool isFiat = false;

  Coin([this.symbol]);

  static Coin getFiat([String symbol="USD"]) => Coin(symbol)..name=symbol..isFiat=true;
}


class OHLCVItem
{
  //num time;     //: 1526176800
  num close;      //: 8421.96
  num high;       //: 8448.33
  num low;        //: 8386.37
  num open;       //: 8447.71
  num volume;     //: 22480267.83 // means the volume in the currency that is being traded
  num volumeFrom; //: 2669.79     // means the volume in the base currency that things are traded into.

  OHLCVItem();
  OHLCVItem.ohlc(this.open, this.high, this.low, this.close, [this.volume]);

  Map<dynamic, dynamic> toMap ()
  {
    return new Map()
      ..["close"] = close
      ..["high"] = high
      ..["low"] = low
      ..["open"] = open
      ..["volumefrom"] = volumeFrom
      ..["volumeto"] = volume
    ;
  }
}