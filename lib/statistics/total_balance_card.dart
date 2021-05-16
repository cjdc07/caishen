import 'package:cjdc_money_manager/utils.dart';
import 'package:flutter/material.dart';

class TotalBalanceCard extends StatelessWidget {
  final double total;

  TotalBalanceCard({
    Key key,
    this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatToCurrency(total),
                  style: TextStyle(
                    fontSize: 24,
                    color: total < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
