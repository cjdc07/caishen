import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  String errorMessage;

  bool loading = false;

  void setLoading() {
    setState(() {
      loading = !loading;
    });
  }

  void login() async {
    if (!formKey.currentState.validate()) {
      return;
    }

    setLoading();

    try {
      UserCredential credentials =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailFieldController.text.trim(),
        password: passwordFieldController.text.trim(),
      );

      print(credentials);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
    } finally {
      setLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 32.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 32.0),
                      child: Column(
                        children: [
                          AppTextField(
                            enabled: !loading,
                            controller: emailFieldController,
                            label: 'Email',
                          ),
                          AppTextField(
                            isPassword: true,
                            enabled: !loading,
                            controller: passwordFieldController,
                            label: 'Password',
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      color: Colors.cyan,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Login ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.login_rounded),
                        ],
                      ),
                      onPressed: login,
                    ),
                    errorMessage != null
                        ? Container(
                            margin: EdgeInsets.only(top: 16.0),
                            child: Text(
                              errorMessage,
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
      ),
    );
  }
}
