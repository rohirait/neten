// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:netten/src/models/score.dart';
//
// Widget ratingBody(BuildContext context, User user) {
//   return SafeArea(
//     child: Container(
//       height: MediaQuery.of(context).size.height,
//       decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/raster.jpg"), fit: BoxFit.cover)),
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
//         SizedBox(height: 10),
//         StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('score_request')
//                 .where('you', isEqualTo: user.email)
//                 .where('accepted', isEqualTo: "PENDING")
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.data == null)
//                 return CircularProgressIndicator();
//               else if (snapshot.data.docs.length > 0) {
//                 return ListView.builder(
//                     padding: const EdgeInsets.all(0),
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: snapshot.data.docs.length,
//                     itemBuilder: (context, index) {
//                       DocumentSnapshot friend = snapshot.data.docs[index];
//                       return StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('friends')
//                               .where('email', isEqualTo: user.email)
//                               .where('friend_email', isEqualTo: friend['opponent'])
//                               .snapshots(),
//                           builder: (context, snapshot) {
//                             if (snapshot.data == null)
//                               return CircularProgressIndicator();
//                             else if (snapshot.data.docs.length > 0) {
//                               DocumentSnapshot friendGame = snapshot.data.docs[0];
//                               return Container(
//                                 decoration: new BoxDecoration(
//                                     color: Color(0xFF00A6FF)
//                                         .withOpacity(0.5) // Specifies the background color and the opacity
//                                     ),
//                                 margin: EdgeInsets.only(right: 40.0, left: 40.0),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
//                                       child: Text("Score submit by: " + friendGame['friend_name'],
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 20.0, // insert your font size here
//                                           )),
//                                     ),
//                                     Text(friend['your_score'].toString() + ' : ' + friend['opponent_score'].toString()),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         ButtonTheme(
//                                           buttonColor: Colors.green,
//                                           height: 60.0,
//                                           child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(primary: Colors.green),
//                                             onPressed: () async {
//                                               Score score = Score(
//                                                   opponentScore: friend['opponent_score'],
//                                                   opponent: friendGame['friend_name'],
//                                                   yourScore: friend['your_score'],
//                                                   date: friend['date'].toDate().toString(),
//                                                   opponentEmail: friend['opponent']);
//                                               addScore(score, user, friend.id);
//                                             },
//                                             child: Text("Add"),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(left: 10.0),
//                                           child: ButtonTheme(
//                                             height: 60.0,
//                                             child: ElevatedButton(
//                                               style: ElevatedButton.styleFrom(primary: Colors.red),
//                                               onPressed: () async {
//                                                 _deleteRequest(friend.id);
//                                               },
//                                               child: Text("Delete"),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Divider()
//                                   ],
//                                 ),
//                               );
//                             } else {
//                               return SizedBox(height: 0);
//                             }
//                           });
//                     });
//               }
//               return Visibility(
//                 child: Text("Gone"),
//                 visible: false,
//               );
//             }),
//         FutureBuilder(
//             future: FirebaseFirestore.instance
//                 .collection('scores')
//                 .where('you', isEqualTo: user.email)
//                 .orderBy('date', descending: true)
//                 .get(),
//             builder: (context, snapshot) {
//               if (snapshot.data == null) return LinearProgressIndicator();
//               return Expanded(
//                 child: SingleChildScrollView(
//                   child: ListView.builder(
//                       padding: const EdgeInsets.all(8),
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: snapshot.data.docs.length,
//                       itemBuilder: (context, index) {
//                         // DocumentSnapshot opponent = snapshot;
//                         Score score = Score.fromSnapshot(snapshot.data.docs[index]);
//                         return Container(
//                           decoration: new BoxDecoration(
//                               color:
//                                   Color(0xFF00A6FF).withOpacity(0.5) // Specifies the background color and the opacity
//                               ),
//                           margin: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 10.0),
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
//                             child: Dismissible(
//                               key: UniqueKey(),
//                               child: GameColumn(score: score),
//                               onDismissed: (direction) async {
//                                 await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
//                                   await myTransaction.delete(snapshot.data.docs[index].reference);
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       }),
//                 ),
//               );
//             })
//       ]),
//     ),
//   );
// }
//
// void addScore(Score score, User user, String id) async {
//   await FirebaseFirestore.instance.collection("scores").add({
//     'date': DateTime.parse(score.date),
//     'opponent': score.opponent,
//     'opponent_email': score.opponentEmail,
//     'your_score': score.yourScore,
//     'opponent_score': score.opponentScore,
//     'you': user.email,
//     'created': FieldValue.serverTimestamp()
//   });
//
//   FirebaseFirestore.instance.collection("score_request").doc(id).update({'accepted': 'ACCEPTED'}).then((_) {
//     print("success!");
//   });
// }
//
// void _deleteRequest(String documentID) {
//   FirebaseFirestore.instance.collection("score_request").doc(documentID).update({'status': 'DELETED'}).then((_) {
//     print("success!");
//   });
// }
//
// class GameColumn extends StatelessWidget {
//   const GameColumn({
//     Key key,
//     this.score,
//   }) : super(key: key);
//   final Score score;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(score.opponent != null ? score.opponent : "Unknown ",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 20.0, // insert your font size here
//             )),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           //Center Row contents horizontally,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(score.yourScore.toString(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20.0, // insert your font size here
//                 )),
//             Text(' : ' + score.opponentScore.toString(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20.0, // insert your font size here
//                 )),
//           ],
//         ),
//         Text(score.date ?? '')
//       ],
//     );
//   }
// }
//
// String readTimestamp(DateTime timestamp) {
//   return DateFormat('dd:MM:yy').format(timestamp);
// }
