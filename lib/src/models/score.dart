import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'firebase_convertable.dart';

class Score {
  int opponentScore;
  int yourScore;
  String uid;
  String opponent;
  String date;
  String opponentEmail;
  String? _fullName;
  String friendId;
  List<int>? mySets;
  List<int>? opponentSets;
  String? comment;

  Score(
      {required this.opponentScore,
      required this.yourScore,
      required this.uid,
      required this.opponent,
      required this.date,
      required this.opponentEmail,
      required this.friendId,
      this.mySets,
      this.opponentSets,
      this.comment});

  Score.fromMap(Map<String, dynamic>? data, String id)
      : opponentScore = data?['opponent_score'] ?? '',
        yourScore = data?['your_score'] ?? '',
        uid = data?['uid'] ?? '',
        opponent = data?['opponent'] ?? '',
        date = data?['date'] != null ? readTimestamp(data!['date'].toDate()) : '',
        opponentEmail = data?['opponent_email'] ?? '',
        friendId = data?['friendId'],
        mySets = List.castFrom(data?['my_sets'] as List? ?? []),
        opponentSets = List.castFrom(data?['opponent_sets']  as List? ?? []),
        comment = data?['comment'],
        id = id.toString();

  Score.fromSnapshot(DocumentSnapshot<dynamic> data)
      : uid = data.reference.id,
        opponentScore = data.get('opponent_score') ?? '',
        yourScore = data.get('your_score') ?? '',
        opponent = data.get('opponent') ?? '',
        date = data.get('date') != null ? readTimestamp(data.get('date').toDate()) : '',
        friendId = data.get('friendId') ?? '',
        mySets = data.get('my_sets') ?? [],
        opponentSets = data.get('opponent_sets') ?? [],
        comment = data.get('comment') ?? '',
        opponentEmail = data.data()['opponent_email'] ?? '';

  // opponentEmail = data?.get('opponent_email') ?? '';

  @override
  String? id;

  @override
  Score parseFromMap(Map<String, dynamic> snapshot, String id) {
    return Score.fromMap(snapshot, id);
  }

  set fullName(String? value) {
    _fullName = value;
  }

  String? get fullName {
    return _fullName ?? 'Unknown';
  }

  @override
  Map<String, dynamic> toJson() => {
        'opponent_score': opponentScore,
        'your_score': yourScore,
        'uid': uid,
        'opponent': opponent,
        'date': date,
        'opponent_email': opponentEmail,
        'friendId': friendId
      };

  static String readTimestamp(DateTime timestamp) {
    return DateFormat('dd.MM.yyyy').format(timestamp);
  }

  Stream getScores(User user) {
    return FirebaseFirestore.instance
        .collection('scores')
        .where('you', isEqualTo: user.email)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
