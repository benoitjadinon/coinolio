
class Exchange
{
  String name;
  List<Pair> pairs;
}

class Pair
{
  final Exchange exchange;
  final Coin coin;
  final Coin base;

  String get symbol => coin.symbol;
  String get name => symbol + '/' + base.symbol;

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

  static Coin Dollar = Coin("USD")..isFiat=true;
}