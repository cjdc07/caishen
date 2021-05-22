import 'package:cjdc_money_manager/common/field_validation.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget with FieldValidation {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final int minLines;
  final int maxLines;
  final bool isPassword;

  const AppTextField({
    Key key,
    @required this.controller,
    @required this.enabled,
    @required this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
      controller: controller,
      validator: (value) => validate(
        value,
        FieldValidationOptions(),
      ),
      cursorColor: Colors.cyan,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: isPassword,
    );
  }
}
