import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTransactionMutation extends StatelessWidget {
  final formKey;
  final AppTransaction oldAppTransaction;
  final String accountId;
  final String appTransactionTypeValue;
  final TextEditingController descriptionFieldController;
  final TextEditingController amountFieldController;
  final TextEditingController fromFieldController;
  final TextEditingController toFieldController;
  final AppTransactionCategory appTransactionCategoryFieldValue;
  final String transferAccountFieldValue;
  final TextEditingController notesFieldController;
  final Function setIsSaving;
  final bool isSaving;
  final DateTime dateTimeValue;

  AppTransactionMutation({
    Key key,
    @required this.formKey,
    @required this.accountId,
    @required this.appTransactionTypeValue,
    @required this.descriptionFieldController,
    @required this.amountFieldController,
    this.oldAppTransaction,
    this.fromFieldController,
    this.toFieldController,
    this.transferAccountFieldValue,
    @required this.appTransactionCategoryFieldValue,
    @required this.notesFieldController,
    @required this.setIsSaving,
    @required this.isSaving,
    @required this.dateTimeValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return Container();
    }

    return IconButton(
      icon: Icon(Icons.check, color: Colors.cyan),
      onPressed: () async {
        if (!formKey.currentState.validate()) {
          return;
        }

        setIsSaving(true);

        final CollectionReference appTransactionsRef =
            FirebaseFirestore.instance.collection('appTransactions');

        final CollectionReference accountsRef =
            FirebaseFirestore.instance.collection('accounts');

        final CollectionReference appTransactionCategoriesRef =
            FirebaseFirestore.instance.collection('appTransactionCategories');

        final DocumentReference accountDocumentRef = accountsRef.doc(accountId);

        final DocumentReference appTransactionCategoryDocumentRef =
            appTransactionTypeValue != TRANSFER
                ? appTransactionCategoriesRef
                    .doc(appTransactionCategoryFieldValue.id)
                : (await appTransactionCategoriesRef
                        .where('key', isEqualTo: 'transfer')
                        .get())
                    .docs[0]
                    .reference;

        AppTransaction appTransaction = new AppTransaction(
          id: oldAppTransaction != null ? oldAppTransaction.id : null,
          account: accountDocumentRef,
          amount: double.parse(amountFieldController.text.trim()),
          category: appTransactionCategoryDocumentRef,
          description: appTransactionTypeValue != TRANSFER
              ? descriptionFieldController.text.trim()
              : 'Transfer',
          from: fromFieldController.text.isNotEmpty
              ? fromFieldController.text.trim()
              : appTransactionTypeValue != TRANSFER
                  ? 'Me'
                  : accountId,
          notes: notesFieldController.text.trim(),
          to: toFieldController.text.isNotEmpty
              ? toFieldController.text.trim()
              : appTransactionTypeValue != TRANSFER
                  ? 'Me'
                  : transferAccountFieldValue,
          type: appTransactionTypeValue.trim(),
          createdAt: dateTimeValue,
          updatedAt: dateTimeValue,
        );

        DocumentSnapshot snapshot = await accountDocumentRef.get();
        Map<String, dynamic> accountData = snapshot.data();
        accountData['id'] = snapshot.id;
        Account account = Account.parse(accountData);

        List<Account> accounts = context.read<AccountNotifier>().getAccounts();
        List<Account> updatedAccounts = new List.from(accounts);

        Map<String, List<AppTransaction>> appTransactions =
            context.read<AppTransactionNotifier>().getAppTransactions();
        Map<String, List<AppTransaction>> updatedAppTransactions =
            new Map.from(appTransactions);

        if (oldAppTransaction != null) {
          appTransactionsRef
              .doc(oldAppTransaction.id)
              .update(appTransaction.toMap());

          if (appTransaction.type == INCOME) {
            account.deduct(oldAppTransaction.amount);
            account.add(appTransaction.amount);
            await accountDocumentRef.update(account.toMap());
          } else if (appTransaction.type == EXPENSE) {
            account.add(oldAppTransaction.amount);
            account.deduct(appTransaction.amount);
            await accountDocumentRef.update(account.toMap());
          } else {
            account.add(oldAppTransaction.amount);
            account.deduct(appTransaction.amount);
            await accountDocumentRef.update(account.toMap());

            Account targetAccount = context
                .read<AccountNotifier>()
                .getAccounts()
                .singleWhere((e) => e.id == appTransaction.to);

            targetAccount.deduct(oldAppTransaction.amount);
            targetAccount.add(appTransaction.amount);

            await accountsRef
                .doc(targetAccount.id)
                .update(targetAccount.toMap());

            if (updatedAppTransactions[targetAccount.id] == null) {
              // load data from firebase to cache
              updatedAppTransactions[targetAccount.id] = [
                ...(await appTransactionsRef
                        .where('account',
                            isEqualTo: accountsRef.doc(targetAccount.id))
                        .get())
                    .docs,
                ...(await appTransactionsRef
                        .where('to', isEqualTo: targetAccount.id)
                        .get())
                    .docs
              ].map((appTransaction) {
                Map<String, dynamic> data = appTransaction.data();
                data['id'] = appTransaction.id;
                return AppTransaction.parse(data);
              }).toList();
            }

            int appTransactionIndex = updatedAppTransactions[targetAccount.id]
                .indexWhere((e) => e.id == appTransaction.id);

            updatedAppTransactions[targetAccount.id][appTransactionIndex] =
                appTransaction;

            // Update target account in cache
            int targetAccountIndex =
                updatedAccounts.indexWhere((e) => e.id == targetAccount.id);

            updatedAccounts[targetAccountIndex] = targetAccount;
          }
        } else {
          DocumentReference docRef =
              await appTransactionsRef.add(appTransaction.toMap());

          appTransaction.id = docRef.id;

          // Update account according to transaction
          if (appTransaction.type == INCOME) {
            account.add(appTransaction.amount);
            await accountDocumentRef.update(account.toMap());
          } else if (appTransaction.type == EXPENSE) {
            account.deduct(appTransaction.amount);
            await accountDocumentRef.update(account.toMap());
          } else {
            // Deduct amount from source account and update firebase
            account.deduct(appTransaction.amount);
            await accountDocumentRef.update(account.toMap());

            // Add amount to target account and update firebase
            Account targetAccount = context
                .read<AccountNotifier>()
                .getAccounts()
                .singleWhere((account) => account.id == appTransaction.to);

            targetAccount.add(appTransaction.amount);

            await accountsRef
                .doc(appTransaction.to)
                .update(targetAccount.toMap());

            // Add appTransaction to target account too in cache
            if (updatedAppTransactions[targetAccount.id] == null) {
              // load data from firebase to cache
              updatedAppTransactions[targetAccount.id] = [
                ...(await appTransactionsRef
                        .where('account',
                            isEqualTo: accountsRef.doc(targetAccount.id))
                        .get())
                    .docs,
                ...(await appTransactionsRef
                        .where('to', isEqualTo: targetAccount.id)
                        .get())
                    .docs
              ].map((appTransaction) {
                Map<String, dynamic> data = appTransaction.data();
                data['id'] = appTransaction.id;
                return AppTransaction.parse(data);
              }).toList();
            } else {
              updatedAppTransactions[targetAccount.id].add(appTransaction);
            }

            // Update target account in cache
            int targetAccountIndex =
                updatedAccounts.indexWhere((e) => e.id == targetAccount.id);
            updatedAccounts[targetAccountIndex] = targetAccount;
          }
        }

        /* Update AppTransactions Cache */
        if (oldAppTransaction != null) {
          int appTransactionIndex = updatedAppTransactions[account.id]
              .indexWhere((e) => e.id == appTransaction.id);

          updatedAppTransactions[account.id][appTransactionIndex] =
              appTransaction;
        } else {
          updatedAppTransactions[account.id].add(appTransaction);
        }

        context
            .read<AppTransactionNotifier>()
            .setAppTransactions(updatedAppTransactions);

        /* Update Accounts Cache */
        int accountIndex =
            updatedAccounts.indexWhere((e) => e.id == account.id);
        updatedAccounts[accountIndex] = account;
        context
            .read<AccountNotifier>()
            .setAppTransactionType(appTransactionTypeValue);
        context.read<AccountNotifier>().setAccounts(updatedAccounts);
        context
            .read<AccountNotifier>()
            .setSelectedAccount(account, notify: true);

        Navigator.pop(context);
      },
    );
  }
}
