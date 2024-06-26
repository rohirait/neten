import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/providers/auth_provider.dart';
import 'package:netten/src/providers/client_provider.dart';
import 'package:netten/src/screens/friends/add_friend.dart';
import 'package:netten/src/screens/friends/search_friend_screen.dart';
import 'package:netten/src/screens/game/add_game.dart';
import 'package:netten/theme.dart';
import 'package:netten/src/widgets/avatar_widget.dart';
import 'package:netten/src/widgets/gradient_text.dart';
import 'package:netten/src/screens/settings/settings_screen.dart';
import 'package:netten/util.dart';
import '../../models/client.dart';
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
                    style: Theme.of(context).textTheme.displayMedium,
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
        Consumer(builder: (context, ref, child) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SettingsScreen(user: ref.read(authenticationProvider).getUser()!);
              }));
            },
            child: Column(
              children: [AvatarWidget(), Text('Settings')],
            ),
          );
        }),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
             Client? client = ref.read(clientProvider).value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LimitedBox(
                    maxWidth: 250,
                    child: Text("Welcome " + (client?.fullName?.capitalizeFirstLetterOfWords() ?? ref.read(authenticationProvider).getUser()?.displayName ?? ''),
                        style: Theme.of(context).textTheme.bodyLarge),
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
        //todo replace with friend request list
        ScoreRequestWidget(),
        FriendRequestWidget()
      ],
      2: [
        FriendsList(),
      ],
      1: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Text('Games', style: Theme.of(context).textTheme.bodyLarge),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'YOU    OPP.',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NetenColor.buttonColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
            ),
          );
  }

  void getButtonRoute(int index) {
    if(index == 2) {
       _showAddFriendDialog();
       return;
    }
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

  Future<void> _showAddFriendDialog( ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Set background color to transparent

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return AddFriendScreen();
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text('Add manually',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NetenColor.buttonColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return SearchFriendScreen();
                      }));

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text('Search for friend',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NetenColor.buttonColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

