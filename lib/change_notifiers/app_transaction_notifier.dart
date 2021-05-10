import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:flutter/material.dart';

class AppTransactionNotifier extends ChangeNotifier {
  Map<String, List<AppTransaction>> _appTransactions =
      new Map<String, List<AppTransaction>>();

  List<AppTransactionCategory> _appTransactionCategories;

  List<AppTransactionCategory> getAppTransactionCategories() =>
      _appTransactionCategories;

  Map<String, List<AppTransaction>> getAppTransactions() => _appTransactions;

  void setAppTransactionCategories(
    List<AppTransactionCategory> appTransactionCategories, {
    bool notify = false,
  }) {
    _appTransactionCategories = appTransactionCategories;
    if (notify) {
      notifyListeners();
    }
  }

  void setAppTransactions(
    Map<String, List<AppTransaction>> appTransactions, {
    bool notify = false,
  }) {
    _appTransactions = appTransactions;
    if (notify) {
      notifyListeners();
    }
  }
}
