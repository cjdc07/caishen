import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtil {
  static Future<QuerySnapshot> getAppTransactionsSnapshot() {
    return FirebaseFirestore.instance.collection('appTransactions').get();
  }

  static Future<QuerySnapshot> getAppTransactionCategoriesSnapshot() {
    return FirebaseFirestore.instance
        .collection('appTransactionCategories')
        .get();
  }
}
