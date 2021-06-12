import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:flutter/material.dart';

class AccountNotifier extends ChangeNotifier {
  List<Account> _accounts;
  Account _selectedAccount;
  String _selectedAppTransactionType = INCOME;

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

  void setAppTransactionType(String appTransactionType, {bool notify = false}) {
    _selectedAppTransactionType = appTransactionType;
    if (notify) {
      notifyListeners();
    }
  }

  void reset() {
    _accounts = null;
    _selectedAccount = null;
    _selectedAppTransactionType = null;
  }
}
