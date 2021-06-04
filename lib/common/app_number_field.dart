import 'package:cjdc_money_manager/common/field_validation.dart';
import 'package:flutter/material.dart';

class AppNumberField extends StatelessWidget with FieldValidation {
  final TextEditingController controller;
  final double max;
  final double min;
  final bool hasMax;
  final bool hasMin;
  final String label;
  final bool enabled;

  const AppNumberField({
    Key key,
    @required this.controller,
    this.max,
    this.min,
    this.hasMax,
    this.hasMin,
    @required this.enabled,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800], width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800], width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: controller,
        validator: (value) => validate(
          value,
          FieldValidationOptions(
            isNumber: true,
            max: max != null ? max : 0,
            min: min != null ? min : 0,
            hasMax: hasMax != null ? hasMax : false,
            hasMin: hasMin != null ? hasMin : false,
          ),
        ),
        cursorColor: Colors.cyan,
      ),
    );
  }
}
