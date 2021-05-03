import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_model_notifier.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/firebase_util.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  Future<Map<String, dynamic>> _statistics;

  String incomeExpenseMonthFilter = "all";
  String incomeExpenseYearFilter = "all";

  final List<Map<String, String>> months = [
    {"label": "All", "value": "all"},
    {"label": "Jan", "value": DateTime.january.toString()},
    {"label": "Feb", "value": DateTime.february.toString()},
    {"label": "Mar", "value": DateTime.march.toString()},
    {"label": "Apr", "value": DateTime.april.toString()},
    {"label": "May", "value": DateTime.may.toString()},
    {"label": "Jun", "value": DateTime.june.toString()},
    {"label": "Jul", "value": DateTime.july.toString()},
    {"label": "Aug", "value": DateTime.august.toString()},
    {"label": "Sep", "value": DateTime.september.toString()},
    {"label": "Oct", "value": DateTime.october.toString()},
    {"label": "Nov", "value": DateTime.november.toString()},
    {"label": "Dec", "value": DateTime.december.toString()},
  ];

  final List<Map<String, String>> years = [
    {"label": "All", "value": "all"},
    {"label": "2020", "value": "2020"},
    {"label": "2021", "value": "2021"},
  ];

  @override
  void initState() {
    super.initState();
    // _statistics = _getStatistics();
  }

  Future<Map<String, dynamic>> _getStatistics() async {
    QuerySnapshot snapshot = await FirebaseUtil.getAppTransactionsSnapshot();

    List<dynamic> payload = snapshot.docs.map((transaction) {
      Map<String, dynamic> data = transaction.data();
      data['id'] = transaction.id;
      return data;
    }).toList();

    final List<AppTransaction> appTransactions =
        AppTransaction.parseList(payload);

    Map<String, dynamic> appTransactionsStats = {
      "BALANCE": {"total": 0, "title": "Total Balance"},
      "INCOME": {"total": 0, "title": "Total Income", "categoryStats": {}},
      "EXPENSE": {"total": 0, "title": "Total Expense", "categoryStats": {}},
    };

    appTransactionsStats['BALANCE']['total'] =
        Provider.of<AccountModelNotifier>(context, listen: false)
            .getAccounts()
            .fold(
                0,
                (previousValue, account) =>
                    previousValue.toDouble() + account.balance);

    Iterable<AppTransaction> filteredAppTransactions =
        appTransactions.where((appTransaction) {
      if (appTransaction.type == AppTransactionType.Transfer) {
        return false;
      }

      if (incomeExpenseMonthFilter == "all" &&
          incomeExpenseYearFilter == "all") {
        return true;
      }

      if (incomeExpenseMonthFilter ==
              appTransaction.createdAt.month.toString() &&
          incomeExpenseYearFilter == "all") {
        return true;
      }

      if (incomeExpenseMonthFilter == "all" &&
          incomeExpenseYearFilter == appTransaction.createdAt.year.toString()) {
        return true;
      }

      if (incomeExpenseMonthFilter ==
              appTransaction.createdAt.month.toString() &&
          incomeExpenseYearFilter == appTransaction.createdAt.year.toString()) {
        return true;
      }

      return false;
    });

    List<QueryDocumentSnapshot> appTransactionCategoriesDocs =
        (await FirebaseUtil.getAppTransactionCategoriesSnapshot()).docs;

    Map<String, Map<String, dynamic>> appTransactionCategoriesDocsMap =
        Map.fromIterable(appTransactionCategoriesDocs,
            key: (doc) => doc.id, value: (doc) => doc.data());

    for (AppTransaction appTransaction in filteredAppTransactions) {
      appTransactionsStats[appTransaction.type]['total'] +=
          appTransaction.amount;

      String categoryName =
          appTransactionCategoriesDocsMap[appTransaction.category.id]['name'];

      if (appTransactionsStats[appTransaction.type]['categoryStats']
              [categoryName] ==
          null) {
        appTransactionsStats[appTransaction.type]['categoryStats']
            [categoryName] = 0;
      }

      appTransactionsStats[appTransaction.type]['categoryStats']
          [categoryName] += appTransaction.amount;
    }

    return appTransactionsStats;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Statistics Page"),
    );
    // return FutureBuilder(
    //   future: _statistics,
    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
    //     if (!snapshot.hasData) {
    //       // TODO: Change to shimmer loading
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     } else {
    //       final totalBalanceStat = snapshot.data['BALANCE'];
    //       final incomeStat = snapshot.data[AppTransactionType.Income];
    //       final expenseStat = snapshot.data[AppTransactionType.Expense];

    //       List sortedIncomeCategoryStat =
    //           List.from(incomeStat['categoryStats'].entries.toList());

    //       List sortedExpenseCategoryStat =
    //           List.from(expenseStat['categoryStats'].entries.toList());

    //       sortedIncomeCategoryStat.sort((a, b) => b.value.compareTo(a.value));
    //       sortedExpenseCategoryStat.sort((a, b) => b.value.compareTo(a.value));

    //       Widget totalBalanceStatCard = Card(
    //         margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
    //         child: Container(
    //           padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
    //           width: MediaQuery.of(context).size.width,
    //           height: MediaQuery.of(context).size.height / 9,
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.stretch,
    //             children: [
    //               Row(
    //                 children: [
    //                   Text(
    //                     totalBalanceStat['title'],
    //                     style: TextStyle(fontSize: 16),
    //                   ),
    //                 ],
    //               ),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: [
    //                   Text(
    //                     formatToCurrency(totalBalanceStat['total']),
    //                     style: TextStyle(
    //                       fontSize: 24,
    //                       color: totalBalanceStat['total'] < 0
    //                           ? Colors.red
    //                           : Colors.green,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                     textAlign: TextAlign.end,
    //                   ),
    //                 ],
    //               )
    //             ],
    //           ),
    //         ),
    //       );

    //       Widget incomeExpenseStatCard = Card(
    //         margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
    //         child: ExpansionTile(
    //           title: Container(
    //             padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
    //             child: Column(
    //               children: [
    //                 Row(
    //                   children: [
    //                     Text(
    //                       "Income | Expense",
    //                       style: TextStyle(fontSize: 16),
    //                     ),
    //                     Spacer(),
    //                     DropdownButton(
    //                       value: incomeExpenseMonthFilter,
    //                       items: months
    //                           .map(
    //                             (month) => DropdownMenuItem(
    //                               value: month['value'],
    //                               child: Text(month['label']),
    //                             ),
    //                           )
    //                           .toList(),
    //                       onChanged: (value) {
    //                         setState(() {
    //                           incomeExpenseMonthFilter = value;
    //                           // TODO: Show loading screen on numbers
    //                           _statistics = _getStatistics();
    //                         });
    //                       },
    //                     ),
    //                     Spacer(),
    //                     DropdownButton(
    //                       value: incomeExpenseYearFilter,
    //                       items: years
    //                           .map(
    //                             (year) => DropdownMenuItem(
    //                               value: year['value'],
    //                               child: Text(year['label']),
    //                             ),
    //                           )
    //                           .toList(),
    //                       onChanged: (value) {
    //                         setState(() {
    //                           incomeExpenseYearFilter = value;
    //                           // TODO: Show loading screen on numbers
    //                           _statistics = _getStatistics();
    //                         });
    //                       },
    //                     ),
    //                   ],
    //                 ),
    //                 Row(
    //                   children: [
    //                     Column(
    //                       children: [
    //                         IncomeExpenseRatioPieChart(
    //                           [
    //                             new IncomeExpenseRatio(
    //                                 0,
    //                                 incomeStat['total'] is int
    //                                     ? (incomeStat['total'] as int)
    //                                         .toDouble()
    //                                     : incomeStat['total'],
    //                                 charts.MaterialPalette.green.shadeDefault),
    //                             new IncomeExpenseRatio(
    //                                 1,
    //                                 expenseStat['total'] is int
    //                                     ? (expenseStat['total'] as int)
    //                                         .toDouble()
    //                                     : expenseStat['total'],
    //                                 charts.MaterialPalette.red.shadeDefault),
    //                           ],
    //                           120,
    //                           120,
    //                           animate: true,
    //                         ),
    //                       ],
    //                     ),
    //                     Spacer(),
    //                     Column(
    //                       crossAxisAlignment: CrossAxisAlignment.end,
    //                       children: [
    //                         Text(
    //                           formatToCurrency(incomeStat['total']),
    //                           style: TextStyle(
    //                             fontSize: 24,
    //                             color: Colors.green,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                           textAlign: TextAlign.end,
    //                         ),
    //                         Text(
    //                           formatToCurrency(expenseStat['total']),
    //                           style: TextStyle(
    //                             fontSize: 24,
    //                             color: Colors.red,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                           textAlign: TextAlign.end,
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //           children: [
    //             ExpansionTile(
    //               tilePadding: EdgeInsets.symmetric(horizontal: 24.0),
    //               childrenPadding: EdgeInsets.symmetric(horizontal: 12.0),
    //               title: Text(
    //                 'Income',
    //                 style: TextStyle(color: Colors.green),
    //               ),
    //               children: sortedIncomeCategoryStat
    //                   .map<Widget>(
    //                     (categoryStat) => Padding(
    //                       padding: const EdgeInsets.symmetric(
    //                         horizontal: 24.0,
    //                         vertical: 16.0,
    //                       ),
    //                       child: SizedBox(
    //                         child: Row(
    //                           children: <Widget>[
    //                             Text(categoryStat.key),
    //                             Spacer(),
    //                             Text(
    //                               formatToCurrency(categoryStat.value),
    //                               style: TextStyle(
    //                                 color: Colors.green,
    //                                 fontSize: 16.0,
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   )
    //                   .toList(),
    //             ),
    //             ExpansionTile(
    //               tilePadding: EdgeInsets.symmetric(horizontal: 24.0),
    //               childrenPadding: EdgeInsets.symmetric(horizontal: 12.0),
    //               title: Text(
    //                 'Expense',
    //                 style: TextStyle(color: Colors.red),
    //               ),
    //               children: sortedExpenseCategoryStat
    //                   .map<Widget>(
    //                     (categoryStat) => Padding(
    //                       padding: const EdgeInsets.symmetric(
    //                         horizontal: 24.0,
    //                         vertical: 16.0,
    //                       ),
    //                       child: SizedBox(
    //                         child: Row(
    //                           children: <Widget>[
    //                             Text(categoryStat.key),
    //                             Spacer(),
    //                             Text(
    //                               formatToCurrency(categoryStat.value),
    //                               style: TextStyle(
    //                                 color: Colors.red,
    //                                 fontSize: 16.0,
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   )
    //                   .toList(),
    //             ),
    //           ],
    //         ),
    //       );

    //       return ListView(
    //         children: [totalBalanceStatCard, incomeExpenseStatCard],
    //       );
    //     }
    //   },
    // );
  }
}

class IncomeExpenseRatioPieChart extends StatelessWidget {
  final double width;
  final double height;
  final List<IncomeExpenseRatio> data;
  final bool animate;

  IncomeExpenseRatioPieChart(this.data, this.width, this.height,
      {this.animate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: charts.PieChart(
        [
          new charts.Series<IncomeExpenseRatio, int>(
            id: 'IncomeExpenseRatio',
            domainFn: (IncomeExpenseRatio incomeExpenseRatio, _) =>
                incomeExpenseRatio.type,
            measureFn: (IncomeExpenseRatio incomeExpenseRatio, _) =>
                incomeExpenseRatio.total != 0 ? incomeExpenseRatio.total : 1,
            colorFn: (IncomeExpenseRatio incomeExpenseRatio, _) =>
                incomeExpenseRatio.color,
            data: data,
          )
        ],
        animate: animate,
      ),
    );
  }
}

class IncomeExpenseRatio {
  static final List<String> labels = ['I', 'E'];
  final int type;
  final double total;
  final charts.Color color;

  IncomeExpenseRatio(this.type, this.total, this.color);
}
