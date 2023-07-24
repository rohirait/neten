import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client.dart';
import 'auth_provider.dart';

final clientProvider = StreamProvider.autoDispose<Client?>((ref) {
  final User? user = ref.read(authenticationProvider).getUser();
  String? uid = user?.uid;
  if (uid != null) {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userStream = userCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        return Client(
          email: data?['email'],
          name: data?['name'],
          uid: data?['uid'],
          url: data?['url'],
        );
      } else {
        return null;
      }
    });
    return userStream;
  } else {
    return const Stream.empty();
  }
});

Future<void> updateUserFields({
  required String uid,
  required Client client,
}) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(uid);

    await userRef.update(client.toMap());
    print('User fields updated successfully');
  } catch (e) {
    print('Error updating user fields: $e');
  }
}