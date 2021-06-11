import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/user_profile_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/user_profile/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      icon: Icon(Icons.check, color: Colors.green),
      onPressed: () async {
        if (!formKey.currentState.validate()) {
          return;
        }

        setIsLoading(true);

        UserProfile userProfile =
            context.read<UserProfileNotifier>().getUserProfile();

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
          balance: double.parse(
            balanceFieldController.text
                .trim()
                .replaceAll(RegExp(',|[a-zA-Z₱\$]'), ''),
          ),
          color: color,
          type: type,
          createdAt: oldAccount != null ? oldAccount.createdAt : now,
          updatedAt: now,
          user: userProfile.id,
        );

        List<Account> accounts = context.read<AccountNotifier>().getAccounts();
        List<Account> updatedAccounts = new List.from(accounts);

        AppTransaction appTransaction;
        DocumentReference appTransactionDocRef;

        if (oldAccount != null) {
          await accountCollectionRef.doc(account.id).update(account.toMap());
          int index = updatedAccounts.indexWhere((e) => e.id == account.id);
          updatedAccounts[index] = account;

          // TODO: add alert when this happens
          if (account.balance > oldAccount.balance) {
            // Add income transaction if new balance > old balance
            QuerySnapshot appTransactionCategorySnapshot =
                await appTransactionCategoryCollectionRef
                    .where('key', isEqualTo: 'accountAdjustment')
                    .get();

            appTransaction = new AppTransaction(
              account: accountCollectionRef.doc(oldAccount.id),
              amount: account.balance - oldAccount.balance,
              createdAt: now,
              updatedAt: now,
              from: 'me',
              category: appTransactionCategorySnapshot.docs[0].reference,
              description: 'Account Adjustment',
              to: 'me',
              type: INCOME,
              user: userProfile.id,
            );

            appTransactionDocRef =
                await appTransactionsCollectionRef.add(appTransaction.toMap());
          } else if (account.balance < oldAccount.balance) {
            // Add expense transaction if new balance < old balance
            QuerySnapshot appTransactionCategorySnapshot =
                await appTransactionCategoryCollectionRef
                    .where('key', isEqualTo: 'accountAdjustment')
                    .get();

            appTransaction = new AppTransaction(
              account: accountCollectionRef.doc(account.id),
              amount: oldAccount.balance - account.balance,
              createdAt: now,
              updatedAt: now,
              from: 'me',
              category: appTransactionCategorySnapshot.docs[0].reference,
              description: 'Account Adjustment',
              to: 'me',
              type: EXPENSE,
              user: userProfile.id,
            );

            appTransactionDocRef =
                await appTransactionsCollectionRef.add(appTransaction.toMap());
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

          appTransaction = new AppTransaction(
            account: docRef,
            amount: account.balance,
            createdAt: now,
            updatedAt: now,
            from: 'me',
            category: appTransactionCategorySnapshot.docs[0].reference,
            description: 'Initial Balance',
            to: 'me',
            type: INCOME,
            user: userProfile.id,
          );

          appTransactionDocRef =
              await appTransactionsCollectionRef.add(appTransaction.toMap());
        }

        /* Update Accounts Cache */
        context.read<AccountNotifier>().setAccounts(updatedAccounts);
        context
            .read<AccountNotifier>()
            .setSelectedAccount(account, notify: true);

        /* Update AppTransactions Cache */
        Map<String, List<AppTransaction>> appTransactions =
            context.read<AppTransactionNotifier>().getAppTransactions();
        Map<String, List<AppTransaction>> updatedAppTransactions =
            new Map.from(appTransactions);

        if (appTransaction != null) {
          appTransaction.id = appTransactionDocRef.id;

          if (updatedAppTransactions.containsKey(account.id)) {
            updatedAppTransactions[account.id].add(appTransaction);
          } else {
            updatedAppTransactions[account.id] = [appTransaction];
          }

          context
              .read<AppTransactionNotifier>()
              .setAppTransactions(updatedAppTransactions, notify: true);
        }

        Navigator.pop(context);
      },
    );
  }
}
