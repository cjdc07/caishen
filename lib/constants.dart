import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/common/full_screen_select/full_screen_select.dart';

const String INCOME = 'INCOME';
const String EXPENSE = 'EXPENSE';
const String TRANSFER = 'TRANSFER';

List<AccountColor> colors = [
  new AccountColor(name: 'blue', alpha: 255, red: 20, green: 130, blue: 184),
  new AccountColor(
      name: 'lightBlue', alpha: 255, red: 30, green: 144, blue: 255),
  new AccountColor(name: 'green', alpha: 255, red: 41, green: 199, blue: 173),
  new AccountColor(
      name: 'darkGreen', alpha: 255, red: 0, green: 129, blue: 138),
  new AccountColor(name: 'red', alpha: 255, red: 207, green: 102, blue: 121),
  new AccountColor(name: 'grey', alpha: 255, red: 128, green: 128, blue: 128),
  new AccountColor(name: 'orange', alpha: 255, red: 255, green: 140, blue: 0),
];

List<FullScreenSelectItem> accountTypeItems = [
  new FullScreenSelectItem(value: 'savings', label: 'Savings'),
  new FullScreenSelectItem(value: 'credit', label: 'Credit'),
  new FullScreenSelectItem(value: 'timeDeposit', label: 'Time Deposit'),
  new FullScreenSelectItem(value: 'digitalWallet', label: 'Digital Wallet'),
  new FullScreenSelectItem(value: 'cash', label: 'Cash'),
  new FullScreenSelectItem(value: 'payroll', label: 'Payroll'),
  new FullScreenSelectItem(value: 'bonds', label: 'Bonds'),
  new FullScreenSelectItem(value: 'stockBroker', label: 'Stock Broker'),
  new FullScreenSelectItem(value: 'mutualFund', label: 'Mutual Fund'),
];

final List<Map<String, dynamic>> months = [
  // {'label': 'All', 'value': 0},
  {'label': 'Jan', 'value': DateTime.january},
  {'label': 'Feb', 'value': DateTime.february},
  {'label': 'Mar', 'value': DateTime.march},
  {'label': 'Apr', 'value': DateTime.april},
  {'label': 'May', 'value': DateTime.may},
  {'label': 'Jun', 'value': DateTime.june},
  {'label': 'Jul', 'value': DateTime.july},
  {'label': 'Aug', 'value': DateTime.august},
  {'label': 'Sep', 'value': DateTime.september},
  {'label': 'Oct', 'value': DateTime.october},
  {'label': 'Nov', 'value': DateTime.november},
  {'label': 'Dec', 'value': DateTime.december},
];

final List<Map<String, dynamic>> years = [
  // {'label': 'All', 'value': 0},
  {'label': '2020', 'value': 2020},
  {'label': '2021', 'value': 2021},
  {'label': '2022', 'value': 2022},
  {'label': '2023', 'value': 2023},
  {'label': '2024', 'value': 2024},
  {'label': '2025', 'value': 2025},
];
