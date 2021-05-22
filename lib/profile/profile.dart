import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
    ;
  }
}
