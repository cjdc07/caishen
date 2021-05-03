import 'package:flutter/material.dart';

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

class FullScreenSelect extends StatelessWidget {
  final bool enabled;
  final Widget fieldTitle;
  final String title;
  final Function onTap;
  final List<FullScreenSelectItem> items;

  FullScreenSelect({
    Key key,
    @required this.enabled,
    @required this.fieldTitle,
    @required this.title,
    @required this.onTap,
    this.items,
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(title),
                  ),
                  body: ListView.builder(
                    padding: EdgeInsets.only(bottom: 24.0),
                    shrinkWrap: true,
                    itemCount: items != null ? items.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      FullScreenSelectItem item = items[index];

                      return ListTile(
                        onTap: () => onTap(item),
                        title: Text(
                          item.label,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
