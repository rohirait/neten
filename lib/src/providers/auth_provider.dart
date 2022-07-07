import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:netten/src/models/authentication.dart';


final authenticationProvider = Provider<Authentication>((ref) {
  return Authentication();
});


final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});



