import 'package:cjdc_money_manager/utils.dart';

abstract class FieldValidation {
  factory FieldValidation._() => null;

  String validate(String value, FieldValidationOptions options) {
    if (!options.isNullable && (value == null || value.isEmpty)) {
      return 'Value must not be empty';
    }

    if (options.isNumber) {
      double parsedValue = double.tryParse(value);

      if (parsedValue == null) {
        return 'Value must be numbers only';
      }

      if (options.hasMax && parsedValue > options.max) {
        return 'Value must not be more than (${formatToCurrency(options.max)})';
      }

      if (options.hasMin && parsedValue < options.min) {
        return 'Value must not be less than (${formatToCurrency(options.min)})';
      }
    }

    return null;
  }
}

class FieldValidationOptions {
  final bool isNullable;
  final bool isNumber;
  final bool hasMax;
  final bool hasMin;
  final double max;
  final double min;

  FieldValidationOptions({
    this.isNullable = false,
    this.isNumber = false,
    this.hasMax = false,
    this.hasMin = false,
    this.max = 0,
    this.min = 0,
  });
}
