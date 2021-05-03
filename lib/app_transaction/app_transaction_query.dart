import 'package:cjdc_money_manager/account/account.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_filter.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_item.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_query_loading_indicator.dart';
import 'package:cjdc_money_manager/change_notifiers/account_model_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTransactionQuery extends StatelessWidget {
  final CollectionReference appTransactionsRef =
      FirebaseFirestore.instance.collection('appTransactions');

  final CollectionReference accountColRef =
      FirebaseFirestore.instance.collection('accounts');

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModelNotifier>(
      builder: (context, cashFlowData, child) {
        Account account = null; // cashFlowData.getSelectedAccount();

        if (account == null) {
          // TODO: Show no data screen
          return Center(
            child: Text('No existing account'),
          );
        }

        final DocumentReference accountDocRef = accountColRef.doc(account.id);

        Query query;

        String appTransactiontype =
            cashFlowData.getSelectedAppTransactionType();

        if (appTransactiontype == AppTransactionType.Transfer) {
          // Transfers is visible to 'from' account and 'to' account
          query =
              appTransactionsRef.where('type', isEqualTo: appTransactiontype);
        } else {
          query = appTransactionsRef
              .where('account', isEqualTo: accountDocRef)
              .where('type', isEqualTo: appTransactiontype);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return SafeArea(child: Text(snapshot.error));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TransactionFilter(
                    type: appTransactiontype,
                  ),
                  TransactionQueryLoadingIndicator(),
                ],
              );
            }

            List<Map<String, dynamic>> payload =
                snapshot.data.docs.map((transaction) {
              Map<String, dynamic> data = transaction.data();
              data['id'] = transaction.id;
              return data;
            }).toList();

            if (appTransactiontype == AppTransactionType.Transfer) {
              payload = payload
                  .where((element) =>
                      element['account'] == accountDocRef ||
                      element['to'] == accountDocRef.id)
                  .toList();
            }

            final List<AppTransaction> appTransactions =
                AppTransaction.parseList(payload);

            final Map<String, List<AppTransaction>>
                groupedTransactionsByCreationDate =
                AppTransaction.groupTransactionsByCreationDate(appTransactions);

            List<String> dates =
                groupedTransactionsByCreationDate.keys.toList();

            dates.sort((a, b) => b.compareTo(a));

            return Column(
              children: [
                TransactionFilter(
                  type: appTransactiontype,
                ),
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
                                    onDismiss: (direction) async {
                                      appTransactionsRef
                                          .doc(transaction.id)
                                          .delete();

                                      account.processDeletedAppTransaction(
                                        transaction,
                                        accountColRef,
                                      );
                                    },
                                  ),
                                )
                                .toList();

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: ExpansionTile(
                            initiallyExpanded: index == 0,
                            title: Text(
                              formatDateString(date),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[350],
                              ),
                            ),
                            children: transactionItems,
                          ),
                        );

                        // return Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     Container(
                        //       margin: EdgeInsets.symmetric(
                        //           horizontal: 8.0, vertical: 8.0),
                        //       child: Text(
                        //         formatDateString(date),
                        //         style: TextStyle(
                        //           fontSize: 16.0,
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.grey[350],
                        //         ),
                        //       ),
                        //     ),
                        //     Column(children: transactionItems),
                        //   ],
                        // );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
