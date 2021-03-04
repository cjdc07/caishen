import 'package:cjdc_money_manager/account/account_form/account_mutation.dart';
import 'package:cjdc_money_manager/common/app_number_field.dart';
import 'package:cjdc_money_manager/common/app_text_field.dart';
import 'package:flutter/material.dart';

class AccountForm extends StatefulWidget {
  @override
  _AccountFormState createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController balanceFieldController = TextEditingController();
  String selectedColor = 'blue';
  bool isSaving = false;

  void setIsSaving(bool isSaving) {
    setState(() {
      this.isSaving = isSaving;
    });
  }

  void setSelectedColor(String color) {
    setState(() {
      this.selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, int>> colors = {
      'blue': {
        'alpha': 255,
        'red': 20,
        'green': 130,
        'blue': 184,
      },
      'red': {
        'alpha': 255,
        'red': 207,
        'green': 102,
        'blue': 121,
      },
      'lightBlue': {
        'alpha': 255,
        'red': 30,
        'green': 144,
        'blue': 255,
      },
      'green': {
        'alpha': 255,
        'red': 41,
        'green': 199,
        'blue': 173,
      },
      'darkGreen': {
        'alpha': 255,
        'red': 0,
        'green': 129,
        'blue': 138,
      },
      'grey': {
        'alpha': 255,
        'red': 128,
        'green': 128,
        'blue': 128,
      },
      'orange': {
        'alpha': 255,
        'red': 255,
        'green': 140,
        'blue': 0,
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        actions: [
          AccountMutation(
            formKey: _formKey,
            nameFieldController: nameFieldController,
            balanceFieldController: balanceFieldController,
            color: colors[selectedColor],
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppTextField(
                  controller: nameFieldController,
                  enabled: !isSaving,
                  label: 'Account Name',
                ),
                AppNumberField(
                  controller: balanceFieldController,
                  min: 0,
                  hasMin: true,
                  enabled: !isSaving,
                  label: 'Balance',
                ),
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      Row(
                        children: colors.keys
                            .map(
                              (key) => Container(
                                margin: EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () => setSelectedColor(key),
                                  child: Container(
                                    child: selectedColor == key
                                        ? Icon(Icons.check)
                                        : null,
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(
                                        colors[key]['alpha'],
                                        colors[key]['red'],
                                        colors[key]['green'],
                                        colors[key]['blue'],
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
