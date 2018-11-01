import 'package:api/Features/Chart/CoinsBloc.dart';
import 'package:api/Model/model.dart';
import 'package:coinolio/Views/TappableOHLCVGraph.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<HomePage> {

  CoinsBloc bloc = kiwi.Container().resolve<CoinsBloc>();

  @override
  void initState() {
    super.initState();
    
    //bloc.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new StreamBuilder<HomeState>(
          stream: bloc.state,
          builder: (context, snapshot)
            => Text(widget.title + ' : ' + (snapshot.data?.title ?? ''))
        ),
        actions: <Widget>[
          /*IconButton(
            icon: Icon(Icons.refresh),
            //onPressed:bloc.refresh, //TODO
          ),*/
          buildList()
        ],
      ),
      body:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //PlaceHolder(),
              Expanded(
                child:buildChart(),
              ),
              Container(
                height: 80.0,
                child: buildRSI(),
              ),
            ]
          )
      /*
      floatingActionButton: new FloatingActionButton(
        onPressed: () => (null),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
      */
    );
  }

  Container buildChart()
    => Container(
      child: new StreamBuilder<HomeState>(
        stream: bloc.state,
        builder: (context, snapshot) {
          if (snapshot.data is HomeLoadingState)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.data is HomeSelectedCoinState)
            return TappableOHLCVGraph((snapshot.data as HomeSelectedCoinState).ohlc);
          return Center();
        }
      )
    );

  Widget buildList()
    => new StreamBuilder<List<Coin>>(
      stream: bloc.coins,
      builder: (context, snapshot) {
        return !snapshot.hasData
          ? CircularProgressIndicator()
          : PopupMenuButton<Coin>(
            onSelected: (c) => bloc.dispatch(HomeSelectCoinEvent(c)),
            itemBuilder: (c) =>
              snapshot.data
                .map((Coin coin) {
                  return PopupMenuItem<Coin>(
                    value: coin,
                    child: Row(
                      children: <Widget>[
                        //CachedNetworkImage(imageUrl: coin.imageUrl),
                        coin.imageUrl != null
                          ? Image(image: CachedNetworkImageProvider(coin.imageUrl))
                          : Center(),
                        Text(coin.name ?? coin.symbol)
                      ],
                    ),
                  );
                })
              .toList()
        );
      },
    );

  Widget buildRSI()
    => Stack(children: <Widget>[
      //new PlaceHolder(),
      new StreamBuilder<HomeState>(
        stream: bloc.state,
        builder: (context, snapshot) {
          if (snapshot.data is HomeEmptyState)
            return Center();
          else if (snapshot.data is HomeLoadingState)
            return Center(child: CircularProgressIndicator());
          else
            return Sparkline(
              data: (snapshot.data as HomeSelectedCoinState).rsi,
              lineColor: Colors.lightBlue[500],
              pointsMode: PointsMode.all,
              pointSize: 0.0,
              min: 0.0,
              max: 100.0,
              //enableGridLines: true,
              //gridLineAmount: 10,
              gridLines: [30.0, 70.0],
              labelPrefix: "",
            );
        }
      )
    ]
  );
}

