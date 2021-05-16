import 'package:cjdc_money_manager/account/account_form.dart';
import 'package:cjdc_money_manager/account/account_card.dart';
import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_filter.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_form.dart';
import 'package:cjdc_money_manager/app_transaction/app_transactions.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoAccountsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CashFlow extends StatefulWidget {
  @override
  _CashFlowState createState() => _CashFlowState();
}

class _CashFlowState extends State<CashFlow> {
  List<Account> _filteredAccounts;
  Function onModalBottomSheetClose;

  @override
  void initState() {
    super.initState();

    setState(() {
      _filteredAccounts = context.read<AccountNotifier>().getAccounts();

      if (_filteredAccounts != null && _filteredAccounts.length > 0) {
        context
            .read<AccountNotifier>()
            .setSelectedAccount(_filteredAccounts[0]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: prints twice when creating first account
    print('cashflow: you should only see me once');
    return Consumer<AccountNotifier>(
      builder: (context, accountModel, child) {
        _filteredAccounts = accountModel.getAccounts();
        Account selectedAccount = accountModel.getSelectedAccount();
        String appTransactiontype =
            accountModel.getSelectedAppTransactionType() != null
                ? accountModel.getSelectedAppTransactionType()
                : INCOME;

        if (_filteredAccounts.isEmpty && selectedAccount == null) {
          return Center(
            child: Container(
              child: CupertinoButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.cyan),
                    const Text(
                      'Add New Account',
                      style: TextStyle(fontSize: 16, color: Colors.cyan),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return AccountForm();
                      },
                    ),
                  ).then(
                    (value) => setState(
                      () {
                        _filteredAccounts =
                            context.read<AccountNotifier>().getAccounts();
                        context.read<AccountNotifier>().getSelectedAccount();
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.pending_outlined,
                  color: Colors.cyan,
                ),
                onPressed: () => showModalBottomSheet<void>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      bottom: true,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        height: MediaQuery.of(context).size.height / 6,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.drag_handle_rounded),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Container(
                                child: TextButton(
                                  child: const Text(
                                    'Create Transaction',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return TransactionForm(
                                            account: selectedAccount,
                                            appTransactiontype:
                                                appTransactiontype,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  child: const Text(
                                    'Update Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return AccountForm(
                                            account: selectedAccount,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
            title: GestureDetector(
              /* Account Title */
              child: Row(
                children: [
                  Text(
                    selectedAccount.name,
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
              onTap: () => showModalBottomSheet<void>(
                /* Custom Account Picker Bottom Modal */
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setModalState) {
                      onModalBottomSheetClose = () => setModalState(
                            () {
                              _filteredAccounts = accountModel.getAccounts();
                            },
                          );

                      return SafeArea(
                        bottom: true,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.close_rounded,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.cyan,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return AccountForm();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                /* Account search input */
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 8, bottom: 16),
                                  child: CupertinoSearchTextField(
                                    placeholder: 'Search account name',
                                    style: TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      if (value == '') {
                                        setModalState(() {
                                          _filteredAccounts =
                                              accountModel.getAccounts();
                                        });
                                        return;
                                      }

                                      setModalState(
                                        () {
                                          _filteredAccounts = accountModel
                                              .getAccounts()
                                              .where((account) => account.name
                                                  .toLowerCase()
                                                  .contains(value))
                                              .toList();
                                        },
                                      );
                                    },
                                  ),
                                ),

                                /* Account list */
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _filteredAccounts.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Account account =
                                          _filteredAccounts[index];

                                      return ListTile(
                                        onTap: () {
                                          if (account.id !=
                                              selectedAccount.id) {
                                            accountModel.setSelectedAccount(
                                              account,
                                              notify: true,
                                            );
                                          }

                                          Navigator.pop(context);
                                        },
                                        title: Text(
                                          account.name,
                                        ),
                                        trailing: Text(
                                          formatToCurrency(account.balance),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        leading: Container(
                                          child:
                                              selectedAccount.id == account.id
                                                  ? Icon(
                                                      Icons.check,
                                                      size: 16,
                                                    )
                                                  : null,
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              account.color.alpha,
                                              account.color.red,
                                              account.color.green,
                                              account.color.blue,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ).whenComplete(() => onModalBottomSheetClose()),
            ),
            elevation: 0.0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AccountCard(account: selectedAccount),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppConfig.of(context).buildFlavor == "Development"
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Center(
                              child: Text(
                                'Running in ${AppConfig.of(context).buildFlavor} mode',
                              ),
                            ),
                          )
                        : Container(),
                    TransactionFilter(
                      type: appTransactiontype,
                      setAppTransactionType: (type) =>
                          context.read<AccountNotifier>().setAppTransactionType(
                                type,
                                notify: true,
                              ),
                    ),
                    Expanded(
                      child: AppTransactions(
                        account: selectedAccount,
                        appTransactiontype: appTransactiontype,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
