import 'package:cjdc_money_manager/account/account.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:flutter/material.dart';

class AccountModelNotifier extends ChangeNotifier {
  List<Account> _accounts;
  Account _selectedAccount;
  String _selectedAppTransactionType = AppTransactionType.Income;

  List<Account> getAccounts() => _accounts;

  Account getSelectedAccount() => _selectedAccount;

  String getSelectedAppTransactionType() => _selectedAppTransactionType;

  void setAccounts(List<Account> accounts, {bool notify = false}) {
    _accounts = accounts;
    if (notify) {
      notifyListeners();
    }
  }

  void setSelectedAccount(Account account, {bool notify = false}) {
    _selectedAccount = account;
    if (notify) {
      notifyListeners();
    }
  }

  void setSelectedAppTransactionType(String appTransactionType) {
    _selectedAppTransactionType = appTransactionType;
  }
}
