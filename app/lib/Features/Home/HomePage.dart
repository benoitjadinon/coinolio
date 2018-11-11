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
        stream: bloc?.state,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Text('Error: ${snapshot.error}');
          if (snapshot.data is HomeLoadingState)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.data is HomeSelectedCoinState)
            return TappableOHLCVGraph((snapshot.data as HomeSelectedCoinState).ohlc);
          return Center();
        }
      )
    );

  Widget buildList()
    => new StreamBuilder<List<Pair>>(
      stream: bloc?.pairs,
      builder: (context, snapshot) {
        return !snapshot.hasData
          ? CircularProgressIndicator()
          : PopupMenuButton<Pair>(
            onSelected: (c) => bloc.selectCoinCommand.execute(HomeSelectCoinIntent(c)),
            itemBuilder: (c) =>
              snapshot.data
                .map((Pair pair) {
                  return PopupMenuItem<Pair>(
                    value: pair,
                    child: Row(
                      children: <Widget>[
                        pair.coin.imageUrl != null
                          ? Image(image: CachedNetworkImageProvider(pair.coin.imageUrl))
                          : Center(),
                        Text(pair.name ?? pair.symbol)
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
        stream: bloc?.state,
        builder: (context, snapshot) {
          if (snapshot.data is HomeEmptyState)
            return Center();
          else if (snapshot.data is HomeLoadingState)
            return Center(child: CircularProgressIndicator());
          else
            return Sparkline(
              data: (snapshot.data as HomeSelectedCoinState).rsi,
              lineColor: Colors.orange,
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

