import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  String errorMessage;
  bool loading = false;

  AnimationController _controller;
  Animation _animation;
  FocusNode _focusNodeEmailField = FocusNode();
  FocusNode _focusNodePasswordField = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _focusNodeEmailField.addListener(() {
      if (_focusNodeEmailField.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    _focusNodePasswordField.addListener(() {
      if (_focusNodePasswordField.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNodeEmailField.dispose();
    _focusNodePasswordField.dispose();

    super.dispose();
  }

  void setLoading() {
    setState(() {
      loading = !loading;
    });
  }

  void login() async {
    bool userExists = true;

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
        userExists = false;
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message;
      }
    }

    if (!userExists) {
      try {
        UserCredential credentials =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailFieldController.text.trim(),
          password: passwordFieldController.text.trim(),
        );

        print(credentials);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        }
      } catch (e) {
        errorMessage = e.message;
        print(e);
      }
    }

    setLoading();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    _animation = Tween(begin: screenHeight / 3, end: screenHeight / 4)
        .animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 32.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(height: _animation.value),
              Container(
                margin: EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: AppTextField(
                        enabled: !loading,
                        controller: emailFieldController,
                        label: 'Email',
                        focusNode: _focusNodeEmailField,
                      ),
                    ),
                    AppTextField(
                      isPassword: true,
                      enabled: !loading,
                      controller: passwordFieldController,
                      label: 'Password',
                      focusNode: _focusNodePasswordField,
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                color: Colors.cyan,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: loading
                      ? [Center(child: CircularProgressIndicator())]
                      : [
                          const Text(
                            'Login/Register ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.login_rounded),
                        ],
                ),
                onPressed: loading ? null : login,
              ),
              CupertinoButton(
                padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Forgot Password',
                      style: TextStyle(fontSize: 16, color: Colors.cyan),
                    ),
                  ],
                ),
                onPressed: () => print('Forgot password'),
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
