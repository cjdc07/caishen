import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTransactionMutation extends StatelessWidget {
  final formKey;
  final AppTransaction oldAppTransaction;
  final String accountId;
  final String selectedAppTransactionTypeValue;
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
    @required this.selectedAppTransactionTypeValue,
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
        if (formKey.currentState.validate()) {
          setIsSaving(true);

          final CollectionReference appTransactionsCollectionReference =
              FirebaseFirestore.instance.collection('appTransactions');

          final CollectionReference accountCollectionReference =
              FirebaseFirestore.instance.collection('accounts');

          final CollectionReference appTransactionCategoryCollectionReference =
              FirebaseFirestore.instance.collection('appTransactionCategories');

          final DocumentReference accountDocumentReference =
              accountCollectionReference.doc(accountId);

          final DocumentReference appTransactionCategoryDocumentReference =
              appTransactionCategoryCollectionReference
                  .doc(appTransactionCategoryFieldValue.id);

          DocumentSnapshot snapshot = await accountDocumentReference.get();

          Map<String, dynamic> accountData = snapshot.data();
          accountData['id'] = snapshot.id;

          Account account = Account.parse(accountData);

          AppTransaction appTransaction = new AppTransaction(
            account: accountDocumentReference,
            amount: double.parse(amountFieldController.text.trim()),
            category: appTransactionCategoryDocumentReference,
            description: descriptionFieldController.text.trim(),
            from: fromFieldController.text.isNotEmpty
                ? fromFieldController.text.trim()
                : transferAccountFieldValue != null
                    ? accountId
                    : 'Me',
            notes: notesFieldController.text.trim(),
            to: toFieldController.text.isNotEmpty
                ? toFieldController.text.trim()
                : transferAccountFieldValue != null
                    ? transferAccountFieldValue
                    : 'Me',
            type: selectedAppTransactionTypeValue.trim(),
            createdAt: dateTimeValue,
            updatedAt: dateTimeValue,
          );

          if (oldAppTransaction != null) {
            appTransactionsCollectionReference
                .doc(oldAppTransaction.id)
                .update(appTransaction.toMap());

            account.processUpdatedAppTransaction(
              oldAppTransaction,
              appTransaction,
              accountCollectionReference,
            );
          } else {
            account.processCreatedAppTransaction(
              appTransaction,
              accountCollectionReference,
            );

            appTransactionsCollectionReference.add(appTransaction.toMap());
          }

          Navigator.pop(context);
        }
      },
    );
  }
}
