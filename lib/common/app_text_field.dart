import 'package:cjdc_money_manager/common/field_validation.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget with FieldValidation {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final int minLines;
  final int maxLines;
  final bool isPassword;
  final FocusNode focusNode;

  const AppTextField({
    Key key,
    @required this.controller,
    @required this.enabled,
    @required this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.isPassword = false,
    this.focusNode,
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
          FieldValidationOptions(),
        ),
        cursorColor: Colors.cyan,
        minLines: minLines,
        maxLines: maxLines,
        obscureText: isPassword,
        focusNode: focusNode,
      ),
    );
  }
}
