import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/screens/add_friends.dart';
import 'package:netten/src/screens/friend_screen.dart';

Widget friendBody(BuildContext context, User user) {
  final databaseReference = Firestore.instance;
  Future _addFriend(index, name, email) async {
    DocumentReference ref = await databaseReference.collection("friends").add({
      'email': user.email,
      'friend_email': email,
      'friend_name': name,
      'uid': user.uid
    });

    databaseReference.collection("friend_request")
          .document(index)
          .updateData({'status': 'ACCEPTED'}).then((_) {
        print("success!");
      });
  }

  void _deleteRequest(String documentID) {
    databaseReference
      ..collection("friend_request")
          .document(documentID)
          .updateData({'status': 'DELETED'}).then((_) {
        print("success!");
      });
  }

  return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/raster.jpg"), fit: BoxFit.cover)),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppBar().preferredSize.height + 20),
            StreamBuilder(
                stream: Firestore.instance
                    .collection('friend_request')
                    .where('recipient_email', isEqualTo: user.email)
                    .where('status', isEqualTo: "PENDING")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data == null)
                    return CircularProgressIndicator();
                  else if (snapshot.data.documents.length > 0) {
                    return Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0,
                                        bottom: 4.0,
                                        left: 8.0,
                                        right: 8.0),
                                    child: Text(friend['sender_name'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:
                                              20.0, // insert your font size here
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ButtonTheme(
                                      buttonColor: Colors.green,
                                      height: 60.0,
                                      child: RaisedButton(
                                        color: Colors.green,
                                        onPressed: () async {
                                          _addFriend(
                                              friend.id,
                                              friend['sender_name'],
                                              friend['email']);
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
                            );
                          }),
                    );
                  }
                  return Visibility(
                    child: Text("Gone"),
                    visible: false,
                  );
                }),
            Expanded(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('friends')
                      .where('email', isEqualTo: user.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return new CircularProgressIndicator();
                    return Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot friend =
                                snapshot.data.documents[index];
                            return ElevatedButton(
                              onPressed: () {
                                Friend clicked = new Friend(
                                    name: friend['friend_name'],
                                    email: friend['friend_email'],
                                    uid: friend.id);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FriendScreen(friend: clicked),
                                    ));
                              },
                              child: Text(
                                friend['friend_name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.0, // insert your font size here
                                ),
                              ),
                            );
                          }),
                    );
                  }),
            ),
          ],
        ),
      ));
}
