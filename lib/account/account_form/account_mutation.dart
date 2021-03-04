import 'package:cjdc_money_manager/account/account_color_model.dart';
import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountMutation extends StatelessWidget {
  final formKey;
  final TextEditingController nameFieldController;
  final TextEditingController balanceFieldController;
  final Map<String, int> color;
  final Function setIsSaving;
  final bool isSaving;

  AccountMutation({
    Key key,
    @required this.formKey,
    @required this.nameFieldController,
    @required this.balanceFieldController,
    @required this.color,
    @required this.setIsSaving,
    @required this.isSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return Container();
    }
    return IconButton(
      icon: Icon(Icons.check, color: Colors.cyan),
      onPressed: () async {
        if (formKey.currentState.validate()) {
          setIsSaving(true);

          final CollectionReference accountCollectionReference =
              FirebaseFirestore.instance.collection('accounts');

          DateTime now = DateTime.now();

          Account account = new Account(
            name: nameFieldController.text.trim(),
            balance: double.parse(balanceFieldController.text.trim()),
            color: AccountColor.parse(color),
            createdAt: now,
            updatedAt: now,
          );

          accountCollectionReference.add(account.toMap()).then((value) async {
            final CollectionReference appTransactionsCollectionReference =
                FirebaseFirestore.instance.collection('appTransactions');

            final CollectionReference
                appTransactionCategoryCollectionReference = FirebaseFirestore
                    .instance
                    .collection('appTransactionCategories');

            QuerySnapshot appTransactionCategorySnapshot =
                (await appTransactionCategoryCollectionReference
                    .where('name', isEqualTo: 'Initial Balance')
                    .get());

            AppTransaction transaction = new AppTransaction(
              account: value,
              amount: account.balance,
              createdAt: now,
              updatedAt: now,
              from: 'Me',
              category: appTransactionCategorySnapshot.docs[0].reference,
              description: 'Initial Balance',
              to: 'Me',
              type: AppTransactionType.Income,
            );

            appTransactionsCollectionReference.add(transaction.toMap());

            int totalAccounts =
                Provider.of<CashFlowData>(context, listen: false)
                    .getAccounts()
                    .length;

            Provider.of<CashFlowData>(context, listen: false)
                .setSelectedAccountIndex(totalAccounts);

            Navigator.pop(context);
          });

          // TODO: create timeout logic to Navigator.pop(context) to handle offline or intermittent net
        }
      },
    );
  }
}
