import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/providers/friends_provider.dart';
import '../models/friend.dart';
import '../models/score_request.dart';
import 'auth_provider.dart';

final myScoresProvider = StreamProvider.autoDispose((ref) {
  final User? user = ref.read(authenticationProvider).getUser();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('myScores')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      Score score = Score.fromMap(doc.data(), doc.id);
      return score;
    }).toList();
  });
});

Stream<List<Score>> friendScores(Friend friend, User user) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('myScores')
      .where('friendId', isEqualTo: friend.id)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      Score score = Score.fromMap(doc.data(), doc.id);
      return score;
    }).toList();
  });
}

Future<bool> deleteScore(String userId, String scoreId) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).collection('myScores').doc(scoreId).delete();
  return true;
}

final scoreRequestProvider = StreamProvider.autoDispose((ref) {
  final String? email = ref.read(authenticationProvider).getUser()?.email;
  List<Friend?>? friends = ref.watch(friendsProvider).value;
  return FirebaseFirestore.instance
      .collection('score_request')
      .where('opponent', isEqualTo: email)
      .where('accepted', isEqualTo: "PENDING")
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      ScoreRequest scoreRequest = ScoreRequest.fromMap(doc.data(), id: doc.id);
      String name = scoreRequest.opponentEmail;

      if (friends != null) {
        for (Friend? f in friends) {
          if (f?.email == scoreRequest.opponentEmail && f?.name != null) {
            name = f!.name;
          }
        }
      }
      scoreRequest.opponentName = name;
      return scoreRequest;
    }).toList();
  });
});
//should be a streamProvider
final friendsProvider = FutureProvider<List<Friend?>?>((ref) async {
  final User? user = ref.read(authenticationProvider).getUser();
  return getFriends(user: user!);
});

Stream getScores(User? user) {
  return FirebaseFirestore.instance
      .collection('scores')
      .where('you', isEqualTo: user?.email)
      .orderBy('date', descending: true)
      .snapshots();
}

//todo way too many variables. Should be easier
@override
Future<List<String>> createScore({required DateTime date, required Score score, required User user}) async {
  try {
    DocumentReference ref =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).collection('myScores').add({
      'date': date,
      'opponent': score.opponent,
      'your_score': score.yourScore,
      'opponent_score': score.opponentScore,
      'opponent_sets': score.opponentSets,
      'my_sets': score.mySets,
      'created': FieldValue.serverTimestamp(),
      'friendId': score.friendId,
      'opponentEmail': score.opponentEmail,
      'comment': score.comment
    });
    //Todo this will change, because we only add a "Score" if both side accept
    // DocumentReference ref1 = await FirebaseFirestore.instance.collection("scores").add({
    //   'date': date,
    //   'opponent': score.opponent,
    //   'your_score': score.yourScore,
    //   'opponent_score': score.opponentScore,
    //   'you': email,
    //   'created': FieldValue.serverTimestamp()
    // });
    //todo check if opponent is read somewhere
    if (score.opponentEmail.isNotEmpty) {
      DocumentReference ref2 = await FirebaseFirestore.instance.collection("score_request").add({
        'date': date,
        'opponent': score.opponentEmail,
        'your_score': score.opponentScore,
        'opponent_score': score.yourScore,
        'opponent_sets': score.mySets,
        'my_sets': score.opponentSets,
        'you': user.email ?? '',
        'created': FieldValue.serverTimestamp(),
        'accepted': 'PENDING'
      });
    }

    return ['Added'];
  } on FirebaseException catch (e) {
    throw Exception(e.toString());
  }
}

Future<void> createScoreFromRequest(ScoreRequest scoreRequest, User user) async {
  //this is still correct as well
  await FirebaseFirestore.instance.collection("scores").add({
    'date': DateFormat('dd.MM.yy').parse(scoreRequest.date),
    'opponent': scoreRequest.opponentEmail,
    'your_score': scoreRequest.opponentScore,
    'opponent_score': scoreRequest.yourScore,
    'you': user.email,
    'created': FieldValue.serverTimestamp()
  });

  Friend? friend = await findUserFriendByEmail(email: scoreRequest.opponentEmail, user: user);

  await FirebaseFirestore.instance.collection("users").doc(user.uid).collection('myScores').add({
    'date': DateFormat('dd.MM.yy').parse(scoreRequest.date),
    'opponent': scoreRequest.opponentName,
    'your_score': scoreRequest.opponentScore,
    'opponent_score': scoreRequest.yourScore,
    'opponent_sets': scoreRequest.opponentSets,
    'my_sets': scoreRequest.mySets,
    'created': FieldValue.serverTimestamp(),
    'friendId': friend != null ? friend.id : '',
    'opponentEmail': scoreRequest.opponentEmail
  });

  await FirebaseFirestore.instance.collection('score_request').doc(scoreRequest.id).update({'accepted': 'ACCEPTED'});
}

Future<void> denyScoreRequest(ScoreRequest scoreRequest) async {
  await FirebaseFirestore.instance.collection('score_request').doc(scoreRequest.id).update({'accepted': 'DENIED'});
}
