import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  final Function onPress;
  final bool isActive;
  final Widget label;

  PillButton({Key key, this.onPress, this.isActive, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(12.0),
      onPressed: onPress,
      child: label,
      color: isActive ? Colors.cyan : Colors.grey[900],
      textColor: isActive ? Colors.grey[200] : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
    );
  }
}
