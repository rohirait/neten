// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:netten/src/screens/add_game.dart';
// import 'package:netten/src/widgets/app_bar.dart';
//
// class RatingsStateful extends StatefulWidget {
//   RatingScreen createState() => RatingScreen();
// }
//
// class RatingScreen extends State<RatingsStateful> {
//   FirebaseFirestore db;
//   User user;
//   final databaseReference = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//   }
//
//   void _loadCurrentUser() {
//     this.user = auth.currentUser;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           extendBodyBehindAppBar: true,
//           appBar: appBar(context, 'Rating'),
//           body: Container(
//             height: double.infinity,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage("assets/raster.jpg"),
//                       fit: BoxFit.cover)),
//               child: SingleChildScrollView(
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       SizedBox(height: AppBar().preferredSize.height + 20),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ButtonTheme(
//                           minWidth: 200,
//                           height: 60.0,
//                           child: RaisedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => AddGame()),
//                               );
//                             },
//                             child: Text("Add Game"),
//                           ),
//                         ),
//                       ),
//                       user != null
//                           ? StreamBuilder(
//                               stream: FirebaseFirestore.instance
//                                   .collection('scores')
//                                   .where('you', isEqualTo: user.email).orderBy('scores', descending: true)
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.data == null) return Text('Loading...');
//                                 return ListView.builder(
//                                     padding: const EdgeInsets.all(8),
//                                     shrinkWrap: true,
//                                     itemCount: snapshot.data.documents.length,
//                                     itemBuilder: (context, index) {
//                                       DocumentSnapshot test =
//                                           snapshot.data.documents[index];
//                                       return Container(
//                                         decoration: new BoxDecoration(
//                                             color: Color(0xFF00A6FF).withOpacity(
//                                                 0.5) // Specifies the background color and the opacity
//                                             ),
//                                         margin: const EdgeInsets.only(
//                                             left: 80.0,
//                                             right: 80.0,
//                                             bottom: 10.0),
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               top: 10.0,
//                                               bottom: 10.0,
//                                               left: 8.0,
//                                               right: 8.0),
//                                           child: Column(
//                                             children: [
//                                               Text(
//                                                   test['opponent'] != null
//                                                       ? test['opponent']
//                                                       : "Unknown ",
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     fontSize:
//                                                         20.0, // insert your font size here
//                                                   )),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 //Center Row contents horizontally,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                       test['your_score']
//                                                           .toString(),
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             20.0, // insert your font size here
//                                                       )),
//                                                   Text(
//                                                       ' : ' +
//                                                           test['opponent_score']
//                                                               .toString(),
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             20.0, // insert your font size here
//                                                       )),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     });
//                               })
//                           : Container(
//                           child:Text('Loading...')),
//                     ]),
//               ))),
//     );
//   }
// }
