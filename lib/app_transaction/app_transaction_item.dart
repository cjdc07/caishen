import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_form/app_transaction_form.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTransactionItem extends StatefulWidget {
  final AppTransaction appTransaction;
  final Account account;
  final Function onDismiss;

  AppTransactionItem({
    Key key,
    this.appTransaction,
    this.account,
    this.onDismiss,
  }) : super(key: key);

  @override
  _AppTransactionItemState createState() => _AppTransactionItemState();
}

class _AppTransactionItemState extends State<AppTransactionItem> {
  @override
  Widget build(BuildContext context) {
    final accounts = Map.fromIterable(
      Provider.of<CashFlowData>(context).getAccounts(),
      key: (account) => account.id,
      value: (account) => account,
    );

    bool isReceived = widget.appTransaction.type == AppTransactionType.Income;
    String to = widget.appTransaction.to;
    String from = widget.appTransaction.from;

    if (widget.appTransaction.type == AppTransactionType.Transfer) {
      isReceived = to == widget.account.id;
      to = accounts[to] != null ? accounts[to].name : to;
      from = accounts[from] != null ? accounts[from].name : from;
    }

    return FutureBuilder(
      future: widget.appTransaction.getAppTransactionCategory(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          // TODO: Change to shimmer loading
          return Container();
        } else {
          AppTransactionCategory category = snapshot.data;

          return Dismissible(
            key: Key(widget.appTransaction.id),
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Transaction"),
                    content: Text(
                      'Are you sure you wish to delete "${widget.appTransaction.description}" ?',
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: widget.onDismiss,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Icon(
                Icons.delete,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                // TODO: Fix form to allow target transfer account to show source account
                if (widget.appTransaction.type != AppTransactionType.Transfer) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ChangeNotifierProvider<CashFlowData>.value(
                          value: CashFlowData.getInstance(),
                          child: TransactionForm(
                              appTransaction: widget.appTransaction),
                        );
                      },
                    ),
                  );
                } else {
                  final snackBar = SnackBar(
                    content: Text(
                      'We will enable editing of transfer transactions soon!',
                      style: TextStyle(color: Colors.grey[200], fontSize: 16.0),
                    ),
                    backgroundColor: Colors.grey[700],
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Container(
                child: ListTile(
                  trailing: Text(
                    '${isReceived ? "+" : "-"}${formatToCurrency(widget.appTransaction.amount)}',
                    style: TextStyle(
                      color: isReceived ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  title: Text(
                    widget.appTransaction.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.grey[200],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // TODO: change category id to category name
                        "${isReceived ? from : to} | ${category.name} | ${formatTimeString(widget.appTransaction.createdAt.toString())}",
                        style: TextStyle(fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
