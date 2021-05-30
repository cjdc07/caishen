import 'package:cjdc_money_manager/app_transaction/app_transaction_item.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:flutter/material.dart';

class CategoryAppTransactions extends StatelessWidget {
  final List<AppTransaction> appTransactions;
  final String categoryName;

  CategoryAppTransactions({
    Key key,
    this.appTransactions,
    this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24.0),
              shrinkWrap: true,
              itemCount: appTransactions.length,
              itemBuilder: (context, index) {
                AppTransaction appTransaction = appTransactions[index];

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: AppTransactionItem(
                    account: null, // TODO: pass account of appTransaction
                    appTransaction: appTransaction,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
