import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                Icon(Icons.logout_rounded),
                const Text(
                  ' Logout',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ),
      ),
    );
  }
}