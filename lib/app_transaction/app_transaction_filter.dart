import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:cjdc_money_manager/common/pill_button.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionFilter extends StatelessWidget {
  final String type;

  TransactionFilter({
    Key key,
    this.type,
  }) : super(key: key);

  void filterTransactionsByType(
      BuildContext context, String appTransactiontype) {
    Provider.of<CashFlowData>(context, listen: false)
        .setSelectedAppTransactionType(appTransactiontype);
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.start,
      children: <Widget>[
        PillButton(
          isActive: type == AppTransactionType.Income,
          label: Text(
            'Income',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => filterTransactionsByType(
            context,
            AppTransactionType.Income,
          ),
        ),
        PillButton(
          isActive: type == AppTransactionType.Expense,
          label: Text(
            'Expenses',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => filterTransactionsByType(
            context,
            AppTransactionType.Expense,
          ),
        ),
        PillButton(
          isActive: type == AppTransactionType.Transfer,
          label: Text(
            'Transfers',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => filterTransactionsByType(
            context,
            AppTransactionType.Transfer,
          ),
        ),
      ],
    );
  }
}
