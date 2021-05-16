import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/cash_flow/cash_flow.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/statistics/statistics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppNavigation extends StatefulWidget {
  final List<Account> accounts;
  final List<AppTransactionCategory> appTransactionCategories;
  const AppNavigation({
    Key key,
    this.accounts,
    this.appTransactionCategories,
  }) : super(key: key);

  @override
  _AppNavigationState createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    Statistics(),
    Column(
      children: [Text('Investments')],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    ),
    CashFlow(),
    Column(
      children: [Text('Goals')],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    ),
    Column(
      children: [Text('Profile Management')],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<AccountNotifier>(context, listen: false)
        .setAccounts(widget.accounts);
    Provider.of<AppTransactionNotifier>(context, listen: false)
        .setAppTransactionCategories(widget.appTransactionCategories);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: _screens,
        index: _selectedIndex,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.black,
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              label: 'Investments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Cash Flow',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_rounded),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
