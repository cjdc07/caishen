import 'package:cjdc_money_manager/app_transaction/app_transaction_model.dart';
import 'package:cjdc_money_manager/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountColor {
  final int alpha;
  final int red;
  final int green;
  final int blue;
  final String name;

  AccountColor({
    this.alpha,
    this.red,
    this.green,
    this.blue,
    this.name,
  });

  static AccountColor parse(Map<String, dynamic> data) {
    return AccountColor(
      alpha: data['alpha'],
      red: data['red'],
      green: data['green'],
      blue: data['blue'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alpha': alpha,
      'red': red,
      'green': green,
      'blue': blue,
      'name': name,
    };
  }

  @override
  String toString() {
    return "{ alpha: $alpha, red: $red, green: $green, blue: $blue, name: $name }";
  }
}

class AccountType {
  final String key;
  final String value;

  AccountType({this.key, this.value});

  static AccountType parse(Map<String, dynamic> data) {
    return AccountType(
      key: data['key'],
      value: data['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() {
    return "{ key: $value, value: $value }";
  }
}

class Account {
  String id;
  final String name;
  double balance;
  final AccountColor color;
  final AccountType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    this.id,
    this.name,
    this.balance,
    this.color,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  void deduct(double amount) {
    balance -= amount;
  }

  void add(double amount) {
    balance += amount;
  }

  void processDeletedAppTransaction(
    AppTransaction appTransaction,
    CollectionReference accountColRef,
  ) {
    if (appTransaction.type == AppTransactionType.Income) {
      DocumentReference fromAccountDocRef = accountColRef.doc(id);
      deduct(appTransaction.amount);
      fromAccountDocRef.update(toMap());
    } else if (appTransaction.type == AppTransactionType.Expense) {
      DocumentReference fromAccountDocRef = accountColRef.doc(id);
      add(appTransaction.amount);
      fromAccountDocRef.update(toMap());
    } else {
      // TODO: only handles transferring TO an account

      // TODO: currently, this does not use 'this' account. it creates new
      //       account objects for to and from. seems inefficient
      final DocumentReference fromAccountDocRef =
          accountColRef.doc(appTransaction.from);

      final DocumentReference toAccountDocRef =
          accountColRef.doc(appTransaction.to);

      fromAccountDocRef.get().then((value) {
        Account fromAccount = Account.parse(value.data());
        fromAccount.add(appTransaction.amount);
        fromAccountDocRef.update(fromAccount.toMap());
      });

      toAccountDocRef.get().then((value) {
        Account toAccount = Account.parse(value.data());
        toAccount.deduct(appTransaction.amount);
        toAccountDocRef.update(toAccount.toMap());
      });
    }
  }

  void processCreatedAppTransaction(
    AppTransaction appTransaction,
    CollectionReference accountColRef,
  ) {
    if (appTransaction.type == AppTransactionType.Income) {
      DocumentReference fromAccountDocRef = accountColRef.doc(id);
      add(appTransaction.amount);
      fromAccountDocRef.update(toMap());
    } else if (appTransaction.type == AppTransactionType.Expense) {
      DocumentReference fromAccountDocRef = accountColRef.doc(id);
      deduct(appTransaction.amount);
      fromAccountDocRef.update(toMap());
    } else {
      // TODO: only handles transferring TO an account

      // TODO: currently, this does not use 'this' account. it creates new
      //       account objects for to and from. seems inefficient
      final DocumentReference fromAccountDocRef =
          accountColRef.doc(appTransaction.from);

      final DocumentReference toAccountDocRef =
          accountColRef.doc(appTransaction.to);

      fromAccountDocRef.get().then((value) {
        Account fromAccount = Account.parse(value.data());
        fromAccount.deduct(appTransaction.amount);
        fromAccountDocRef.update(fromAccount.toMap());
      });

      toAccountDocRef.get().then((value) {
        Account toAccount = Account.parse(value.data());
        toAccount.add(appTransaction.amount);
        toAccountDocRef.update(toAccount.toMap());
      });
    }
  }

  void processUpdatedAppTransaction(
    AppTransaction oldAppTransaction,
    AppTransaction appTransaction,
    CollectionReference accountColRef,
  ) {
    if (appTransaction.type == AppTransactionType.Income) {
      DocumentReference fromAccountDocRef = accountColRef.doc(id);
      deduct(oldAppTransaction.amount);
      add(appTransaction.amount);
      fromAccountDocRef.update(toMap());
    } else if (appTransaction.type == AppTransactionType.Expense) {
      DocumentReference fromAccountDocRef = accountColRef.doc(id);
      add(oldAppTransaction.amount);
      deduct(appTransaction.amount);
      fromAccountDocRef.update(toMap());
    } else {
      // TODO: Update Transfer App Transaction do soon!

      // TODO: Transaction Update does not handle Transfer Transactions

      // TODO: only handles transferring TO an account

      // TODO: currently, this does not use 'this' account. it creates new
      //       account objects for to and from. seems inefficient
    }
  }

  static Account parse(Map<String, dynamic> data) {
    return Account(
      id: data['id'],
      name: data['name'],
      balance: data['balance'] is int
          ? (data['balance'] as int).toDouble()
          : data['balance'],
      color: AccountColor.parse(data['color']),
      type: AccountType.parse(data['type']),
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  static List<Account> parseList(List accounts) {
    return accounts
        .map(
          (account) => Account.parse(account),
        )
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'balance': balance,
      'color': color.toMap(),
      'type': type.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return "{ id: $id, name: $name, balance: $balance, color: ${color.toString()}, type: ${type.toString()}, createdAt: $createdAt, updatedAt: $updatedAt}";
  }
}
