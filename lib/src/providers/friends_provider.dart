import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/providers/auth_provider.dart';

import '../models/friend.dart';
import '../models/friend_request.dart';

final StreamProvider<List<Friend>> friendsStreamProvider = StreamProvider((ref) {
  final User? user = ref.read(authenticationProvider).getUser();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('myFriends')
      .snapshots()
      .map((snapshot) {
    print(snapshot.toString());
    return snapshot.docs.map((doc) {
      return Friend.fromMap(doc.data());
    }).toList();
  });
});

Future<bool> addFriendFromRequest(
    {required String id, required String email, required String name, required User? user}) async {
  var dbref1 = await FirebaseFirestore.instance
      .collection("users")
      .doc(user?.uid)
      .collection('myFriends')
      .add({'email': user?.email, 'friend_email': email, 'friend_name': name, 'uid': user?.uid});
  dbref1.update({'id': dbref1.id});
  await FirebaseFirestore.instance.collection("friend_request").doc(id).update({'status': 'ACCEPTED'});
  return true;
}

Future<List<String>> addFriend(
    {required String email, required String name, required User? user, bool createFriendRequest = true}) async {
  var dbref1 = await FirebaseFirestore.instance
      .collection("users")
      .doc(user?.uid)
      .collection('myFriends')
      .add({'email': user?.email, 'friend_email': email, 'friend_name': name, 'uid': user?.uid});
  dbref1.update({'id': dbref1.id});

  if (email.isNotEmpty && createFriendRequest)
    await FirebaseFirestore.instance.collection("friend_request").add({
      'email': user?.email,
      'recipient_email': email,
      'recipient_name': name,
      'sender_uid': user?.uid,
      'sender_name': user?.displayName,
      'status': "PENDING"
    });
  return [dbref1.id];
}

Future<bool> denyRequest({required String id}) async {
  await FirebaseFirestore.instance.collection("friend_request").doc(id).update({'status': 'DENIED'});

  return true;
}

final friendRequestProvider = StreamProvider.autoDispose((ref) {
  final String? email = ref.read(authenticationProvider).getUser()?.email;

  return FirebaseFirestore.instance
      .collection('friend_request')
      .where('recipient_email', isEqualTo: email)
      .where('status', isEqualTo: "PENDING")
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      FriendRequest friendRequest = FriendRequest.fromMap(doc.data(), id: doc.id);

      return friendRequest;
    }).toList();
  });
});

void updateFriend({required String email, required String friendId, required User user}) async {
  //1. Update the email of friend
  await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection('myFriends')
      .doc(friendId)
      .update({'friend_email': email});
  //2. Set up the friend request so you can be accepted
  await FirebaseFirestore.instance.collection("friend_request").add({
    'email': user.email,
    'recipient_email': email,
    'sender_uid': user.uid,
    'sender_name': user.displayName,
    'status': "PENDING"
  });
  //3-4. Change all scores to also reflect the email. Then create score_requests from all.
  WriteBatch myScoresBatch = FirebaseFirestore.instance.batch();

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('myScores')
      .where('friendId', isEqualTo: friendId)
      .get()
      .then((snapshot) {
    snapshot.docs.forEach((document) async {
      myScoresBatch.update(document.reference, {'opponentEmail': email});
      Score score = Score.fromMap(document.data());
      FirebaseFirestore.instance.collection("score_request").add({
        'date': document.data()['date'],
        'opponent': email,
        'your_score': score.opponentScore,
        'opponent_score': score.yourScore,
        'you': user.email ?? '',
        'created': FieldValue.serverTimestamp(),
        'accepted': 'PENDING'
      });
    });
  });
  myScoresBatch.commit();
}
