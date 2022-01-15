import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'firebase_convertable.dart';

class Score implements FirebaseConverter<Score> {
  int opponentScore;
  int yourScore;
  String uid;
  String opponent;
  String date;
  String opponentEmail;
  Score({this.opponentScore, this.yourScore, this.uid, this.opponent, this.date, this.opponentEmail});
  Score.fromMap(Map<String, dynamic> data)
      : opponentScore = data['opponent_score'] ?? '',
        yourScore = data['your_score'] ?? '',
        uid = data['uid'] ?? '',
        opponent = data['opponent'] ?? '',
        date = data['date'] ?? '',
        opponentEmail = data['opponent_email'];

  Score.fromSnapshot(DocumentSnapshot data)
      : uid = data.reference.id,
        opponentScore = data.get('opponent_score') ?? '',
        yourScore = data.get('your_score') ?? '',
        opponent = data.get('opponent') ?? '',
        date = data.get('date') != null ? readTimestamp(data.get('date').toDate()) : '',
        opponentEmail = data.get('opponent_email') ?? '';

  @override
  String id;

  @override
  Score parseFromMap(Map<String, dynamic> snapshot, String id) {
    return Score.fromMap(snapshot);
  }

  @override
  Map<String, dynamic> toJson() =>
      {'opponent_score': opponentScore, 'your_score': yourScore, 'uid': uid, 'opponent': opponent, 'date': date, 'opponent_email': opponentEmail};

  static String readTimestamp(DateTime timestamp) {
    return DateFormat('dd:MM:yy').format(timestamp);
  }
}
