import 'package:cjdc_money_manager/common/field_validation.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget with FieldValidation {
  final TextEditingController controller;

  const PasswordField({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Password',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
      controller: this.controller,
      validator: (value) => validate(
        value,
        FieldValidationOptions(),
      ),
      cursorColor: Colors.cyan,
      obscureText: true,
    );
  }
}
