import 'package:api/Features/Chart/CoinsBloc.dart';
import 'package:api/Model/OHLCService.dart';
import 'package:kiwi/kiwi.dart';
import 'package:http/http.dart';

// https://pub.dartlang.org/packages/kiwi_generator

// dart :
// pub run build_runner build
// pub run build_runner watch

// flutter
// flutter packages pub run build_runner build

part 'setup.g.dart';

abstract class Injector {
  @Register.factory(Client)
  //@Register.singleton(BaseOHLCService, from:OHLCFakeService)
  @Register.singleton(BaseOHLCService, from:OHLCService)
  @Register.singleton(CoinsBloc)
  /*
  @Register.factory(Service, from: ServiceB)
  @Register.factory(ServiceB, name: 'factoryB')
  @Register.factory(ServiceC, resolvers: {ServiceB: 'factoryB'})
  */
  void configure();

  static bool isInjected = false;

  void setup() {
    if (!isInjected) {
      configure();
      isInjected = true;
    }
  }
}

Injector getInjector() => _$Injector();