// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:netten/src/models/friend.dart';
// import 'package:netten/src/models/score.dart';
// import 'package:netten/src/screens/add_friends.dart';
// import 'package:netten/src/widgets/rating_body.dart';
//
// import 'add_game.dart';
//
// class FriendScreen extends StatefulWidget {
//   final Friend friend;
//
//   FriendScreen({Key key, @required this.friend}) : super(key: key);
//
//   FriendScreenState createState() => FriendScreenState();
// }
//
// class FriendScreenState extends State<FriendScreen> {
//   final formKey = GlobalKey<FormState>();
//   User user;
//   String _name = '';
//   String _email = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     _name = widget.friend.name;
//     _email = widget.friend.email;
//   }
//
//   void _loadCurrentUser() {
//     this.user = FirebaseAuth.instance.currentUser;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             extendBodyBehindAppBar: true,
//             resizeToAvoidBottomInset: false,
//             appBar: new AppBar(
//                 backgroundColor: Colors.transparent,
//                 automaticallyImplyLeading: true,
//                 leading: IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () => Navigator.pop(context, false),
//                 )),
//             body: new Container(
//                 decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: AssetImage("assets/raster.jpg"),
//                         fit: BoxFit.cover)),
//                 child: Container(
//                     margin: new EdgeInsets.all(15.0),
//                     child: Form(
//                         key: formKey,
//                         child: Column(children: [
//                           SizedBox(height: AppBar().preferredSize.height + 20),
//                           friendNameField(widget.friend.name),
//                           emailField(widget.friend.email),
//                           Container(margin: EdgeInsets.only(top: 25.0)),
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Spacer(),
//                                 deleteButton(context),
//                                 Spacer(),
//                                 addGame(context, widget.friend),
//                                 Spacer(),
//                                 saveButton(),
//                                 Spacer(),
//
//                               ]),
//                           Expanded(
//                              child: gamesList(user.email, widget.friend.name, widget.friend.email)
//                           )
//                         ]))))));
//   }
//   Widget gamesList(String email, String name, String friendEmail){
//     return StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('scores')
//             .where('you', isEqualTo: email)
//             .where("opponent", whereIn: [name, friendEmail]).orderBy('date', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.data == null) return Text('Loading...');
//           return ListView.builder(
//               scrollDirection: Axis.vertical,
//               padding: const EdgeInsets.all(8),
//               shrinkWrap: true,
//               itemCount: snapshot.data.docs.length,
//               itemBuilder: (context, index) {
//                 DocumentSnapshot game = snapshot.data.docs[index];
//                 Score score = Score.fromSnapshot(snapshot.data.docs[index]);
//                 return Container(
//                   decoration: new BoxDecoration(
//                       color: Color(0xFF00A6FF).withOpacity(
//                           0.5) // Specifies the background color and the opacity
//                   ),
//                   margin: const EdgeInsets.only(
//                       left: 80.0, right: 80.0, bottom: 10.0),
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                         top: 10.0,
//                         bottom: 10.0,
//                         left: 8.0,
//                         right: 8.0),
//                     child: GameColumn(score:score)
//                   ),
//                 );
//               });
//         });
//   }
//   Widget friendNameField(String name) {
//     return Opacity(
//       opacity: 0.5,
//       child: Container(
//         color: Color(0xFF00A6FF),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextFormField(
//                   initialValue: name,
//                   style: TextStyle(
//                     fontSize: 20.0,
//                   ),
//                   onSaved: (String val) {
//                     _name = val;
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget emailField(String email) {
//     return Opacity(
//       opacity: 0.5,
//       child: Container(
//         color: Color(0xFF00A6FF),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextFormField(
//                   initialValue: email,
//                   onSaved: (String val) {
//                     _email = val;
//                   },
//                   keyboardType: TextInputType.emailAddress,
//                   style: TextStyle(
//                     fontSize: 20.0,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget deleteButton(context) {
//     return ElevatedButton(
//         onPressed: () {
//           showAlertDialog(context);
//         },
//         child: Text("Delete"));
//   }
//
//   Widget addGame(context, Friend friend) {
//     return ElevatedButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => AddGame(name: friend)),
//           );
//         },
//         child: Text("Add Game"));
//   }
//
//   Widget saveButton() {
//     return ElevatedButton(
//         onPressed: () {
//           formKey.currentState.save();
//           saveJob(widget.friend.uid);
//         },
//         child: Text("Save"));
//   }
//
//   showAlertDialog(BuildContext context) {
//     String name = widget.friend.name;
//     // set up the buttons
//     Widget cancelButton = FlatButton(
//       child: Text("Cancel"),
//       onPressed: () {
//         Navigator.of(context, rootNavigator: true).pop();
//       },
//     );
//     Widget continueButton = FlatButton(
//       child: Text("Delete"),
//       onPressed: () {
//         rejectJob(widget.friend.uid);
//         Navigator.of(context, rootNavigator: true).pop();
//         Navigator.pop(context);
//       },
//     );
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("Delete friend"),
//       content: Text("Are you sure you want to delete $name from your friends?"),
//       actions: [
//         cancelButton,
//         continueButton,
//       ],
//     );
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   Future<void> rejectJob(String jobId) {
//     return FirebaseFirestore.instance.collection('friends').doc(jobId).delete();
//   }
//
//    getFriendGames(){
//     return FirebaseFirestore.instance
//         .collection('scores')
//         .where('you', isEqualTo: user.email)
//         .where("opponent", arrayContainsAny: [_name, _email]).orderBy('date', descending: true)
//         .snapshots();
//   }
//
//   Future<void> saveJob(String jobId) {
//     return FirebaseFirestore.instance
//         .collection('friends')
//         .doc(jobId)
//         .update({'friend_email': _email, 'friend_name': _name}).then(
//       (value) => Navigator.pop(this.context, false),
//     );
//   }
// }
