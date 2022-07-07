import '../../util.dart';

class ScoreRequest {
  String id;
  int opponentScore;
  int yourScore;
  String opponentEmail;
  String date;
  String? opponentName;



  ScoreRequest({required this.opponentScore,
    required this.yourScore,
    required this.date,
    required this.opponentEmail,
    required this.id});

  ScoreRequest.fromMap(Map<String, dynamic>? data, {required String id})
      : id = id,
        opponentScore = data?['your_score'] ?? '',
        yourScore = data?['opponent_score'] ?? '',
        opponentEmail = data?['you'] ?? '',
        date = data?['date'] != null ? readTimestamp(data!['date'].toDate()) : '' ;
}