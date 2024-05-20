import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:netten/auth_widget.dart';
import 'package:netten/src/providers/client_provider.dart';
import 'package:netten/src/screens/home/home_screen.dart';
import 'package:netten/src/screens/onboarding/basic_data_screen.dart';
import 'package:netten/src/screens/onboarding/sign_in.dart';
import 'package:netten/src/services/shared_preference_service.dart';
import 'package:netten/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: NetenTheme,
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => Consumer(
          builder: (context, ref, _) {
            return SignIn();
          },
        ),
        signedInBuilder: (_) {
          final client = ref.watch(clientProvider);
          if(client.isLoading)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (client.value?.firstName != null && client.value?.lastName != null) {
            return HomeScreen();
          } else {
            // Handle the case where either firstName or lastName is null.
            // You can return a different widget or show an error message.
            return BasicDataScreen(userId: client.value!.uid!);
          }
        },

      ),
    );
  }
}


