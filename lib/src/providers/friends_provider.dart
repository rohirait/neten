import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/providers/auth_provider.dart';

import '../models/friend.dart';

final StreamProvider friendsStreamProvider = StreamProvider((ref) {
  final String? email = ref.read(authenticationProvider).getUser()?.email;
  return FirebaseFirestore.instance.collection('friends').where('email', isEqualTo: email).snapshots().map((snapshot) {
    print(snapshot.toString());
    return snapshot.docs.map((doc) {
      print("and document is: " + doc.toString());
      return Friend.fromMap(doc.data());
    }).toList();
  });
});

Future<List<String>> addFriend({required String email, required String name, required User user}) async {
  var dbref1 = await FirebaseFirestore.instance
      .collection("friends")
      .add({'email': user.email, 'friend_email': email, 'friend_name': name, 'uid': user.uid});

  var dbref2 = await FirebaseFirestore.instance.collection("friend_request").add({
    'email': user.email,
    'recipient_email': email,
    'recipient_name': name,
    'sender_uid': user.uid,
    'sender_name': user.displayName,
    'status': "PENDING"
  });
  return [dbref1.id, dbref2.id];
}
