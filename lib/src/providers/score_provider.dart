import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/src/providers/top_level_providers.dart';

import 'package:netten/src/models/score.dart';
import '../models/friend.dart';
import '../models/score_request.dart';
import 'auth_provider.dart';

final scoresProvider = StreamProvider.autoDispose((ref) {
  final String? email = ref.read(authenticationProvider).getUser()?.email;
  return FirebaseFirestore.instance
      .collection('scores')
      .where('you', isEqualTo: email)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      Score score = Score.fromMap(doc.data());
      return score;
    }).toList();
  });
});

final scoreRequestProvider = StreamProvider.autoDispose((ref) {
  final String? email = ref.read(authenticationProvider).getUser()?.email;
  final List<Friend?>? friends = ref.read(friendsProvider).value;

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
          if(f?.email == scoreRequest.opponentEmail && f?.name != null){
            name = f!.name;
          }
        }
      }
      scoreRequest.opponentName = name;
      return scoreRequest;
    }).toList();
  });
});

final friendsProvider = FutureProvider<List<Friend?>?>((ref) async {
  final String? email = ref.read(authenticationProvider).getUser()?.email;
  List<Friend?>? s = await getFriends(email: email);
  return getFriends(email: email);
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
Future<List<String>> createScore({required DateTime date, required Score score, required String yourEmail}) async {
  try {
    DocumentReference ref1 = await FirebaseFirestore.instance.collection("scores").add({
      'date': date,
      'opponent': score.opponent,
      'your_score': score.yourScore,
      'opponent_score': score.opponentScore,
      'you': yourEmail,
      'created': FieldValue.serverTimestamp()
    });
    DocumentReference ref2 = await FirebaseFirestore.instance.collection("score_request").add({
      'date': date,
      'opponent': yourEmail,
      'your_score': score.opponentScore,
      'opponent_score': score.yourScore,
      'you': score.opponentEmail,
      'created': FieldValue.serverTimestamp(),
      'accepted': 'PENDING'
    });

    return [ref1.id, ref2.id];
  } on FirebaseException catch (e) {
    throw Exception(e.toString());
  }
}

Future<void> createScoreFromRequest(ScoreRequest scoreRequest, String email) async{
   await FirebaseFirestore.instance.collection("scores").add({
    'date': DateFormat('dd.MM.yy').parse(scoreRequest.date),
    'opponent': scoreRequest.opponentEmail,
    'your_score': scoreRequest.opponentScore,
    'opponent_score': scoreRequest.yourScore,
    'you': email,
    'created': FieldValue.serverTimestamp()
  });

   await FirebaseFirestore.instance.collection('score_request').doc(scoreRequest.id).update({'accepted':'ACCEPTED'});
}

Future<void> denyScoreRequest(ScoreRequest scoreRequest) async {
  await FirebaseFirestore.instance.collection('score_request').doc(scoreRequest.id).update({'accepted':'DENIED'});

}

Future<List<Friend?>?> getFriends({required String? email}) async {
  try {
    var a = await FirebaseFirestore.instance.collection('friends').where('email', isEqualTo: email).get();
    return a.docs.map((doc) {
      return Friend.fromMap(doc.data());
    }).toList();
  } on FirebaseException catch (e) {
    print(e);
  }
  return null;
}
