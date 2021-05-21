import 'package:cjdc_money_manager/common/full_screen_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenSelectContent extends StatefulWidget {
  final String title;
  final List<Widget> actions;
  final bool hasSearch;
  final List<FullScreenSelectItem> items;
  final Function onTap;
  final dynamic selectedItemValue;

  FullScreenSelectContent({
    Key key,
    this.title,
    this.actions,
    this.hasSearch,
    this.items,
    this.onTap,
    this.selectedItemValue,
  }) : super(key: key);

  @override
  _FullScreenSelectContentState createState() =>
      _FullScreenSelectContentState();
}

class _FullScreenSelectContentState extends State<FullScreenSelectContent> {
  List<FullScreenSelectItem> filteredItems;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void setFilteredItems(String value) {
    setState(() {
      filteredItems = widget.items
          .where((e) => e.label.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.actions,
      ),
      body: Column(
        children: [
          widget.hasSearch
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: CupertinoSearchTextField(
                    placeholder: 'Search',
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => setFilteredItems(value),
                  ),
                )
              : Container(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24.0),
              shrinkWrap: true,
              itemCount: filteredItems != null ? filteredItems.length : 0,
              itemBuilder: (BuildContext context, int index) {
                FullScreenSelectItem item = filteredItems[index];

                return ListTile(
                  onTap: () => widget.onTap(item),
                  title: Text(
                    item.label,
                  ),
                  trailing: widget.selectedItemValue == item.value
                      ? Icon(Icons.check_rounded)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
