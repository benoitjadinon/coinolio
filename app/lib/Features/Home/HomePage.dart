import 'package:api/Model/CoinsBloc.dart';
import 'package:api/Model/model.dart';
import 'package:api/Services/OHLCService.dart';
import 'package:coinolio/Views/PlaceHolder.dart';
import 'package:coinolio/Views/TappableOHLCVGraph.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:dryice/dryice.dart' as di;

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<HomePage> {

  CoinsBloc bloc = CoinsBloc(OHLCService(http.Client()));

  @override
  void initState() {
    super.initState();

    //bloc.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder(
          bloc: bloc,
          builder: (context, snapshot)
            => Text(widget.title + ' : ' + (snapshot.data?.name ?? ''))
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
      child: new BlocBuilder(
        bloc: bloc,
        builder: (context, snapshot) {
          return !snapshot.hasData || snapshot.data == null
            ? Center(child: CircularProgressIndicator())
            : TappableOHLCVGraph(snapshot.data);
        }
      )
    );

  Widget buildList()
    => new BlocBuilder(
      bloc: bloc,
      builder: (context, snapshot) {
        return !snapshot.hasData
          ? CircularProgressIndicator()
          : PopupMenuButton<Coin>(
            onSelected: (c) =>
              bloc.selectCoin.add(c),
            itemBuilder: (c) => (snapshot.data as List<Coin>).map((Coin coin) {
              return PopupMenuItem<Coin>(
                value: coin,
                child: Row(
                  children: <Widget>[
                    //CachedNetworkImage(imageUrl: coin.imageUrl),
                    Image(image: CachedNetworkImageProvider(coin.imageUrl)),
                    Text(coin.name)
                  ],
                ),
              );
            }).toList()
        );
      },
    );

  Widget buildRSI()
    => Stack(children: <Widget>[
      //new PlaceHolder(),
      new BlocBuilder(
        bloc: bloc,
        builder: (context, s) {
          return !s.hasData || s.data == null
            ? Center(child: CircularProgressIndicator())
            : Sparkline(
              data: s.data,
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

