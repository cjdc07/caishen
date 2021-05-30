import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_item.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../extensions.dart';

class AppTransactions extends StatelessWidget {
  final CollectionReference appTransactionsRef =
      FirebaseFirestore.instance.collection('appTransactions');

  final Account account;
  final String appTransactiontype;

  AppTransactions({
    Key key,
    this.account,
    this.appTransactiontype,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DocumentReference accountDocRef =
        FirebaseFirestore.instance.collection('accounts').doc(account.id);

    Map<String, List<AppTransaction>> appTransactionsCache =
        Provider.of<AppTransactionNotifier>(context, listen: true)
            .getAppTransactions();

    if (appTransactionsCache.containsKey(accountDocRef.id)) {
      return AppTransactionsCardList(
        appTransactions: appTransactionsCache[accountDocRef.id]
            .where(
              (appTransaction) => appTransaction.type == appTransactiontype,
            )
            .toList(),
        appTransactiontype: appTransactiontype,
        account: account,
      );
    }

    return FutureBuilder<List<QuerySnapshot>>(
      future: Future.wait([
        appTransactionsRef.where('account', isEqualTo: accountDocRef).get(),
        appTransactionsRef.where('to', isEqualTo: accountDocRef.id).get()
      ]),
      builder:
          (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error occured when fetching transactions'));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          /* Parse data from Firebase collections */
          // TODO: Replace Models parseList method to these?
          List<AppTransaction> appTransactions = [
            ...snapshot.data[0].docs, // All transactions for this account
            ...snapshot.data[1].docs, // All transfer transaction received
          ].map((appTransaction) {
            Map<String, dynamic> data = appTransaction.data();
            data['id'] = appTransaction.id;
            return AppTransaction.parse(data);
          }).toList();
          /****************************************/

          /* Save AppTransactions to cache */
          Map<String, List<AppTransaction>> updatedAppTransactionsCache =
              Map.from(appTransactionsCache);

          updatedAppTransactionsCache[accountDocRef.id] = appTransactions;

          Provider.of<AppTransactionNotifier>(context, listen: false)
              .setAppTransactions(updatedAppTransactionsCache);
          /*********************************/

          return AppTransactionsCardList(
            appTransactions: appTransactions
                .where(
                  (appTransaction) => appTransaction.type == appTransactiontype,
                )
                .toList(),
            appTransactiontype: appTransactiontype,
            account: account,
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class AppTransactionsCardList extends StatelessWidget {
  final Account account;
  final List<AppTransaction> appTransactions;
  final String appTransactiontype;

  AppTransactionsCardList({
    Key key,
    this.account,
    this.appTransactions,
    this.appTransactiontype,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (appTransactions.isEmpty) {
      return Center(
        child: Text(
          'No ${appTransactiontype.capitalize()} records!',
          style: TextStyle(fontSize: 16, color: Colors.cyan),
        ),
      );
    }

    final Map<String, List<AppTransaction>> groupedTransactionsByCreationDate =
        AppTransaction.groupTransactionsByCreationDate(appTransactions);

    List<String> dates = groupedTransactionsByCreationDate.keys.toList();

    dates.sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            // TODO: Maintain state of ListView when going back from another screen
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24.0),
              shrinkWrap: true,
              itemCount: groupedTransactionsByCreationDate.length,
              itemBuilder: (context, index) {
                String date = dates[index];

                final List<Widget> transactionItems =
                    groupedTransactionsByCreationDate[date]
                        .map(
                          (transaction) => AppTransactionItem(
                            account: account,
                            appTransaction: transaction,
                          ),
                        )
                        .toList();

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ExpansionTile(
                    initiallyExpanded: index == 0,
                    title: Text(
                      formatDateString(date),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[200],
                      ),
                    ),
                    children: transactionItems,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
