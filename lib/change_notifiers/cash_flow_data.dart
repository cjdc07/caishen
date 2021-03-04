import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:flutter/material.dart';

class CashFlowData extends ChangeNotifier {
  static CashFlowData cashFlowData;
  List<Account> _accounts;
  int _selectedAccountIndex = 0;
  String _selectedAppTransactionType = AppTransactionType.Income;

  static CashFlowData getInstance() {
    if (cashFlowData == null) {
      cashFlowData = CashFlowData();
    }

    return cashFlowData;
  }

  List<Account> getAccounts() => _accounts;

  void setAccounts(List<Account> accounts) {
    _accounts = accounts;
    notifyListeners();
  }

  int getSelectedAccountIndex() => _selectedAccountIndex;

  void setSelectedAccountIndex(int index) {
    _selectedAccountIndex = index;
    notifyListeners();
  }

  String getSelectedAppTransactionType() => _selectedAppTransactionType;

  void setSelectedAppTransactionType(String appTransactionType) {
    _selectedAppTransactionType = appTransactionType;
    notifyListeners();
  }

  Account getSelectedAccount() {
    if (_accounts == null || _accounts.length < 1) {
      return null;
    }

    int index = _selectedAccountIndex >= _accounts.length
        ? _accounts.length - 1
        : _selectedAccountIndex;

    return _accounts[index];
  }
}
