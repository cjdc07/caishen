import 'package:cjdc_money_manager/account/account_model.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_form/app_transaction_category_select.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_form/app_transaction_mutation.dart';
import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/change_notifiers/cash_flow_data.dart';
import 'package:cjdc_money_manager/common/app_dropdown_field.dart';
import 'package:cjdc_money_manager/common/app_number_field.dart';
import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:cjdc_money_manager/common/full_screen_select.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionForm extends StatefulWidget {
  final AppTransaction appTransaction;

  TransactionForm({Key key, this.appTransaction}) : super(key: key);

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
  AppTransactionCategory selectedAppTransactionCategory;
  String selectedTransferAccount;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    notesFieldController.addListener(() {
      setState(() {});
    });

    if (widget.appTransaction != null) {
      descriptionFieldController.value =
          TextEditingValue(text: widget.appTransaction.description);

      amountFieldController.value =
          TextEditingValue(text: widget.appTransaction.amount.toString());

      toFieldController.value =
          TextEditingValue(text: widget.appTransaction.to);

      fromFieldController.value =
          TextEditingValue(text: widget.appTransaction.from);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.appTransaction.category.get().then(
              (value) => setState(
                () {
                  Map<String, dynamic> data = value.data();
                  data['id'] = value.id;
                  selectedAppTransactionCategory =
                      AppTransactionCategory.parse(data);
                },
              ),
            );
      });

      notesFieldController.value = TextEditingValue(
          text: widget.appTransaction.notes != null
              ? widget.appTransaction.notes
              : "");

      if (widget.appTransaction.type == AppTransactionType.Transfer) {
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

  void setTransactionTypeField(String appTransactionType) {
    // TODO: only set this after submitting form
    Provider.of<CashFlowData>(context, listen: false)
        .setSelectedAppTransactionType(appTransactionType);
  }

  void setIsSaving(bool isSaving) {
    setState(() {
      this.isSaving = isSaving;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Account account =
        Provider.of<CashFlowData>(context).getSelectedAccount();

    final String selectedAppTransactionTypeValue = widget.appTransaction == null
        ? Provider.of<CashFlowData>(context).getSelectedAppTransactionType()
        : widget.appTransaction.type;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appTransaction != null
            ? 'Update Transaction'
            : 'Create Transaction'),
        actions: [
          AppTransactionMutation(
            oldAppTransaction: widget.appTransaction,
            formKey: _formKey,
            accountId: account.id,
            selectedAppTransactionTypeValue: selectedAppTransactionTypeValue,
            descriptionFieldController: descriptionFieldController,
            amountFieldController: amountFieldController,
            fromFieldController: fromFieldController,
            toFieldController: toFieldController,
            appTransactionCategoryFieldValue: selectedAppTransactionCategory,
            notesFieldController: notesFieldController,
            transferAccountFieldValue: selectedTransferAccount,
            setIsSaving: setIsSaving,
            isSaving: isSaving,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ListView(
              children: <Widget>[
                AppDropDownField(
                  controller: setTransactionTypeField,
                  defaultValue: selectedAppTransactionTypeValue,
                  enabled: !isSaving,
                  label: 'Transaction Type',
                  items: [
                    {
                      'label': 'Income',
                      'value': AppTransactionType.Income,
                    },
                    {
                      'label': 'Expense',
                      'value': AppTransactionType.Expense,
                    },
                    {
                      'label': 'Transfer',
                      'value': AppTransactionType.Transfer,
                    },
                  ],
                ),
                AppTextField(
                  controller: descriptionFieldController,
                  enabled: !isSaving,
                  label: 'Description',
                ),
                AppNumberField(
                  controller: amountFieldController,
                  max: widget.appTransaction != null
                      ? account.balance + widget.appTransaction.amount
                      : account.balance,
                  hasMax: selectedAppTransactionTypeValue ==
                          AppTransactionType.Expense ||
                      selectedAppTransactionTypeValue ==
                          AppTransactionType.Transfer,
                  enabled: !isSaving,
                  label: 'Amount',
                ),
                selectedAppTransactionTypeValue == AppTransactionType.Transfer
                    ? AppDropDownField(
                        defaultValue: selectedTransferAccount,
                        controller: setTransferAccountField,
                        enabled: !isSaving,
                        items: Provider.of<CashFlowData>(context)
                            .getAccounts()
                            .where((other) => other.id != account.id)
                            .map(
                              (other) => {
                                'label': other.name,
                                'value': other.id,
                              },
                            )
                            .toList(),
                        label: 'To',
                      )
                    : Container(),
                selectedAppTransactionTypeValue == AppTransactionType.Income
                    ? AppTextField(
                        controller: fromFieldController,
                        enabled: !isSaving,
                        label: 'From',
                      )
                    : Container(),
                selectedAppTransactionTypeValue == AppTransactionType.Expense
                    ? AppTextField(
                        controller: toFieldController,
                        enabled: !isSaving,
                        label: 'To',
                      )
                    : Container(),
                FullScreenSelect(
                  enabled: !isSaving,
                  fieldTitle: Text(
                    selectedAppTransactionCategory != null
                        ? selectedAppTransactionCategory.name
                        : 'Category',
                    style: selectedAppTransactionCategory != null
                        ? TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.white60),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return AppTransactionCategorySelect(
                            onTap: (appTransactionCategory) {
                              setCategoryField(
                                appTransactionCategory,
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                FullScreenSelect(
                  enabled: !isSaving,
                  fieldTitle: Text(
                    notesFieldController.text != ""
                        ? '${notesFieldController.text.replaceAll(new RegExp(r'\n'), ' ')}...'
                        : 'Notes',
                    style: notesFieldController.text != ""
                        ? TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.white60),
                  ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
