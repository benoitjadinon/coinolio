// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup.dart';

// **************************************************************************
// InjectorGenerator
// **************************************************************************

class _$Injector extends Injector {
  void configure() {
    final Container container = Container();
    container.registerFactory((c) => Client());
    container.registerSingleton<BaseOHLCService, OHLCService>(
        (c) => OHLCService(c<Client>()));
    container.registerSingleton((c) => CoinsBloc(c<BaseOHLCService>()));
  }
}
