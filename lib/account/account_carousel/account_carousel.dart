import 'package:carousel_slider/carousel_slider.dart';
import 'package:cjdc_money_manager/account/account_carousel/account_carousel_navigator.dart';
import 'package:cjdc_money_manager/account/account_carousel/account_carousel_page.dart';
import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountCarousel extends StatefulWidget {
  final List<Account> accounts;

  AccountCarousel({Key key, @required this.accounts}) : super(key: key);

  @override
  _AccountCarouselState createState() => _AccountCarouselState();
}

class _AccountCarouselState extends State<AccountCarousel> {
  final CarouselController _controller = CarouselController();
  int selectedAccountIndex = 0;

  void setSelectedAccountIndex(int index) {
    setState(() {
      selectedAccountIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CashFlowData>(
      builder: (context, cashFlowData, child) {
        final Account account = cashFlowData.getSelectedAccount();

        if (account == null) {
          // TODO: Show no data screen
          return Center(
            child: Text('No existing account'),
          );
        }

        _controller.onReady.then((_) {
          if (selectedAccountIndex != cashFlowData.getSelectedAccountIndex()) {
            _controller.animateToPage(cashFlowData.getSelectedAccountIndex());
            setSelectedAccountIndex(cashFlowData.getSelectedAccountIndex());
          }
        });

        return Column(
          children: <Widget>[
            CarouselSlider.builder(
              key: widget.key,
              carouselController: _controller,
              options: CarouselOptions(
                height: 72.0,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  if (reason == CarouselPageChangedReason.manual) {
                    Provider.of<CashFlowData>(context, listen: false)
                        .setSelectedAccountIndex(index);
                  }
                },
              ),
              itemCount: widget.accounts.length,
              itemBuilder: (BuildContext context, int index) {
                return AccountCarouselPage(account: widget.accounts[index]);
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
              child: AccountCarouselNavigator(
                accounts: widget.accounts,
                selectedAccountId: account.id,
              ),
            ),
          ],
        );
      },
    );
  }
}
