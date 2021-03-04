import 'package:flutter/material.dart';

class FullScreenSelect extends StatelessWidget {
  final bool enabled;
  final Widget fieldTitle;
  final Function onTap;

  FullScreenSelect({
    Key key,
    @required this.enabled,
    @required this.fieldTitle,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white38)),
      ),
      child: ListTile(
        enabled: enabled,
        isThreeLine: false,
        contentPadding: EdgeInsets.zero,
        title: fieldTitle,
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}
