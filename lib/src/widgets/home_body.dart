// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:netten/src/models/score.dart';
// import 'package:netten/src/screens/add_game.dart';
// import 'package:netten/src/screens/rating_screen.dart';
// import 'package:netten/sign_in.dart';
// import 'package:netten/src/widgets/rating_body.dart';
//
// import '../../login_page.dart';
//
// Widget buildBody(BuildContext context, User user) {
//   return SafeArea(
//       child: Container(
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//             image: DecorationImage(
//                 image: AssetImage("assets/raster.jpg"), fit: BoxFit.cover)),
//         child: Column(
//           children: [Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: CircleAvatar(
//                     radius: 60.0,
//                     backgroundColor: Colors.brown.shade800,
//                     backgroundImage: NetworkImage(user.photoURL),
//                   ),
//                 ),
//               ),
//               SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: ButtonTheme(
//                           minWidth: 200,
//                           height: 60.0,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => AddGame()),
//                               );
//                             },
//                             child: Text("Add Game"),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           ButtonTheme(
//             minWidth: 300,
//             height: 60.0,
//             child: ElevatedButton(
//               onPressed: () {
//                signOut();
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(builder: (context) => LoginPage()),
//                );
//               },
//               child: Text("Log out"),
//             ),
//           ),
//              Expanded(
//                child: Container(
//            child: StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('scores')
//                       .where('you', isEqualTo: user.email).orderBy('date', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.data == null) return CircularProgressIndicator();
//                     return ListView.builder(
//                         padding: const EdgeInsets.all(8),
//                         shrinkWrap: true,
//                         itemCount: snapshot.data.docs.length,
//                         itemBuilder: (context, index) {
//                           Score score = Score.fromSnapshot(snapshot.data.docs[index]);
//                           return Container(
//                             decoration: new BoxDecoration(
//                                 color: Color(0xFF00A6FF).withOpacity(
//                                     0.5) // Specifies the background color and the opacity
//                             ),
//                             margin: const EdgeInsets.only(
//                                 left: 80.0,
//                                 right: 80.0,
//                                 bottom: 10.0),
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 10.0,
//                                   bottom: 10.0,
//                                   left: 8.0,
//                                   right: 8.0),
//                               child: GameColumn(score: score)
//                             ),
//                           );
//                         });
//                   }),
//                ),
//              )],
//         ),
//       ));
// }