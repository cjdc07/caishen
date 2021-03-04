import 'package:cjdc_money_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

final loginMutation = gql(r'''
  mutation login($username: String!, $password: String!) {
    login(username: $username, password: $password) {
      __typename
      token
    }
  }
''');

class LoginMutation extends StatelessWidget {
  final formKey;
  final TextEditingController usernameFieldController;
  final TextEditingController passwordFieldController;

  LoginMutation({
    Key key,
    @required this.formKey,
    @required this.usernameFieldController,
    @required this.passwordFieldController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        documentNode: loginMutation,
        update: (Cache cache, QueryResult result) {
          return cache;
        },
        onCompleted: (dynamic resultData) async {
          if (resultData != null) {
            final String token = resultData['login']['token'];

            Hive.box('tokens').put('authToken', token);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
        onError: (error) {
          print(error);
        },
      ),
      builder: (RunMutation login, QueryResult result) {
        Text errorMessage;

        if (result.hasException) {
          errorMessage = Text(
            result.exception.toString(),
            style: TextStyle(color: Colors.red),
          );
        }

        if (result.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            FlatButton(
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => {
                if (formKey.currentState.validate())
                  {
                    login({
                      'username': usernameFieldController.text.trim(),
                      'password': passwordFieldController.text.trim(),
                    })
                  }
              },
              color: Colors.cyan,
              textColor: Colors.white,
            ),
            errorMessage != null ? errorMessage : Container(),
          ],
        );
      },
    );
  }
}
