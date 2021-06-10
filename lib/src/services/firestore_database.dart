

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:netten/src/models/friend.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FireStoreDatabase {
  FireStoreDatabase(this.uid) : assert(uid != null, 'Cannot create FireStore database without uid');
  final User user = FirebaseAuth.instance.currentUser;
  final String uid;

  Future<void> addFriend(Friend friend) => FirebaseFirestore.instance.collection('friends').add({
    'email': user.email,
    'friend_email': friend.email,
    'friend_name' : friend.name,
    'uid': user.uid
  });
}