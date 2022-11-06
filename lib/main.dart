import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:netten/auth_widget.dart';
import 'package:netten/src/screens/home/home_screen.dart';
import 'package:netten/src/screens/onboarding/sign_in.dart';
import 'package:netten/src/services/shared_preference_service.dart';
import 'package:netten/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
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
        signedInBuilder: (_) => HomeScreen(),
      ),
    );
  }
}



//TODO remove old code
// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//
//     return MaterialApp(
//         title: 'Flutter Login',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: FutureBuilder(
//             future: Firebase.initializeApp(),
//             builder: (BuildContext context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               }
//               if (snapshot.hasData) {
//                 User user = FirebaseAuth.instance.currentUser;
//                 if(user != null)return MainPage(user);
//                 return LoginPage();
//               }
//
//               /// other way there is no user logged.
//               return LoginPage();
//             })
// //      onGenerateRoute: routes,
//         );
//   }
//
//   Future<Route> routes(RouteSettings settings) async {
//     if (settings.name == '/') {
//       return MaterialPageRoute(builder: (context) {
//         return LoginPage();
//       });
//       // signed in
//     } else {
//       return MaterialPageRoute(builder: (context) {
//         return LoginPage();
//       });
//     }
//   }
// }
