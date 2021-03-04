import 'package:cjdc_money_manager/account/account_carousel/account_carousel.dart';
import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/account/account_query_loading_indicator.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class AccountQuery extends StatelessWidget {
  final CollectionReference accounts =
      FirebaseFirestore.instance.collection('accounts');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: accounts.snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return SafeArea(child: Text(snapshot.error));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return AccountQueryLoadingIndicator();
        }

        List<Map<String, dynamic>> payload = snapshot.data.docs.map((account) {
          Map<String, dynamic> data = account.data();
          data['id'] = account.id;
          return data;
        }).toList();

        final List<Account> accounts = Account.parseList(payload);

        // TODO: This results in 2 calls to changenotifier (here and account and transaction mutation)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<CashFlowData>(context, listen: false)
              .setAccounts(accounts);
        });

        accounts.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AccountCarousel(accounts: accounts),
          ],
        );
      },
    );
  }
}
