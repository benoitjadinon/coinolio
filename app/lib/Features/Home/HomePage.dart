import 'package:api/Model/CoinsBloc.dart';
import 'package:api/Model/model.dart';
import 'package:api/Services/OHLCService.dart';
import 'package:coinolio/Views/PlaceHolder.dart';
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

  CoinsBloc bloc = CoinsBloc(OHLCService());

  @override
  void initState() {
    super.initState();

    //bloc.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new StreamBuilder(
          stream: bloc.selectedCoin,
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
      body: Center(
          child:Stack(children: <Widget>[
            //PlaceHolder(),
            buildChart()
        ])
      ),
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
      child: new StreamBuilder(
        stream: bloc.coinChartData,
        builder: (context, snapshot) {
          return !snapshot.hasData || snapshot.data == null
            ? new CircularProgressIndicator()
            : TappableOHLCVGraph(snapshot.data);
        }
      )
    );

  Widget buildList() {
    return new StreamBuilder(
      stream: bloc.coins,
      builder: (context, snapshot) {
        return !snapshot.hasData
          ? new CircularProgressIndicator()
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
  }
}

