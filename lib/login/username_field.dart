import 'package:cjdc_money_manager/common/field_validation.dart';
import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget with FieldValidation {
  final TextEditingController controller;

  const UsernameField({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Username',
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
    );
  }
}
