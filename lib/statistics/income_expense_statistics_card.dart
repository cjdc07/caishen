import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class IncomeExpenseStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> incomeStatistics;
  final Map<String, dynamic> expenseStatistics;
  final int month;
  final int year;
  final Function onMonthChange;
  final Function onYearChange;

  IncomeExpenseStatisticsCard({
    Key key,
    this.incomeStatistics,
    this.expenseStatistics,
    this.month,
    this.year,
    this.onMonthChange,
    this.onYearChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List sortedIncomeCategoryStat =
        List.from(incomeStatistics['categoryStats'].entries.toList());

    List sortedExpenseCategoryStat =
        List.from(expenseStatistics['categoryStats'].entries.toList());

    sortedIncomeCategoryStat.sort((a, b) => b.value.compareTo(a.value));
    sortedExpenseCategoryStat.sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: ExpansionTile(
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Income | Expense",
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  DropdownButton(
                    value: month,
                    items: months
                        .map(
                          (month) => DropdownMenuItem(
                            value: month['value'],
                            child: Text(month['label']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => onMonthChange(value),
                  ),
                  Spacer(),
                  DropdownButton(
                    value: year,
                    items: years
                        .map(
                          (year) => DropdownMenuItem(
                            value: year['value'],
                            child: Text(year['label']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => onYearChange(value),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      IncomeExpenseRatioPieChart(
                        [
                          new IncomeExpenseRatio(
                              0,
                              incomeStatistics['total'] is int
                                  ? (incomeStatistics['total'] as int)
                                      .toDouble()
                                  : incomeStatistics['total'],
                              charts.MaterialPalette.green.shadeDefault),
                          new IncomeExpenseRatio(
                              1,
                              expenseStatistics['total'] is int
                                  ? (expenseStatistics['total'] as int)
                                      .toDouble()
                                  : expenseStatistics['total'],
                              charts.MaterialPalette.red.shadeDefault),
                        ],
                        120,
                        120,
                        animate: true,
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatToCurrency(incomeStatistics['total']),
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        formatToCurrency(expenseStatistics['total']),
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 24.0),
            childrenPadding: EdgeInsets.symmetric(horizontal: 12.0),
            title: Text(
              'Income',
              style: TextStyle(color: Colors.green),
            ),
            children: sortedIncomeCategoryStat
                .map<Widget>(
                  (categoryStat) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: SizedBox(
                      child: Row(
                        children: <Widget>[
                          Text(categoryStat.key),
                          Spacer(),
                          Text(
                            formatToCurrency(categoryStat.value),
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 24.0),
            childrenPadding: EdgeInsets.symmetric(horizontal: 12.0),
            title: Text(
              'Expense',
              style: TextStyle(color: Colors.red),
            ),
            children: sortedExpenseCategoryStat
                .map<Widget>(
                  (categoryStat) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: SizedBox(
                      child: Row(
                        children: <Widget>[
                          Text(categoryStat.key),
                          Spacer(),
                          Text(
                            formatToCurrency(categoryStat.value),
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
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
