import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_navigation.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/user_profile_notifier.dart';
import 'package:cjdc_money_manager/login/login.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:cjdc_money_manager/user_profile/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountNotifier()),
        ChangeNotifierProvider(create: (context) => AppTransactionNotifier()),
        ChangeNotifierProvider(create: (context) => UserProfileNotifier())
      ],
      child: MaterialApp(
        title: AppConfig.of(context).appTitle,
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.grey[900],
          ),
          accentColor: Colors.cyan,
          cardColor: Colors.grey[900],
          primaryColor: Colors.black,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          dividerColor: Colors.transparent,
        ),
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Failed to initialize Firebase')),
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder<User>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child:
                            Text('Something went wrong while authenticating'),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.active) {
                    User user = snapshot.data;

                    if (user != null) {
                      UserProfile userProfile = UserProfile(
                        id: user.uid,
                        email: user.email,
                      );

                      Provider.of<UserProfileNotifier>(context, listen: false)
                          .setUserProfile(userProfile);

                      final CollectionReference accountsRef =
                          FirebaseFirestore.instance.collection('accounts');

                      final CollectionReference appTransactionsCategoriesRef =
                          FirebaseFirestore.instance
                              .collection('appTransactionCategories');

                      return FutureBuilder<List<QuerySnapshot>>(
                        future: Future.wait([
                          accountsRef.orderBy('name').get(),
                          appTransactionsCategoriesRef.get(),
                        ]),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<List<QuerySnapshot>> snapshot,
                        ) {
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

                          QuerySnapshot accountsSnapshot = snapshot.data[0];
                          QuerySnapshot appTransactionCategoriesSnapshot =
                              snapshot.data[1];

                          final List<Account> accounts =
                              Account.parseList(accountsSnapshot.docs.map(
                            (account) {
                              Map<String, dynamic> data = account.data();
                              data['id'] = account.id;
                              return data;
                            },
                          ).toList());

                          List<AppTransactionCategory>
                              appTransactionCategories =
                              appTransactionCategoriesSnapshot.docs
                                  .map((appTransactionCategory) {
                            Map<String, dynamic> data =
                                appTransactionCategory.data();
                            data['id'] = appTransactionCategory.id;
                            return AppTransactionCategory.parse(data);
                          }).toList();

                          return AppNavigation(
                            userProfile: userProfile,
                            accounts: accounts,
                            appTransactionCategories: appTransactionCategories,
                          );
                        },
                      );
                    }

                    return Login();
                  }

                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
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
