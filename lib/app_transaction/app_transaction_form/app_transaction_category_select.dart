import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:cjdc_money_manager/firebase_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppTransactionCategorySelect extends StatefulWidget {
  final Function onTap;

  AppTransactionCategorySelect({
    Key key,
    @required this.onTap,
  }) : super(key: key);

  @override
  _AppTransactionCategorySelectState createState() =>
      _AppTransactionCategorySelectState();
}

class _AppTransactionCategorySelectState
    extends State<AppTransactionCategorySelect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.cyan),
            onPressed: () {
              return showDialog<void>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  final TextEditingController nameFieldController =
                      TextEditingController();

                  return AlertDialog(
                    title: Text('New Category'),
                    content: AppTextField(
                      controller: nameFieldController,
                      enabled: true,
                      label: 'Name',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.cyan,
                          ),
                        ),
                        onPressed: () async {
                          final CollectionReference
                              appTransactionCategoryCollectionReference =
                              FirebaseFirestore.instance
                                  .collection('appTransactionCategories');

                          final appTransactionCategory = AppTransactionCategory(
                              name: nameFieldController.text.trim());
                          // TODO: check for duplicates before adding
                          await appTransactionCategoryCollectionReference
                              .add(appTransactionCategory.toMap());

                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appTransactionCategories')
            .snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return SafeArea(child: Text(snapshot.error));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // TODO: show proper loading screen
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<dynamic> payload = snapshot.data.docs.map((transaction) {
            Map<String, dynamic> data = transaction.data();
            data['id'] = transaction.id;
            return data;
          }).toList();

          final List<AppTransactionCategory> appTransactionCategories =
              AppTransactionCategory.parseList(payload);

          return ListView.builder(
            padding: EdgeInsets.only(bottom: 24.0),
            shrinkWrap: true,
            itemCount: appTransactionCategories.length,
            itemBuilder: (BuildContext context, int index) {
              AppTransactionCategory appTransactionCategory =
                  appTransactionCategories[index];

              return ListTile(
                onTap: () => widget.onTap(appTransactionCategory),
                title: Text(
                  appTransactionCategory.name,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
