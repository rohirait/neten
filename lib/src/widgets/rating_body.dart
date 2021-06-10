import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netten/src/screens/add_game.dart';
import 'package:netten/src/models/Score.dart';

class RatingBody extends StatefulWidget {
  const RatingBody({Key key, @required this.user}) : super(key: key);

  @override
  _RatingBodyState createState() => _RatingBodyState();
  final User user;
}

class _RatingBodyState extends State<RatingBody> {
  Stream scores;
  @override
  void initState() {
    scores = Firestore.instance.collection('scores').where('you', isEqualTo: widget.user.email).snapshots();
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
        Expanded(
          child: StreamBuilder(
              stream: scores,
              builder: (context, snapshot) {
                if (snapshot.data == null) return LinearProgressIndicator();
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot opponent = snapshot.data.documents[index];
                      return Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF00A6FF).withOpacity(0.5) // Specifies the background color and the opacity
                        ),
                        margin: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 10.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
                          child: Dismissible(
                            key: UniqueKey(),
                            child: gameColumn(opponent),
                            onDismissed: (direction) async {
                              await Firestore.instance.runTransaction((Transaction myTransaction) async {
                                await myTransaction.delete(snapshot.data.documents[index].reference);
                              });
                            },
                          ),
                        ),
                      );
                    });
              }),
        )
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
      Expanded(
        child: StreamBuilder(
            stream: Firestore.instance.collection('scores').where('you', isEqualTo: user.email).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null) return LinearProgressIndicator();
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot opponent = snapshot.data.documents[index];
                    return Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF00A6FF).withOpacity(0.5) // Specifies the background color and the opacity
                          ),
                      margin: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
                        child: Dismissible(key: UniqueKey(), child: gameColumn(opponent), onDismissed: (direction) async{
                          await Firestore.instance.runTransaction((Transaction myTransaction) async {
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

Column gameColumn(DocumentSnapshot opponent) {
  return Column(
    children: [
      Text(opponent['opponent'] != null ? opponent['opponent'] : "Unknown ",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0, // insert your font size here
          )),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //Center Row contents horizontally,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(opponent['your_score'].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0, // insert your font size here
              )),
          Text(' : ' + opponent['opponent_score'].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0, // insert your font size here
              )),
        ],
      ),
      Text(opponent.data().containsKey('data') ? readTimestamp(opponent['data'].toDate()) : "")
    ],
  );
}

String readTimestamp(DateTime timestamp) {
  return DateFormat('dd:MM:yy kk:mm').format(timestamp);
}
