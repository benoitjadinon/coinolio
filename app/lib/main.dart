import 'package:coinolio/Features/Home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:api/setup.dart';
import 'setup.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    getAppInjector().setup();

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
      home: HomePage(title: 'Coinolio (alpha)'),
    );
  }
}