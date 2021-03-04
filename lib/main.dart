import 'package:cjdc_money_manager/cash_flow/cash_flow.dart';
import 'package:cjdc_money_manager/client_provider.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

const String graphqlEndpoint = String.fromEnvironment('GRAPHQL_ENDPOINT');
const String subscriptionEndpoint =
    String.fromEnvironment('SUBSCRIPTION_ENDPOINT');

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("FIREBASE ERROR");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          // Hive.box('tokens').delete('authToken');
          final String authToken = Hive.box('tokens').get('authToken');

          return ClientProvider(
            uri: graphqlEndpoint,
            subscriptionUri: subscriptionEndpoint,
            child: MaterialApp(
              title: AppConfig.of(context).appTitle,
              // TODO: Create custom theme in another file
              theme: ThemeData(
                primarySwatch: Colors.grey,
                primaryColor: Colors.black,
                brightness: Brightness.dark,
                backgroundColor: const Color(0xFF212121),
                accentColor: Colors.white,
                accentIconTheme: IconThemeData(color: Colors.black),
                dividerColor: Colors.transparent,
              ),
              // TODO: Revert when firebase auth is done
              // home: authToken != null ? HomePage() : LoginPage(),
              home: HomePage(),
            ),
          );
        }

        return MaterialApp(home: Text('LOADING...'));
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    CashFlow(),
    Column(
      children: [Text('Hello Investments')],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    ),
    Column(
      children: [Text('Profile Management')],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: _screens,
        index: _selectedIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Cash Flow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Investments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        onTap: _onItemTapped,
      ),
    );
  }
}
