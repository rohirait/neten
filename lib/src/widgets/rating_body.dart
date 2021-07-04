import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/screens/add_game.dart';

class RatingBody extends StatefulWidget {
  const RatingBody({Key key, @required this.user}) : super(key: key);

  @override
  _RatingBodyState createState() => _RatingBodyState();
  final User user;
}

class _RatingBodyState extends State<RatingBody> {
  Stream scores;
  User user;
  @override
  void initState() {
    scores = FirebaseFirestore.instance.collection('scores').where('you', isEqualTo: widget.user.email).orderBy('date', descending: true).snapshots();
    user = widget.user;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/raster.jpg"), fit: BoxFit.cover)),
      child:
      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: AppBar().preferredSize.height + 20),
        ButtonTheme(
          minWidth: 200,
          height: 60.0,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddGame()),
              );
            },
            child: Text("Add Game"),
          ),
        ),
        // Expanded(
        //   child: StreamBuilder(
        //       stream: scores,
        //       builder: (context, snapshot) {
        //         if (snapshot.data == null) return LinearProgressIndicator();
        //         return ListView.builder(
        //             padding: const EdgeInsets.all(8),
        //             shrinkWrap: true,
        //             itemCount: snapshot.data.documents.length,
        //             itemBuilder: (context, index) {
        //               DocumentSnapshot opponent = snapshot.data.documents[index];
        //               return Container(
        //                 decoration: new BoxDecoration(
        //                     color: Color(0xFF00A6FF).withOpacity(0.5) // Specifies the background color and the opacity
        //                 ),
        //                 margin: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 10.0),
        //                 child: Padding(
        //                   padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
        //                   child: Dismissible(
        //                     key: UniqueKey(),
        //                     child: GameColumn(opponent),
        //                     onDismissed: (direction) async {
        //                       await Firestore.instance.runTransaction((Transaction myTransaction) async {
        //                         await myTransaction.delete(snapshot.data.documents[index].reference);
        //                       });
        //                     },
        //                   ),
        //                 ),
        //               );
        //             });
        //       }),
        // )
      ]),
    );
  }
}

Widget ratingBody(BuildContext context, User user) {
  return Container(
    height: double.infinity,
    decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/raster.jpg"), fit: BoxFit.cover)),
    child:
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(height: AppBar().preferredSize.height + 20),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('score_request')
                  .where('you', isEqualTo: user.email)
                  .where('status', isEqualTo: "PENDING")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data == null)
                  return CircularProgressIndicator();
                else if (snapshot.data.documents.length > 0) {
                  return ListView.builder(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot friend =
                        snapshot.data.documents[index];
                        return Container(
                          decoration: new BoxDecoration(
                              color: Color(0xFF00A6FF).withOpacity(
                                  0.5) // Specifies the background color and the opacity
                          ),
                          margin: EdgeInsets.only(right: 20.0, left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                    left: 8.0,
                                    right: 8.0),
                                child: Text("Score submit by: "+friend['opponent'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                      20.0, // insert your font size here
                                    )),
                              ),
                              Text(friend['your_score'].toString()+' : '+friend['opponent_score'].toString()),
                              Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ButtonTheme(
                                      buttonColor: Colors.green,
                                      height: 60.0,
                                      child: RaisedButton(
                                        color: Colors.green,
                                        onPressed: () async {
                                          Score score = Score(opponentScore: friend['opponent_score'], opponent: friend['opponent'],
                                              yourScore: friend['your_score'],date:friend['date'].toDate().toString());
                                          addScore(score, user, friend.id);
                                        },
                                        child: Text("Add"),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ButtonTheme(
                                      height: 60.0,
                                      child: RaisedButton(
                                        color: Colors.red,
                                        onPressed: () async {
                                          _deleteRequest(friend.documentID);
                                        },
                                        child: Text("Delete"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      });
                }
                return Visibility(
                  child: Text("Gone"),
                  visible: false,
                );
              }),
      Expanded(
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('scores').where('you', isEqualTo: user.email).orderBy('date', descending: true).get(),
            builder: (context, snapshot) {
              if (snapshot.data == null) return LinearProgressIndicator();
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    // DocumentSnapshot opponent = snapshot;
                    Score score = Score.fromSnapshot(snapshot.data.documents[index]);
                    return Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF00A6FF).withOpacity(0.5) // Specifies the background color and the opacity
                          ),
                      margin: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
                        child: Dismissible(key: UniqueKey(), child: GameColumn(score: score), onDismissed: (direction) async{
                          await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                            await myTransaction.delete(snapshot.data.documents[index].reference);
                          });
                        },),
                      ),
                    );
                  });
            }),
      )
    ]),
  );
}

void addScore(Score score, User user, String id) async {

 await FirebaseFirestore.instance.collection("scores").add({
    'date': DateTime.parse(score.date),
    'opponent': score.opponent,
    'your_score': score.yourScore,
    'opponent_score': score.opponentScore,
    'you': user.email,
    'created': FieldValue.serverTimestamp()
  });

 FirebaseFirestore.instance.collection("score_request")
     .document(id)
     .updateData({'status': 'ACCEPTED'}).then((_) {
   print("success!");
 });

}

void _deleteRequest(String documentID) {
  FirebaseFirestore.instance
      .collection("score_request")
      .document(documentID)
      .updateData({'status': 'DELETED'}).then((_) {
    print("success!");
  });
}



class GameColumn extends StatelessWidget {
  const GameColumn({
    Key key, this.score,
  }) : super(key: key);
  final Score score;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(score.opponent != null ? score.opponent : "Unknown ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0, // insert your font size here
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(score.yourScore.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0, // insert your font size here
                )),
            Text(' : ' + score.opponentScore.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0, // insert your font size here
                )),
          ],
        ),
        Text(score.date ?? '')
      ],
    );
  }
}

String readTimestamp(DateTime timestamp) {
  return DateFormat('dd:MM:yy').format(timestamp);
}
