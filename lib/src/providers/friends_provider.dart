import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/providers/auth_provider.dart';

import 'package:netten/src/models/friend.dart';
import 'package:netten/src/models/friend_request.dart';

import '../models/client.dart';

final friendsStreamProvider = StreamProvider.autoDispose((ref) {
  final User? user = ref.read(authenticationProvider).getUser();
  return FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('myFriends').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Friend.fromMap(doc.data());
    }).toList();
  });
});

Future<bool> addFriendFromRequest({required String id, required String email, required String name, required Client? user}) async {
  var dbref1 = await FirebaseFirestore.instance
      .collection("users")
      .doc(user?.uid)
      .collection('myFriends')
      .add({'email': user?.email, 'friend_email': email, 'friend_name': name, 'uid': user?.uid});
  dbref1.update({'id': dbref1.id});
  await FirebaseFirestore.instance.collection("friend_request").doc(id).update({'status': 'ACCEPTED'});
  return true;
}

Future<Friend?> findUserFriendByEmail({required String email, required User user}) async {
  return FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection('myFriends')
      .limit(1)
      .where('email', isEqualTo: email)
      .get()
      .then((QuerySnapshot<Map<String, dynamic>> value) {
    return value.docs.isNotEmpty ? Friend.fromMap(value.docs.first.data()) : null;
  });
}

Future<List<String>> addFriend({required String email, required String name, required Client? user, bool createFriendRequest = true}) async {
  var dbref1 = await FirebaseFirestore.instance
      .collection("users")
      .doc(user?.uid)
      .collection('myFriends')
      .add({'email': user?.email, 'friend_email': email, 'friend_name': name, 'uid': user?.uid, 'added': DateTime.now()});
  dbref1.update({'id': dbref1.id});

  if (email.isNotEmpty) {
    if (createFriendRequest)
      await FirebaseFirestore.instance.collection("friend_request").add({
        'email': user?.email,
        'recipient_email': email,
        'recipient_name': name,
        'sender_uid': user?.uid,
        'sender_name': user?.displayName,
        'created': FieldValue.serverTimestamp(),
        'status': "PENDING"
      });
    addToAnalytics(email);
  };
  return [dbref1.id];
}

Future<void> addToAnalytics(String email) async {
  bool test = await checkIfUserExists(email);
  if (test) {
    return;
  }
  await addUserToEmailCollection(email);
}

Future<bool> denyRequest({required String id}) async {
  await FirebaseFirestore.instance.collection("friend_request").doc(id).update({'status': 'DENIED'});

  return true;
}

Future<bool> deleteFriend(User user, String friendId, String email) async {
  await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('myFriends').doc(friendId).delete();

  QuerySnapshot<Map<String, dynamic>> docs = await FirebaseFirestore.instance
      .collection('friend_request')
      .where('recipient_email', isEqualTo: email)
      .where('email', isEqualTo: user.email)
      .get();

  for (var doc in docs.docs) {
    await doc.reference.delete();
  }
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

void updateFriend({required String email, required String friendId, required Client user}) async {
  //1. Update the email of friend
  await FirebaseFirestore.instance.collection("users").doc(user.uid).collection('myFriends').doc(friendId).update({'friend_email': email});
  //2. Set up the friend request so you can be accepted
  await FirebaseFirestore.instance
      .collection("friend_request")
      .add({'email': user.email, 'recipient_email': email, 'sender_uid': user.uid, 'sender_name': user.displayName, 'status': "PENDING"});
  //3. Add user email for checking if new user
  await addToAnalytics(email);
  //4-5. Change all scores to also reflect the email. Then create score_requests from all.
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
      Score score = Score.fromMap(document.data(), document.id);
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

Future<List<Friend?>?> getFriends({required User user}) async {
  try {
    var a = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('myFriends').get();
    return a.docs.map((doc) {
      return Friend.fromMap(doc.data());
    }).toList();
  } on FirebaseException catch (e) {
    print(e);
  }
  return null;
}

Future<bool> checkIfUserExists(String userEmail) async {
  try {
    var snapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).get();
    return snapshot.docs.isNotEmpty;
  } catch (e) {
    print("Error checking user existence: $e");
    return false;
  }
}

Future<void> addUserToEmailCollection(String email) async {
  try {
    await FirebaseFirestore.instance.collection('usersToEmail').add({'email': email});
    print('User with email $email added to usersToEmail collection.');
  } catch (e) {
    print("Error adding user to usersToEmail collection: $e");
  }
}
