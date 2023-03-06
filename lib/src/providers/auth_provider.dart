import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:netten/src/models/authentication.dart';


final authenticationProvider = Provider<Authentication>((ref) {
  return Authentication();
});


final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});
//todo(Rait) wrong place, write an DAO that allows for updating document easily
Future<void> deleteUser(String id){
 return FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({'deleteRequested': true});
}



