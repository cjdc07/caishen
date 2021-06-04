import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_mutation.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/account_notifier.dart';
import 'package:cjdc_money_manager/change_notifiers/app_transaction_notifier.dart';
import 'package:cjdc_money_manager/common/app_dropdown_field.dart';
import 'package:cjdc_money_manager/common/app_number_field.dart';
import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:cjdc_money_manager/common/full_screen_select/full_screen_select.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cjdc_money_manager/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import '../extensions.dart';

class TransactionForm extends StatefulWidget {
  final AppTransaction appTransaction;
  final Account account;
  final String appTransactiontype;

  TransactionForm({
    Key key,
    this.appTransaction,
    this.account,
    this.appTransactiontype,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionFieldController =
      TextEditingController();
  final TextEditingController amountFieldController = TextEditingController();
  final TextEditingController toFieldController = TextEditingController();
  final TextEditingController fromFieldController = TextEditingController();
  final TextEditingController notesFieldController = TextEditingController();
  DateTime dateTimeValue = DateTime.now();
  AppTransactionCategory selectedAppTransactionCategory;
  String selectedTransferAccount;
  bool isSaving = false;
  String appTransactionTypeValue;
  Account currentAccount;

  @override
  void initState() {
    super.initState();

    currentAccount = widget.account;

    appTransactionTypeValue = widget.appTransaction == null
        ? widget.appTransactiontype
        : widget.appTransaction.type;

    notesFieldController.addListener(() {
      setState(() {});
    });

    if (widget.appTransaction != null) {
      if (appTransactionTypeValue == TRANSFER &&
          widget.appTransaction.account.id != currentAccount.id) {
        currentAccount = Provider.of<AccountNotifier>(context, listen: false)
            .getAccounts()
            .singleWhere((e) => e.id == widget.appTransaction.account.id);
      }

      descriptionFieldController.value =
          TextEditingValue(text: widget.appTransaction.description);

      amountFieldController.value =
          TextEditingValue(text: widget.appTransaction.amount.toString());

      dateTimeValue = widget.appTransaction.createdAt;

      toFieldController.value =
          TextEditingValue(text: widget.appTransaction.to);

      fromFieldController.value =
          TextEditingValue(text: widget.appTransaction.from);

      selectedAppTransactionCategory = context
          .read<AppTransactionNotifier>()
          .getAppTransactionCategories()
          .singleWhere(
              (category) => widget.appTransaction.category.id == category.id);

      notesFieldController.value = TextEditingValue(
          text: widget.appTransaction.notes != null
              ? widget.appTransaction.notes
              : "");

      if (widget.appTransaction.type == TRANSFER) {
        selectedTransferAccount = widget.appTransaction.to;
      }
    }
  }

  @override
  void dispose() {
    descriptionFieldController.dispose();
    amountFieldController.dispose();
    toFieldController.dispose();
    fromFieldController.dispose();
    notesFieldController.dispose();
    super.dispose();
  }

  void setDateTimeValue(DateTime dateTime) {
    setState(() {
      dateTimeValue = dateTime;
    });
  }

  void setTransferAccountField(String accountId) {
    setState(() {
      selectedTransferAccount = accountId;
    });
  }

  void setCategoryField(AppTransactionCategory appTransactionCategory) {
    setState(() {
      selectedAppTransactionCategory = appTransactionCategory;
    });
  }

  void setAppTransactionTypeField(String appTransactionType) {
    setState(() {
      appTransactionTypeValue = appTransactionType;
    });
  }

  void setIsSaving(bool isSaving) {
    setState(() {
      this.isSaving = isSaving;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appTransaction != null
              ? 'Update ${appTransactionTypeValue.capitalize()}'
              : 'Create Transaction',
        ),
        actions: [
          AppTransactionMutation(
            oldAppTransaction: widget.appTransaction,
            formKey: _formKey,
            accountId: currentAccount.id,
            appTransactionTypeValue: appTransactionTypeValue,
            descriptionFieldController: descriptionFieldController,
            amountFieldController: amountFieldController,
            fromFieldController: fromFieldController,
            toFieldController: toFieldController,
            appTransactionCategoryFieldValue: selectedAppTransactionCategory,
            notesFieldController: notesFieldController,
            transferAccountFieldValue: selectedTransferAccount,
            setIsSaving: setIsSaving,
            isSaving: isSaving,
            dateTimeValue: dateTimeValue,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                // Transaction Type Field
                widget.appTransaction == null
                    ? AppDropDownField(
                        controller: setAppTransactionTypeField,
                        defaultValue: appTransactionTypeValue,
                        enabled: !isSaving,
                        label: 'Transaction Type',
                        items: [
                            {
                              'label': 'Income',
                              'value': INCOME,
                            },
                            {
                              'label': 'Expense',
                              'value': EXPENSE,
                            },
                            {
                              'label': 'Transfer',
                              'value': TRANSFER,
                            },
                          ])
                    : Container(),

                // Amount Field
                AppNumberField(
                  controller: amountFieldController,
                  max: widget.appTransaction != null
                      ? currentAccount.balance + widget.appTransaction.amount
                      : currentAccount.balance,
                  hasMax: appTransactionTypeValue == EXPENSE ||
                      appTransactionTypeValue == TRANSFER,
                  hasMin: true,
                  min: 0,
                  enabled: !isSaving,
                  label: 'Amount',
                ),

                // Description Field
                appTransactionTypeValue != TRANSFER
                    ? AppTextField(
                        controller: descriptionFieldController,
                        enabled: !isSaving,
                        label: 'Description',
                      )
                    : Container(),

                // Created date Field
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.only(bottom: 10),
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
                    enabled: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${formatDateString(dateTimeValue.toString())} ${formatTimeString(dateTimeValue.toString())}',
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded,
                        color: Colors.white70),
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        maxTime: DateTime.now(),
                        theme: DatePickerTheme(
                          backgroundColor: Colors.black,
                          cancelStyle: TextStyle(
                            color: Colors.red,
                          ),
                          itemStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        showTitleActions: true,
                        currentTime: dateTimeValue,
                        onChanged: (date) {
                          setDateTimeValue(date);
                        },
                      );
                    },
                  ),
                ),

                // To Field for Transfer
                appTransactionTypeValue == TRANSFER
                    ? FullScreenSelect(
                        title: 'Select Transfer Account',
                        enabled:
                            widget.appTransaction != null ? false : !isSaving,
                        items: Provider.of<AccountNotifier>(context,
                                listen: false)
                            .getAccounts()
                            .where((account) => account.id != currentAccount.id)
                            .map(
                              (account) => (new FullScreenSelectItem(
                                label: account.name,
                                value: account.id,
                              )),
                            )
                            .toList(),
                        fieldTitle: Text(
                          selectedTransferAccount != null
                              ? Provider.of<AccountNotifier>(
                                  context,
                                  listen: false,
                                )
                                  .getAccounts()
                                  .singleWhere(
                                    (account) =>
                                        account.id == selectedTransferAccount,
                                  )
                                  .name
                              : 'To',
                          style: selectedTransferAccount != null &&
                                  widget.appTransaction == null
                              ? TextStyle(color: Colors.white)
                              : TextStyle(color: Colors.white60),
                        ),
                        onTap: (FullScreenSelectItem accountItem) {
                          setTransferAccountField(
                            context
                                .read<AccountNotifier>()
                                .getAccounts()
                                .singleWhere(
                                  (account) => accountItem.value == account.id,
                                )
                                .id,
                          );
                          Navigator.pop(context);
                        },
                      )
                    : Container(),

                // From field for income
                appTransactionTypeValue == INCOME
                    ? AppTextField(
                        controller: fromFieldController,
                        enabled: !isSaving,
                        label: 'From',
                      )
                    : Container(),

                // To Field for expense
                appTransactionTypeValue == EXPENSE
                    ? AppTextField(
                        controller: toFieldController,
                        enabled: !isSaving,
                        label: 'To',
                      )
                    : Container(),

                // Category Field
                // TODO: Add validation here!
                appTransactionTypeValue != TRANSFER
                    ? Consumer<AppTransactionNotifier>(
                        builder: (context, appTransactionNotifier, child) {
                        List<FullScreenSelectItem> appTransactionCategoryItems =
                            appTransactionNotifier
                                .getAppTransactionCategories()
                                .map((e) => new FullScreenSelectItem(
                                    label: e.value, value: e.key))
                                .toList();

                        appTransactionCategoryItems
                            .sort((a, b) => a.label.compareTo(b.label));

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: FullScreenSelect(
                            title: 'Select Category',
                            hasSearch: true,
                            enabled: !isSaving,
                            selectedItemValue:
                                selectedAppTransactionCategory?.key,
                            items: appTransactionCategoryItems,
                            fieldTitle: Text(
                              selectedAppTransactionCategory != null
                                  ? selectedAppTransactionCategory.value
                                  : 'Category',
                              style: selectedAppTransactionCategory != null
                                  ? TextStyle(color: Colors.white)
                                  : TextStyle(color: Colors.white60),
                            ),
                            onTap: (FullScreenSelectItem category) {
                              setCategoryField(
                                context
                                    .read<AppTransactionNotifier>()
                                    .getAppTransactionCategories()
                                    .singleWhere((appTransactionCategory) =>
                                        appTransactionCategory.key ==
                                        category.value),
                              );
                              Navigator.pop(context);
                            },
                            actions: [
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.cyan),
                                onPressed: () {
                                  return showDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      final TextEditingController
                                          nameFieldController =
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
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                                                  appTransactionCategoriesRef =
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'appTransactionCategories');

                                              final appTransactionCategory =
                                                  AppTransactionCategory(
                                                key: nameFieldController.text
                                                    .toCamelCase(),
                                                value: nameFieldController.text
                                                    .trim(),
                                                type: 'user',
                                              );

                                              // TODO: check for duplicates before adding
                                              //       Show alert when category already exists
                                              DocumentReference docRef =
                                                  await appTransactionCategoriesRef
                                                      .add(
                                                          appTransactionCategory
                                                              .toMap());

                                              appTransactionCategory.id =
                                                  docRef.id;

                                              List<AppTransactionCategory>
                                                  appTransactionCategories =
                                                  context
                                                      .read<
                                                          AppTransactionNotifier>()
                                                      .getAppTransactionCategories();

                                              context
                                                  .read<
                                                      AppTransactionNotifier>()
                                                  .setAppTransactionCategories(
                                                [
                                                  ...appTransactionCategories,
                                                  appTransactionCategory
                                                ],
                                                notify: true,
                                              );

                                              setCategoryField(
                                                  appTransactionCategory);

                                              // Pop twice to go back to form
                                              Navigator.pop(context);
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
                        );
                      })
                    : Container(),

                // Notes Field
                Container(
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
                    // TODO: Create common widget for this ListTile
                    enabled: !isSaving,
                    isThreeLine: false,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      notesFieldController.text != ""
                          ? '${notesFieldController.text.replaceAll(new RegExp(r'\n'), ' ')}...'
                          : 'Notes',
                      style: notesFieldController.text != ""
                          ? TextStyle(color: Colors.white)
                          : TextStyle(color: Colors.white60),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text('Notes'),
                              ),
                              body: Padding(
                                padding: EdgeInsets.all(16),
                                child: AppTextField(
                                  controller: notesFieldController,
                                  enabled: !isSaving,
                                  label: 'Notes',
                                  minLines: 15,
                                  maxLines: 15,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
