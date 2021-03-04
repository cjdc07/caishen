import 'package:cjdc_money_manager/common/field_validation.dart';
import 'package:flutter/material.dart';

class AppDropDownField extends StatefulWidget {
  final Function controller;
  final bool enabled;
  final List<dynamic> items;
  final String label;
  final String defaultValue;

  const AppDropDownField({
    Key key,
    @required this.controller,
    @required this.enabled,
    @required this.items,
    @required this.label,
    this.defaultValue,
  }) : super(key: key);

  @override
  _AppDropDownFieldState createState() => _AppDropDownFieldState();
}

class _AppDropDownFieldState extends State<AppDropDownField>
    with FieldValidation {
  String selectedValue;

  void setSelectedValue(String value) {
    setState(() {
      selectedValue = value;
    });
  }

  List<DropdownMenuItem> createDropDownMenuItems() {
    return widget.items
        .map((item) => DropdownMenuItem(
              child: Text(item['label']),
              value: item['value'],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
      items: createDropDownMenuItems(),
      hint: selectedValue != null ? Text(selectedValue) : null,
      onChanged: widget.enabled ? (value) => widget.controller(value) : null,
      value: widget.defaultValue,
      validator: (value) {
        setSelectedValue(value);
        return validate(
          value,
          FieldValidationOptions(),
        );
      },
    );
  }
}
