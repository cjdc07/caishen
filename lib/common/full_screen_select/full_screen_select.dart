import 'package:cjdc_money_manager/common/full_screen_select/full_screen_select_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenSelect extends StatelessWidget {
  final bool enabled;
  final Widget fieldTitle;
  final String title;
  final Function onTap;
  final List<FullScreenSelectItem> items;
  final dynamic selectedItemValue;
  final List<Widget> actions;
  final bool hasSearch;

  FullScreenSelect({
    Key key,
    @required this.enabled,
    @required this.fieldTitle,
    @required this.title,
    @required this.onTap,
    this.items,
    this.actions,
    this.hasSearch = false,
    this.selectedItemValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(color: Colors.grey[900]),
          top: BorderSide(color: Colors.grey[900]),
          left: BorderSide(color: Colors.grey[900]),
          right: BorderSide(color: Colors.grey[900]),
        ),
      ),
      child: ListTile(
        enabled: enabled,
        isThreeLine: false,
        contentPadding: EdgeInsets.zero,
        title: fieldTitle,
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return FullScreenSelectContent(
                  actions: actions,
                  hasSearch: hasSearch,
                  items: items,
                  onTap: onTap,
                  title: title,
                  selectedItemValue: selectedItemValue,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FullScreenSelectItem {
  final String label;
  final String value;

  FullScreenSelectItem({
    this.label,
    this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}
