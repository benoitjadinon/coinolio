import 'package:coinolio/OHLCService.dart';
import 'package:coinolio/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coinolio',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Coinolio (alpha)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  List<dynamic> _coinChartData = [];
  List<Coin> _coins = <Coin>[
    Coin()..id="loading..."..name="loading"
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

    _coins = coins.sublist(0,10);

    _selectCoin(coins[0]);
  }

  void _selectCoin(Coin selectedCoin) async {
    var data = await dataService.getCoinDataHoursDynamic(Pair(null, selectedCoin, "USD" /* TODO */));

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
        child:
            (_coinChartData.isEmpty) ?
              new Container(
                child: new Text("loading..."),
              )
            :
              Container(
                child: OHLCVGraph(
                    data: _coinChartData,
                    enableGridLines: true,
                    volumeProp: 0.15,
                    labelPrefix: "€",
                    gridLineAmount: 10,
                    gridLineColor: Colors.grey[300],
                    gridLineLabelColor: Colors.grey,
                ),
              )
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => (null),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}