import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountCarouselNavigator extends StatelessWidget {
  final List<Account> accounts;
  final String selectedAccountId;

  AccountCarouselNavigator({
    Key key,
    @required this.accounts,
    @required this.selectedAccountId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: accounts
          .map(
            (account) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: 2.0,
                  right: 2.0,
                  top: 4.0,
                  bottom: 2.0,
                ),
                child: FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
                  height: 20.0,
                  onPressed: () {
                    Provider.of<CashFlowData>(context, listen: false)
                        .setSelectedAccountIndex(accounts.indexOf(account));
                  },
                  child: selectedAccountId == account.id
                      ? Icon(
                          Icons.circle,
                          size: 14.0,
                        )
                      : null,
                  color: Color.fromARGB(
                    account.color.alpha,
                    account.color.red,
                    account.color.green,
                    account.color.blue,
                  ),
                  textColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
