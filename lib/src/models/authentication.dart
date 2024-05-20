import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Authentication {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error Occured'),
          content: Text(e.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("OK"))
          ],
        ),
      );
    }
  }

  // SignUp the user using Email and Password
  Future<void> signUpWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(title: Text('Error Occured'), content: Text(e.toString()), actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("OK"))
              ]));
    } catch (e) {
      if (e == 'email-already-in-use') {
        print('Email already in use.');
      } else {
        print('Error: $e');
      }
    }
  }

  //  SignIn the user Google
  Future<void> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      User? user = (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        updateOrSetUser(user);
      }
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error Occured'),
          content: Text(e.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("OK"))
          ],
        ),
      );
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential credential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    try {
      User? user = (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        updateOrSetUser(user);
      }
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error Occured'),
          content: Text(e.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("OK"))
          ],
        ),
      );
    }
  }

  void updateOrSetUser(User user, {String? firstName, String? lastName}) {
    FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {'lastLogin': DateTime.now(),
            if(firstName != null) 'firstName':firstName,
            if(lastName != null) 'lastName':lastName,
            if(firstName != null && lastName != null) 'displayName':firstName+' '+lastName
          },
        );
        FirebaseFirestore.instance.collection('users').doc(user.uid).collection('myFriends');
        FirebaseFirestore.instance.collection('users').doc(user.uid).collection('myScores');
      } else {
        // The document doesn't exist, create it
        FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'name': user.displayName,
            'email': user.email,
            'uid': user.uid,
            'created': DateTime.now(),
            if(firstName != null) 'firstName': firstName,
            if(lastName != null) 'lastName': lastName,
            if(firstName != null && lastName != null) 'displayName':firstName+' '+lastName

          },
        ).then((_) {

        }).catchError((error) {
          // Handle errors, e.g., if there's a problem with Firestore
          print('Error: $error');
        });
      }
    }).catchError((error) {
      // Handle errors when fetching the document
      print('Error: $error');
    });
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple(BuildContext context) async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    String? firstName = appleCredential.givenName;
    String? lastName = appleCredential.familyName;
    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    try {
      User? user = (await _auth.signInWithCredential(oauthCredential)).user;
      if (user != null) updateOrSetUser(user, firstName: firstName, lastName: lastName);
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error Occured'),
          content: Text(e.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("OK"))
          ],
        ),
      );
    }
  }

  //  SignOut the current user
  Future<void> signOut() async {
    try {
      await GoogleSignIn().isSignedIn().then((value) async {
        if (value) await GoogleSignIn().disconnect();
      });
    } catch (error) {
      print(error);
    }
    await _auth.signOut();
  }

  User? getUser() {
    return _auth.currentUser;
  }

}
