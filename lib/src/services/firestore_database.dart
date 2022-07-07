import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/services/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({required this.uid});
  final String uid;
  FirebaseFirestore _firestore = FirebaseFirestore.instance; // Create an instance of Firebase Firestore.


  Stream getScores(User user) {
    return FirebaseFirestore.instance
        .collection('scores')
        .where('you', isEqualTo: user.email)
        .orderBy('date', descending: true)
        .snapshots();
  }
  // a stream that is continuously listening for changes happening in the database

}