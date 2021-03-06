import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/providers/auth_provider.dart';
import 'package:netten/src/providers/score_provider.dart';
import 'package:netten/src/screens/friends/add_friend.dart';
import 'package:netten/src/screens/game/add_game.dart';

import 'package:netten/theme.dart';
import '../../widgets/gradient_text.dart';
import 'friends_list.dart';
import 'games_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetenColor.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
                child: GradientText("NeteN",
                    style: Theme.of(context).textTheme.headline2,
                    gradient: LinearGradient(colors: [NetenColor.primaryColor, NetenColor.secondaryColor]))),
            ...getBody(_selectedIndex),
            SizedBox(height: 8),
            getBottomButton(_selectedIndex)
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        unselectedItemColor: NetenColor.iconColor,
        selectedItemColor: NetenColor.primaryColor,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> getBody(int index) {
    Map<int, List<Widget>> widgets = {
      0: [
        Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return ref.read(authenticationProvider).getUser()?.photoURL != null
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(ref.read(authenticationProvider).getUser()!.photoURL!),
                  ),
                )
              : SizedBox.shrink();
        }),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LimitedBox(
                    maxWidth: 250,
                    child: Text("Welcome " + (ref.read(authenticationProvider).getUser()?.displayName ?? ''),
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                        onPressed: () {
                          ref.watch(authenticationProvider).signOut();
                        },
                        child: Icon(Icons.power_settings_new, color: NetenColor.greyText)),
                  ),
                ],
              ),
            );
          },
        ),
        GamesList()
      ],
      2: [
        FriendsList(),
      ],
      1: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Text('Games', style: Theme.of(context).textTheme.bodyText1),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'YOU    OPP.',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ],
          ),
        ),
        GamesList()
      ]
    };
    if (widgets[index] != null) {
      return widgets[index]!;
    } else
      return widgets[0]!;
  }

  Widget getBottomButton(int index) {
    return index == 0
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  getButtonRoute(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    index == 2 ? 'Add friend' : 'Add game',
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: NetenColor.buttonColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
            ),
          );
  }

  void getButtonRoute(int index) {
    Map<int, Widget> routes = {
      0: Text("Test"),
      1: AddGameScreen(),
      2: AddFriendScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      if (routes[index] != null) {
        return routes[index]!;
      }
      return routes[0]!;
    }));
  }
}
