import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/account/account_mutation.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/common/app_number_field.dart';
import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:cjdc_money_manager/common/full_screen_select/full_screen_select.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountForm extends StatefulWidget {
  final Account account;

  AccountForm({Key key, this.account}) : super(key: key);

  @override
  _AccountFormState createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController balanceFieldController = TextEditingController();

  AccountColor selectedColor = colors[0];
  FullScreenSelectItem type;
  bool isLoading = false;
  bool isUpdate = false;
  List<String> errors = [];

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      isUpdate = true;
      nameFieldController.value = TextEditingValue(text: widget.account.name);
      balanceFieldController.value = TextEditingValue(
        text: formatToCurrency(widget.account.balance),
      );
      type = FullScreenSelectItem(
        label: widget.account.type.value,
        value: widget.account.type.key,
      );
      selectedColor = widget.account.color;
    }
  }

  void setIsLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }

  void setColor(AccountColor color) {
    setState(() {
      this.selectedColor = color;
    });
  }

  void setTypeField(FullScreenSelectItem type) {
    setState(() {
      this.type = type;
      this.errors = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUpdate ? 'Update ${widget.account.name}' : 'Add New Account',
        ),
        actions: [
          AccountMutation(
            formKey: _formKey,
            nameFieldController: nameFieldController,
            balanceFieldController: balanceFieldController,
            color: selectedColor,
            type: new AccountType(key: type?.value, value: type?.label),
            setIsLoading: setIsLoading,
            isLoading: isLoading,
            oldAccount: widget.account,
            validate: () {
              if (type == null) {
                setState(() {
                  this.errors = ['Please select account type'];
                });

                return false;
              }

              return true;
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /* Account name field */
                AppTextField(
                  enabled: !isLoading,
                  controller: nameFieldController,
                  label: 'Account Name',
                ),

                /* Account balance field */
                AppNumberField(
                  enabled: !isLoading,
                  controller: balanceFieldController,
                  min: 0,
                  hasMin: true,
                  label: 'Balance',
                ),

                /* Account type field */
                FullScreenSelect(
                  enabled: !isLoading,
                  title: 'Account Type',
                  items: accountTypeItems,
                  fieldTitle: Text(
                    type != null ? type.label : 'Type',
                    style: type != null
                        ? TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.white60),
                  ),
                  onTap: (type) {
                    setTypeField(type);
                    Navigator.pop(context);
                  },
                  errors: errors,
                ),

                /* Account color picker */
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Color',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Wrap(
                        runSpacing: 10.0,
                        spacing: 18.0,
                        children: colors
                            .map(
                              (color) => Container(
                                child: GestureDetector(
                                  onTap: () =>
                                      isLoading ? null : setColor(color),
                                  child: Container(
                                    child: selectedColor.name == color.name
                                        ? Icon(
                                            Icons.check,
                                            color: color.name == 'white'
                                                ? Colors.black
                                                : Colors.white,
                                          )
                                        : null,
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(
                                        color.alpha,
                                        color.red,
                                        color.green,
                                        color.blue,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

                /* Delete button if update */
                isUpdate
                    ? Padding(
                        padding: EdgeInsets.only(top: 32.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextButton(
                            child: Text(
                              'Delete ${widget.account.name}',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            onPressed: () {
                              return showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:
                                        Text('Delete ${widget.account.name}'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              'This will also delete all associated transactions.\n\nAre you sure?'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'Cancel',
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          final CollectionReference
                                              accountsRef = FirebaseFirestore
                                                  .instance
                                                  .collection('accounts');

                                          // Delete all associated transactions
                                          final CollectionReference
                                              appTransactionsRef =
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      'appTransactions');

                                          QuerySnapshot appTransactionSnapshot =
                                              await appTransactionsRef
                                                  .where(
                                                    'account',
                                                    isEqualTo: accountsRef
                                                        .doc(widget.account.id),
                                                  )
                                                  .get();

                                          await Future.forEach(
                                            appTransactionSnapshot.docs,
                                            (QueryDocumentSnapshot doc) async {
                                              await doc.reference.delete();
                                            },
                                          );

                                          // Delete Account
                                          await accountsRef
                                              .doc(widget.account.id)
                                              .delete();

                                          List<Account> accounts =
                                              Provider.of<AccountNotifier>(
                                                      context,
                                                      listen: false)
                                                  .getAccounts();

                                          List<Account> updatedAccounts =
                                              new List.from(accounts);

                                          updatedAccounts.removeWhere(
                                            (account) =>
                                                account.id == widget.account.id,
                                          );

                                          context
                                              .read<AccountNotifier>()
                                              .setSelectedAccount(
                                                updatedAccounts.length > 0
                                                    ? updatedAccounts[0]
                                                    : null,
                                              );

                                          context
                                              .read<AccountNotifier>()
                                              .setAccounts(
                                                updatedAccounts,
                                                notify: true,
                                              );

                                          // Should return to cash flow page
                                          Navigator.of(context).popUntil(
                                            (route) => route.isFirst,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
