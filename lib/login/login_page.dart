import 'package:cjdc_money_manager/login/login_mutation.dart';
import 'package:cjdc_money_manager/login/password_field.dart';
import 'package:cjdc_money_manager/login/username_field.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();

  @override
  void dispose() {
    usernameFieldController.dispose();
    passwordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 16.0,
                    ),
                    child: UsernameField(controller: usernameFieldController),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 32.0,
                    ),
                    child: PasswordField(controller: passwordFieldController),
                  ),
                ],
              ),
              Container(
                child: LoginMutation(
                  formKey: _formKey,
                  passwordFieldController: passwordFieldController,
                  usernameFieldController: usernameFieldController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
