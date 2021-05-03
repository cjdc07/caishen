import 'package:cjdc_money_manager/main.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  var configuredApp = AppConfig(
    appTitle: "Caishen Dev",
    buildFlavor: "Development",
    child: App(),
  );

  return runApp(configuredApp);
}
