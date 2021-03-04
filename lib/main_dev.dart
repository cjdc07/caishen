import 'package:cjdc_money_manager/main.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('tokens');

  var configuredApp = AppConfig(
    appTitle: "Caishen Dev",
    buildFlavor: "Development",
    child: MyApp(),
  );

  return runApp(configuredApp);
}
