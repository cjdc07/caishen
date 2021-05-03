import 'package:cjdc_money_manager/account/account.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  AccountCard({Key key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Card(
          color: Color.fromARGB(
            account.color.alpha,
            account.color.red,
            account.color.green,
            account.color.blue,
          ),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ExpansionTile(
            trailing: Icon(
              Icons.bar_chart_rounded,
            ),
            initiallyExpanded: true,
            title: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatToCurrency(account.balance),
                    style: TextStyle(
                      color: Colors.grey[100],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            children: [Text("Account Stats Here")],
          ),
        )
      ],
    );
  }
}
