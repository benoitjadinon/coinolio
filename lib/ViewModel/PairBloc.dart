import 'dart:async';

import 'package:coinolio/Model/model.dart';

import 'package:rxdart/subjects.dart';

class PairBloc
{
  final _selectController = StreamController<Pair>();
  Sink<Pair> get selectPair => _selectController.sink;

  final _selectedPair = new ReplaySubject<Pair>(maxSize: 1);
  Stream<Pair> get selectedPair => _selectedPair.stream;

  PairBloc(){
    _selectController.stream.listen((e) => _selectedPair.add(e));
  }
}