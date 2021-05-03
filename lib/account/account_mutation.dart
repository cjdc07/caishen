import 'package:cjdc_money_manager/account/account.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_model_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO:
// 1. Create AppTransactionCategory class with key, value, type
// 2. Update appTransactionCategories in prod
class AccountMutation extends StatelessWidget {
  final formKey;
  final TextEditingController nameFieldController;
  final TextEditingController balanceFieldController;
  final AccountColor color;
  final AccountType type;
  final Function setIsLoading;
  final bool isLoading;
  final Account oldAccount; // if null, create new else update

  AccountMutation({
    Key key,
    @required this.formKey,
    @required this.nameFieldController,
    @required this.balanceFieldController,
    @required this.color,
    @required this.type,
    @required this.setIsLoading,
    @required this.isLoading,
    @required this.oldAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container();
    }

    return IconButton(
      icon: Icon(Icons.check, color: Colors.cyan),
      onPressed: () async {
        if (!formKey.currentState.validate()) {
          return;
        }

        setIsLoading(true);

        final CollectionReference accountCollectionRef =
            FirebaseFirestore.instance.collection('accounts');

        final CollectionReference appTransactionsCollectionRef =
            FirebaseFirestore.instance.collection('appTransactions');

        final CollectionReference appTransactionCategoryCollectionRef =
            FirebaseFirestore.instance.collection('appTransactionCategories');

        DateTime now = DateTime.now();

        Account account = new Account(
          id: oldAccount != null ? oldAccount.id : null,
          name: nameFieldController.text.trim(),
          balance: double.parse(balanceFieldController.text.trim()),
          color: color,
          type: type,
          createdAt: oldAccount != null ? oldAccount.createdAt : now,
          updatedAt: now,
        );

        List<Account> accounts =
            context.read<AccountModelNotifier>().getAccounts();
        List<Account> updatedAccounts = new List.from(accounts);

        if (oldAccount != null) {
          await accountCollectionRef.doc(oldAccount.id).update(account.toMap());
          int index = updatedAccounts.indexWhere((acc) => acc.id == account.id);
          updatedAccounts[index] = account;

          // TODO: add alert when this happens
          if (account.balance > oldAccount.balance) {
            // Add income transaction if new balance > old balance
            QuerySnapshot appTransactionCategorySnapshot =
                await appTransactionCategoryCollectionRef
                    .where('key', isEqualTo: 'accountAdjustment')
                    .get();

            AppTransaction appTransaction = new AppTransaction(
              account: accountCollectionRef.doc(oldAccount.id),
              amount: account.balance - oldAccount.balance,
              createdAt: now,
              updatedAt: now,
              from: 'me',
              category: appTransactionCategorySnapshot.docs[0].reference,
              description: 'Account Adjustment',
              to: 'me',
              type: AppTransactionType.Income,
            );

            appTransactionsCollectionRef.add(appTransaction.toMap());
          } else if (account.balance < oldAccount.balance) {
            // Add expense transaction if new balance < old balance
            QuerySnapshot appTransactionCategorySnapshot =
                await appTransactionCategoryCollectionRef
                    .where('key', isEqualTo: 'accountAdjustment')
                    .get();

            AppTransaction appTransaction = new AppTransaction(
              account: accountCollectionRef.doc(oldAccount.id),
              amount: oldAccount.balance - account.balance,
              createdAt: now,
              updatedAt: now,
              from: 'me',
              category: appTransactionCategorySnapshot.docs[0].reference,
              description: 'Account Adjustment',
              to: 'me',
              type: AppTransactionType.Expense,
            );

            appTransactionsCollectionRef.add(appTransaction.toMap());
          }
        } else {
          DocumentReference docRef =
              await accountCollectionRef.add(account.toMap());

          account.id = docRef.id;

          updatedAccounts.add(account);

          // Add income transaction on account creation
          QuerySnapshot appTransactionCategorySnapshot =
              await appTransactionCategoryCollectionRef
                  .where('key', isEqualTo: 'initialBalance')
                  .get();

          AppTransaction appTransaction = new AppTransaction(
            account: docRef,
            amount: account.balance,
            createdAt: now,
            updatedAt: now,
            from: 'me',
            category: appTransactionCategorySnapshot.docs[0].reference,
            description: 'Initial Balance',
            to: 'me',
            type: AppTransactionType.Income,
          );

          appTransactionsCollectionRef.add(appTransaction.toMap());
        }

        context.read<AccountModelNotifier>().setAccounts(updatedAccounts);
        context
            .read<AccountModelNotifier>()
            .setSelectedAccount(account, notify: true);

        Navigator.pop(context);
      },
    );
  }
}
