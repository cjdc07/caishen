import 'package:cjdc_money_manager/account/account.dart';
import 'package:cjdc_money_manager/app_navigation.dart';
import 'package:cjdc_money_manager/change_notifiers/account_model_notifier.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountModelNotifier())
      ],
      child: MaterialApp(
        title: AppConfig.of(context).appTitle,
        theme: ThemeData.dark(),

        // TODO: Forgot why I used custom theme
        //       Create custom theme in another file
        // theme: ThemeData(
        //   primarySwatch: Colors.grey,
        //   primaryColor: Colors.black,
        //   brightness: Brightness.dark,
        //   backgroundColor: const Color(0xFF212121),
        //   accentColor: Colors.white,
        //   accentIconTheme: IconThemeData(color: Colors.black),
        //   dividerColor: Colors.transparent,
        // ),

        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Failed to initialize Firebase')),
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              final CollectionReference accountsRef =
                  FirebaseFirestore.instance.collection('accounts');

              return FutureBuilder<QuerySnapshot>(
                future: accountsRef.get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(child: Text('Something went wrong')),
                    );
                  }

                  if (snapshot.data == null) {
                    return Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data.docs;

                  final List<Account> accounts = Account.parseList(docs.map(
                    (account) {
                      Map<String, dynamic> data = account.data();
                      data['id'] = account.id;
                      return data;
                    },
                  ).toList());

                  return AppNavigation(accounts: accounts);
                },
              );
            }

            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
