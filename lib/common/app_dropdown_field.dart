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
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: widget.label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800], width: 0.5),
            borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
