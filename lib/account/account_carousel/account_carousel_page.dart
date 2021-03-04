import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:flutter/material.dart';

class AccountCarouselPage extends StatelessWidget {
  final Account account;

  AccountCarouselPage({Key key, @required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            account.name,
            style: TextStyle(color: Colors.grey[100]),
          ),
          Text(
            formatToCurrency(account.balance),
            style: TextStyle(
              color: Colors.grey[100],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(
          account.color.alpha,
          account.color.red,
          account.color.green,
          account.color.blue,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
    );
  }
}
