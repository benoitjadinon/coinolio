import 'package:coinolio/Services/OHLCService.dart';
import 'package:coinolio/Model/model.dart';
//import 'package:coinolio/Views/PlaceHolder.dart';
import 'package:coinolio/Views/TappableOHLCVGraph.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<HomePage> {

  List<dynamic> _coinChartData = [];
  List<Coin> _coins = <Coin>[
    Coin()
      ..id="loading..."
      ..name="loading"
  ];
  Coin _selectedCoin;

  OHLCService dataService;

  _MyHomePageState(){
    dataService = OHLCService();
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    //var exchanges = await dataService.getExchanges();

    var coins = await dataService.getAllCoins();

    _coins = coins.sublist(0,20);

    if (!mounted)
      return;

    _selectCoin(coins[0]);
  }

  void _selectCoin(Coin selectedCoin) async
  {
    setState(() {
      _coinChartData = [];
    });

    var data = await dataService.getCoinDataHoursDynamic(Pair(null /* TODO */, selectedCoin, Coin.dollar /* TODO */));

    setState(() {
      _selectedCoin = selectedCoin;
      _coinChartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + ' : ' + (_selectedCoin?.name??'')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed:loadData,
          ),
          PopupMenuButton<Coin>(
            onSelected: _selectCoin,
            itemBuilder: (BuildContext context) {
              return _coins.map((Coin coin) {
                return PopupMenuItem<Coin>(
                  value: coin,
                  child:Row(
                    children: <Widget>[
                      //CachedNetworkImage(imageUrl: coin.imageUrl),
                      Image(image: CachedNetworkImageProvider(coin.imageUrl)),
                      Text(coin.name)
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
          child://Stack(children: <Widget>[
          //Placeholder(),
          buildList()
        //])
      ),
      /*floatingActionButton: new FloatingActionButton(
        onPressed: () => (null),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),*/
    );
  }

  Container buildList()
  =>
      (_coinChartData.isEmpty) ?
      new Container(
        child: new Text("loading..."),
      )
          :
      Container(
          child: TappableOHLCVGraph(_coinChartData)
      );
}
