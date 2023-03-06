import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:netten/src/services/firestore_database.dart';
import 'package:riverpod/riverpod.dart';

final firebaseAuthProvider =
Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider.autoDispose<User?>(
        (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider.autoDispose<FirestoreDatabase?>((ref) {
  final auth = ref.watch(authStateChangesProvider);

  if (auth.asData?.value?.uid != null) {
    return FirestoreDatabase(uid: auth.asData!.value!.uid);
  }
  return null;
});

