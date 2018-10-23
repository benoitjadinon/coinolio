import 'package:api/Features/Chart/CoinsBloc.dart';
import 'package:api/Features/Chart/OHLCService.dart';
import 'package:kiwi/kiwi.dart';
import 'package:http/http.dart';

// https://pub.dartlang.org/packages/kiwi_generator

part 'setup.g.dart';

abstract class Injector {
  @Register.factory(Client)
  @Register.singleton(OHLCService)
  @Register.singleton(CoinsBloc)
  /*
  @Register.factory(Service, from: ServiceB)
  @Register.factory(ServiceB, name: 'factoryB')
  @Register.factory(ServiceC, resolvers: {ServiceB: 'factoryB'})
  */
  void configure();

  void setup() {
    configure();
  }
}

Injector getInjector() => _$Injector();