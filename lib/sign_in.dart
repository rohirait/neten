import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User> signInWithGoogle() async {
  // final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  // final GoogleSignInAuthentication googleSignInAuthentication =
  //     await googleSignInAccount.authentication;
  //
  // final AuthCredential credential = GoogleAuthProvider.getCredential(
  //   accessToken: googleSignInAuthentication.accessToken,
  //   idToken: googleSignInAuthentication.idToken,
  // );
  //
  // final AuthResult authResult = await _auth.signInWithCredential(credential);
  // final User user = authResult.user;
  // Firestore.instance.collection('users').document(user.uid).setData(
  //     {'firstName': user.displayName, 'email': user.email, 'uid': user.uid, 'url':user.photoUrl});
  // assert(!user.isAnonymous);
  // assert(await user.getIdToken() != null);
  //
  // final User currentUser =  _auth.currentUser;
  // assert(user.uid == currentUser.uid);
  //
  // return currentUser;
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    idToken: googleSignInAuthentication.idToken,
    accessToken: googleSignInAuthentication.accessToken,
  );

  User user = (await auth.signInWithCredential(credential)).user;

  FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'firstName': user.displayName, 'email': user.email, 'uid': user.uid, 'url':user.photoURL});
  return user;
}

void signOutGoogle() async {
  await googleSignIn.signOut();

}

void signOut() async {
  await googleSignIn.signOut();
  await auth.signOut();

}
