import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/user_profile_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePage createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.0),
          child: CupertinoButton(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  ' Logout',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            onPressed: () async {
              Provider.of<UserProfileNotifier>(context, listen: false).reset();
              Provider.of<AccountNotifier>(context, listen: false).reset();
              Provider.of<AppTransactionNotifier>(context, listen: false)
                  .reset();

              await FirebaseAuth.instance.signOut();
            },
          ),
        ),
      ),
    );
  }
}
