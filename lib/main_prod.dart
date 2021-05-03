import 'package:cjdc_money_manager/main.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  var configuredApp = AppConfig(
    appTitle: "Caishen",
    buildFlavor: "Production",
    child: App(),
  );

  return runApp(configuredApp);
}
