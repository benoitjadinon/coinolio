import 'dart:async';
import 'package:angular/core.dart';
import 'package:angular_forms/src/directives/ng_form_control.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:angular/angular.dart';
import 'package:api/api.dart';
import 'package:http/browser_client.dart' as http;

@Component(
  selector: 'coin_selector',
  //styleUrls: ['coin_selector_component.css'],
  templateUrl: 'coin_selector_component.html',
  directives: [
    NgFor,
    NgIf,
    //materialInputDirectives
  ],
)
class CoinSelectorComponent implements OnInit {
  List<String> coins = [];

  @override
  void ngOnInit() {

    var bloc = CoinsBloc(OHLCService(http.BrowserClient()));
    bloc.coins
       .map((cs) => cs.map((c) => c.name))
       .listen(coins.addAll);
  }
}
