import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/statistics/income_expense_statistics_card.dart';
import 'package:cjdc_money_manager/statistics/total_balance_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int month = DateTime.may;
  int year = 2021;

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> _computeAppTransactions(
    List<AppTransaction> appTransactions,
    List<AppTransactionCategory> appTransactionCategories,
  ) {
    Map<String, dynamic> results = {
      "INCOME": {"total": 0, "title": "Total Income", "categoryStats": {}},
      "EXPENSE": {"total": 0, "title": "Total Expense", "categoryStats": {}},
    };

    Iterable<AppTransaction> filteredAppTransactions =
        appTransactions.where((appTransaction) {
      if (appTransaction.type == TRANSFER) {
        return false;
      }

      // if (incomeExpenseMonthFilter == "all" &&
      //     incomeExpenseYearFilter == "all") {
      //   return true;
      // }

      // if (incomeExpenseMonthFilter ==
      //         appTransaction.createdAt.month.toString() &&
      //     incomeExpenseYearFilter == "all") {
      //   return true;
      // }

      // if (incomeExpenseMonthFilter == "all" &&
      //     incomeExpenseYearFilter == appTransaction.createdAt.year.toString()) {
      //   return true;
      // }

      if (month == appTransaction.createdAt.month &&
          year == appTransaction.createdAt.year) {
        return true;
      }

      return false;
    });

    Map<String, dynamic> appTransactionCategoriesMap = Map.fromIterable(
      appTransactionCategories,
      key: (doc) => doc.id,
      value: (doc) => doc,
    );

    for (AppTransaction appTransaction in filteredAppTransactions) {
      results[appTransaction.type]['total'] += appTransaction.amount;

      String categoryName =
          appTransactionCategoriesMap[appTransaction.category.id.toString()]
              .value;

      if (results[appTransaction.type]['categoryStats'][categoryName] == null) {
        results[appTransaction.type]['categoryStats'][categoryName] = 0;
      }

      results[appTransaction.type]['categoryStats'][categoryName] +=
          appTransaction.amount;
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    print('statistics: you should only see me once');
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Statistics'),
      ),
      body: ListView(
        children: [
          Consumer<AccountNotifier>(
            builder: (context, accountModel, child) {
              List<Account> accounts = accountModel.getAccounts();

              double total = accounts.fold(
                0,
                (previous, account) => previous.toDouble() + account.balance,
              );

              return TotalBalanceCard(
                total: total,
              );
            },
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('appTransactions')
                .where(
                  "createdAt",
                  isGreaterThanOrEqualTo:
                      new DateTime(year, month), // Start of month
                )
                .where(
                  "createdAt",
                  isLessThanOrEqualTo:
                      new DateTime(year, month + 1, 0), // End of month
                )
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Failed to retrieve transactions'));
              }

              if (snapshot.connectionState == ConnectionState.done) {
                List<AppTransaction> appTransactions =
                    snapshot.data.docs.map((transaction) {
                  Map<String, dynamic> data = transaction.data();
                  data['id'] = transaction.id;
                  return AppTransaction.parse(data);
                }).toList();

                List<AppTransactionCategory> categories =
                    Provider.of<AppTransactionNotifier>(context)
                        .getAppTransactionCategories();

                Map<String, dynamic> results =
                    _computeAppTransactions(appTransactions, categories);

                return IncomeExpenseStatisticsCard(
                  incomeStatistics: results[INCOME],
                  expenseStatistics: results[EXPENSE],
                );
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
