import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:netten/src/widgets/fab/friendsFloat.dart';
import 'package:netten/src/widgets/fab/rating.dart';
import 'package:netten/src/widgets/friends_body.dart';
import 'package:netten/src/widgets/home_body.dart';
import 'package:netten/src/widgets/rating_body.dart';
//todo remove user from widgets and use streams
class MainPage extends StatefulWidget {
  final User user;

  MainPage(this.user);

  MainPageState createState() => MainPageState(user);
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  MainPageState(this.user);

  final User user;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      buildBody(context, user),
      ratingBody(context, user),
      friendBody(context, user),
    ];

    final List<FloatingActionButton> buttons = [
      null,
      ratingFloat(context ),
      friendFloat(context),
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          new BottomNavigationBarItem(icon: Icon(Icons.sports_tennis_sharp), label: 'Games'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Friends')
        ],
      ),
      floatingActionButton: buttons[_currentIndex],
    );
  }
}
