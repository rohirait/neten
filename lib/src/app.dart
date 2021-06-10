import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netten/src/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import '../login_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        title: 'Flutter Login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasData) {
                User user = FirebaseAuth.instance.currentUser;
                if(user != null)return MainPage(user);
                return LoginPage();
              }

              /// other way there is no user logged.
              return LoginPage();
            })
//      onGenerateRoute: routes,
        );
  }

  Future<Route> routes(RouteSettings settings) async {
    if (settings.name == '/') {
      return MaterialPageRoute(builder: (context) {
        return LoginPage();
      });
      // signed in
    } else {
      return MaterialPageRoute(builder: (context) {
        return LoginPage();
      });
    }
  }
}
