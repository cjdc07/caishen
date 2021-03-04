import 'package:cjdc_money_manager/account/account_form/account_form.dart';
import 'package:cjdc_money_manager/account/account_query.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_form/app_transaction_form.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_query.dart';
import 'package:cjdc_money_manager/cash_flow/statistics.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:cjdc_money_manager/resources/app_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CashFlow extends StatefulWidget {
  @override
  _CashFlowState createState() => _CashFlowState();
}

// TODO: Getting bloated. Separate components!
class _CashFlowState extends State<CashFlow> {
  String _page = "Accounts";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CashFlowData>(
      create: (context) => CashFlowData.getInstance(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          actions: [
            _page == "Accounts"
                ? IconButton(
                    icon: Icon(Icons.more_horiz),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          bottom: true,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            height: MediaQuery.of(context).size.height / 5,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.drag_handle_outlined),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 16.0),
                                    child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        color: Colors.cyan,
                                        child: const Text(
                                          'Create Transaction',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return ChangeNotifierProvider<
                                                    CashFlowData>.value(
                                                  // TODO: maybe just pass account and transaction type
                                                  //       as args so provider will not be used in TransactionForm()
                                                  value: CashFlowData
                                                      .getInstance(),
                                                  child: TransactionForm(),
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                  ),
                                  Container(
                                    child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      color: Colors.cyan,
                                      child: const Text(
                                        'Create Account',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return ChangeNotifierProvider<
                                                  CashFlowData>.value(
                                                value:
                                                    CashFlowData.getInstance(),
                                                child: AccountForm(),
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
                : Container(),
          ],
          title: GestureDetector(
            child: Row(
              children: [
                Text(_page),
                Icon(Icons.arrow_drop_down),
              ],
            ),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return SafeArea(
                  bottom: true,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    height: MediaQuery.of(context).size.height / 5,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.drag_handle_outlined),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // TODO: Do not show button of current screen
                          Container(
                            margin: EdgeInsets.only(bottom: 16.0),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              color: Colors.cyan,
                              child: const Text(
                                'Cash Flow',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: () => setState(
                                () {
                                  _page = 'Accounts';
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              color: Colors.cyan,
                              child: const Text(
                                'Statistics',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: () => setState(
                                () {
                                  _page = 'Statistics';
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Colors.grey[850],
          elevation: 0.0,
        ),
        body: _page == 'Accounts'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AccountQuery(),
                  AppConfig.of(context).buildFlavor == "Development"
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Center(
                            child: Text(
                                'Running in ${AppConfig.of(context).buildFlavor} mode'),
                          ),
                        )
                      : Container(),
                  Expanded(child: AppTransactionQuery()),
                ],
              )
            : Statistics(),
      ),
    );
  }
}
