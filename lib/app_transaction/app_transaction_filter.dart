import 'package:cjdc_money_manager/common/pill_button.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:flutter/material.dart';

class TransactionFilter extends StatelessWidget {
  final String type;
  final Function setAppTransactionType;

  TransactionFilter({
    Key key,
    this.type,
    this.setAppTransactionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.start,
      children: <Widget>[
        PillButton(
          isActive: type == INCOME,
          label: Text(
            'Income',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => setAppTransactionType(
            INCOME,
          ),
        ),
        PillButton(
          isActive: type == EXPENSE,
          label: Text(
            'Expenses',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => setAppTransactionType(
            EXPENSE,
          ),
        ),
        PillButton(
          isActive: type == TRANSFER,
          label: Text(
            'Transfers',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => setAppTransactionType(
            TRANSFER,
          ),
        ),
      ],
    );
  }
}
