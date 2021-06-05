import 'dart:convert';

import 'package:intl/intl.dart';

String getPrettyJSONString(Object jsonObject) {
  return const JsonEncoder.withIndent('  ').convert(jsonObject);
}

String formatToCurrency(dynamic value) {
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: '₱',
  ).format(value);
}

String formatDateString(String date) {
  return DateFormat('MMMM d, yyyy').format(DateTime.parse(date));
}

String formatTimeString(String date) {
  return DateFormat('HH:mm').format(DateTime.parse(date));
}
