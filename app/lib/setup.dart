import 'package:kiwi/kiwi.dart';
import 'package:http/http.dart';
import 'package:api/setup.dart';

part 'setup.g.dart';

abstract class AppInjector {
  @Register.singleton(EmptyForGenerationToWork)
  /*
  @Register.singleton(OHLCService)
  @Register.singleton(CoinsBloc)
  @Register.factory(Service, from: ServiceB)
  @Register.factory(ServiceB, name: 'factoryB')
  @Register.factory(ServiceC, resolvers: {ServiceB: 'factoryB'})
  */
  void configure();

  static bool injected = false;

  void setup()
  {
    if (!injected){
      getInjector().setup();
      configure();
      injected = true;
    }
  }
}

class EmptyForGenerationToWork{}

AppInjector getAppInjector() => _$AppInjector();