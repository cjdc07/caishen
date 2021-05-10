import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_form.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTransactionItem extends StatefulWidget {
  final AppTransaction appTransaction;
  final Account account;

  AppTransactionItem({
    Key key,
    this.appTransaction,
    this.account,
  }) : super(key: key);

  @override
  _AppTransactionItemState createState() => _AppTransactionItemState();
}

class _AppTransactionItemState extends State<AppTransactionItem> {
  final CollectionReference appTransactionsRef =
      FirebaseFirestore.instance.collection('appTransactions');
  final CollectionReference accountsRef =
      FirebaseFirestore.instance.collection('accounts');

  @override
  Widget build(BuildContext context) {
    AppTransactionCategory appTransactionCategory =
        Provider.of<AppTransactionNotifier>(context, listen: false)
            .getAppTransactionCategories()
            .singleWhere(
              (category) => category.id == widget.appTransaction.category.id,
            );

    bool isReceived = widget.appTransaction.type == INCOME;
    String to = widget.appTransaction.to;
    String from = widget.appTransaction.from;

    if (widget.appTransaction.type == TRANSFER) {
      final accounts = Map.fromIterable(
        Provider.of<AccountNotifier>(context, listen: false).getAccounts(),
        key: (account) => account.id,
        value: (account) => account,
      );

      isReceived = to == widget.account.id;
      to = accounts[to] != null ? accounts[to].name : to;
      from = accounts[from] != null ? accounts[from].name : from;
    }

    return Dismissible(
      key: Key(widget.appTransaction.id),
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete ${widget.appTransaction.description}'),
              content: Text(
                'Are you sure?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        appTransactionsRef.doc(widget.appTransaction.id).delete();

        Map<String, List<AppTransaction>> appTransactions =
            context.read<AppTransactionNotifier>().getAppTransactions();
        Map<String, List<AppTransaction>> updatedAppTransactions =
            new Map.from(appTransactions);
        List<Account> accounts = context.read<AccountNotifier>().getAccounts();
        List<Account> updatedAccounts = new List.from(accounts);

        if (widget.appTransaction.type == INCOME) {
          widget.account.deduct(widget.appTransaction.amount);
          await accountsRef
              .doc(widget.account.id)
              .update(widget.account.toMap());
        } else if (widget.appTransaction.type == EXPENSE) {
          widget.account.add(widget.appTransaction.amount);
          await accountsRef
              .doc(widget.account.id)
              .update(widget.account.toMap());
        } else {
          Account sourceAccount = context
              .read<AccountNotifier>()
              .getAccounts()
              .singleWhere((e) => e.id == widget.appTransaction.from);
          sourceAccount.add(widget.appTransaction.amount);
          await accountsRef.doc(sourceAccount.id).update(sourceAccount.toMap());

          Account targetAccount = context
              .read<AccountNotifier>()
              .getAccounts()
              .singleWhere((e) => e.id == widget.appTransaction.to);
          targetAccount.deduct(widget.appTransaction.amount);
          await accountsRef.doc(targetAccount.id).update(targetAccount.toMap());

          // Remove appTransaction to source and target account in cache
          updatedAppTransactions[sourceAccount.id]
              .removeWhere((e) => e.id == widget.appTransaction.id);

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

          updatedAppTransactions[targetAccount.id]
              .removeWhere((e) => e.id == widget.appTransaction.id);

          // Update source and target account in cache
          int sourceAccountIndex =
              updatedAccounts.indexWhere((e) => e.id == sourceAccount.id);
          int targetAccountIndex =
              updatedAccounts.indexWhere((e) => e.id == targetAccount.id);
          updatedAccounts[sourceAccountIndex] = sourceAccount;
          updatedAccounts[targetAccountIndex] = targetAccount;
        }

        if (widget.appTransaction.type != TRANSFER) {
          // For transfers, cache was already updated above
          updatedAppTransactions[widget.account.id]
              .removeWhere((e) => e.id == widget.appTransaction.id);

          int accountIndex =
              updatedAccounts.indexWhere((e) => e.id == widget.account.id);
          updatedAccounts[accountIndex] = widget.account;
        }

        // Save updatedAppTransactions and updatedAccounts to cache
        context
            .read<AppTransactionNotifier>()
            .setAppTransactions(updatedAppTransactions);
        context.read<AccountNotifier>().setAccounts(updatedAccounts);
        context.read<AccountNotifier>().setSelectedAccount(
              widget.account,
              notify: true,
            );
      },
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
          if (widget.appTransaction.type != TRANSFER) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return TransactionForm(
                    appTransaction: widget.appTransaction,
                    account: widget.account,
                    appTransactiontype: widget.appTransaction.type,
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
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                  "${isReceived ? from : to} | ${appTransactionCategory.value} | ${formatTimeString(widget.appTransaction.createdAt.toString())}",
                  style: TextStyle(fontSize: 13.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
