import 'package:cloud_firestore/cloud_firestore.dart';

class AccountFirebase {
  AccountFirebase();

  Future<DocumentReference> add(Map<String, dynamic> account) async {
    final CollectionReference accountCollectionReference =
        FirebaseFirestore.instance.collection('accounts');

    return accountCollectionReference.add(account);
  }
}
