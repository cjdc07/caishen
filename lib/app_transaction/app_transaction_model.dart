import 'package:cloud_firestore/cloud_firestore.dart';

class AppTransaction {
  String id;
  final DocumentReference account;
  final String description;
  final String to;
  final String from;
  final DocumentReference category;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final String notes;

  AppTransaction({
    this.id,
    this.account,
    this.description,
    this.to,
    this.from,
    this.category,
    this.amount,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.notes,
  });

  static AppTransaction parse(Map<String, dynamic> data) {
    return AppTransaction(
      id: data['id'],
      account: data['account'],
      amount: data['amount'] is int
          ? (data['amount'] as int).toDouble()
          : data['amount'],
      description: data['description'],
      category: data['category'],
      from: data['from'],
      to: data['to'],
      type: data['type'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
      notes: data['notes'],
    );
  }

  static List<AppTransaction> parseList(List appTransactions) {
    return appTransactions
        .map(
          (appTransaction) => AppTransaction.parse(appTransaction),
        )
        .toList();
  }

  static Map<String, List<AppTransaction>> groupTransactionsByCreationDate(
      List<AppTransaction> transactions) {
    Map<String, List<AppTransaction>> result = new Map();

    transactions.forEach((transaction) {
      String key = transaction.createdAt.toIso8601String().split('T')[0];
      if (!result.containsKey(key)) {
        result[key] = [];
      }
      result[key].add(transaction);
    });

    result.forEach((_, value) {
      value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    return result;
  }

  Future<AppTransactionCategory> getAppTransactionCategory() async {
    // TODO: Something wrong with this after updating transaction
    return AppTransactionCategory.parse((await category.get()).data());
  }

  Map<String, dynamic> toMap() {
    return {
      'account': account,
      'description': description,
      'to': to,
      'from': from,
      'category': category,
      'amount': amount,
      'type': type,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return "{ id: $id, account: $account, description: $description, \ to: $to, from: $from, category: ${category.toString()}, amount: $amount, type: $type, createdAt: $createdAt, updatedAt: $updatedAt }";
  }
}

class AppTransactionCategory {
  String id;
  final String name;

  AppTransactionCategory({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  static AppTransactionCategory parse(Map<String, dynamic> data) {
    return AppTransactionCategory(id: data['id'], name: data['name']);
  }

  static List<AppTransactionCategory> parseList(List appTransactionCategories) {
    return appTransactionCategories
        .map(
          (appTransactionCategory) =>
              AppTransactionCategory.parse(appTransactionCategory),
        )
        .toList();
  }

  @override
  String toString() {
    return '{ id: $id, name: $name }';
  }
}
