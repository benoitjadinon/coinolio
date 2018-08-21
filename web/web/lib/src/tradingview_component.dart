
import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';

import 'package:angular_components/angular_components.dart';

import 'TradingView.dart' as tv;


@Component(
  selector: 'tradingview',
  //styleUrls: ['tradingview_component.css'],
  templateUrl: 'tradingview_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
  ],
)
class TradingviewComponent implements OnInit {

  //TradingviewComponent(this.todoListService);

  //TODO https://github.com/tradingview/charting-library-examples/blob/master/angular5/src/app/tv-chart-container/tv-chart-container.component.ts

  @override
  Future<Null> ngOnInit() async
  {
    //items = await todoListService.getTodoList();
    tv.widget (
      new tv.WidgetOptions()
          ..container_id = 'tv_chart_container'
          ..autosize = true
          ..symbol = "COINBASE:BTCUSD"
          ..interval = tv.TimeInterval.M1.toString()
    );/*
          'container_id': 'tv_chart_container',
          'autosize': true,
          'symbol': "COINBASE:BTCUSD",//this.symbolPair,
          'interval': 'D',
          'timezone': 'exchange',
          'theme': 'Dark',
          'style': '1',
          'toolbar_bg': '#f1f3f6',
          'withdateranges': true,
          'hide_side_toolbar': false,
          "enable_publishing": false,
          'allow_symbol_change': true,
          'save_image': false,
          'hideideas': true,
          //'studies': [ 'MASimple@tv-basicstudies' ],
          'show_popup_button': true,
          'popup_width': '1000',
          'popup_height': '650'
        }
      );*/
  }
}
