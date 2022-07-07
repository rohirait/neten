import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:netten/src/providers/score_provider.dart';
import 'package:netten/src/widgets/gradient_text.dart';
import 'package:netten/theme.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/providers/auth_provider.dart';

class AddGameScreen extends StatefulWidget {
  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}
//todo Rait refactor by a lot
class _AddGameScreenState extends State<AddGameScreen> {
  final _scrollController = ScrollController();

  DateTime selectedDate = DateTime.now();
  Friend? friend;
  List<int> yourGames = <int>[];
  List<int> opponentGames = <int>[];

  final TextEditingController yourScoreController = TextEditingController();
  final TextEditingController opponentScoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NetenColor.backgroundColor,
        bottomNavigationBar: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final String? email = ref.read(authenticationProvider).getUser()?.email;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => saveMatch(email ?? ''),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:
                      Text('Save match', style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white)),
                ),
                style: ElevatedButton.styleFrom(
                  primary: NetenColor.buttonColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
            );
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                      child: GradientText("NeteN",
                          style: Theme.of(context).textTheme.headline2,
                          gradient: LinearGradient(colors: [NetenColor.primaryColor, NetenColor.secondaryColor]))),
                  SizedBox(height: 8),
                  Text('Add game', style: Theme.of(context).textTheme.bodyText1),
                  SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                border: Border.all(color: NetenColor.greyBorder)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('dd.MM.yyyy').format(selectedDate),
                                      style: Theme.of(context).textTheme.subtitle1),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            )),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Consumer(
                        builder: (BuildContext context, WidgetRef ref, Widget? child) {
                          return ref.watch(friendsProvider).when(
                              data: (friends) {
                                return friends!.isNotEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(Radius.circular(40)),
                                            border: Border.all(color: NetenColor.greyBorder)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: DropdownButton<Friend>(
                                              hint: Text('Opponent'),
                                              value: friend,
                                              underline: SizedBox.shrink(),
                                              onChanged: (value) {
                                                print(value?.name ?? ' TEst');
                                                friend = value;
                                                setState(() {});
                                              },
                                              items: friends.map((friend) {
                                                return DropdownMenuItem(
                                                  value: friend,
                                                  child: Text(
                                                    friend?.name ?? '',
                                                  ),
                                                );
                                              }).toList()),
                                        ))
                                    : SizedBox.shrink();
                              },
                              error: (error, stack) => Text('oops'),
                              loading: () => const CircularProgressIndicator());
                        },
                      ),
                    )
                  ]),
                  SizedBox(height: 24),
                  Center(child: Text('SETS')),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              SizedBox(width: 50, child: Text('YOU', style: Theme.of(context).textTheme.subtitle1)),
                              SizedBox(width: 20),
                              Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: NetenColor.lightGreyBorder),
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                        controller: yourScoreController,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 26),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(2),
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        ]),
                                  ))
                            ]),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(width: 90),
                                Text((opponentGames.length + 1).toString(), style: Theme.of(context).textTheme.caption)
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(children: [
                              SizedBox(width: 50, child: Text('OPP.', style: Theme.of(context).textTheme.subtitle1)),
                              SizedBox(width: 20),
                              Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: NetenColor.lightGreyBorder), color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                        controller: opponentScoreController,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 26),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(2),
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        ]),
                                  ))
                            ]),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Scrollbar(
                            isAlwaysShown: true,
                            controller: _scrollController,
                            trackVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < yourGames.length; i++) ...[
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                              Text(yourGames[i].toString(),
                                                  style: Theme.of(context).textTheme.bodyText1),
                                            ]),
                                          ),
                                          SizedBox(height: 14),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: Row(
                                                children: [
                                                  Text((yourGames.length - i).toString(),
                                                      style: Theme.of(context).textTheme.caption),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                              Text(opponentGames[i].toString(),
                                                  style: Theme.of(context).textTheme.bodyText1),
                                            ]),
                                          ),
                                          SizedBox(height: 24),
                                        ]),
                                    SizedBox(width: 22)
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: Theme.of(context)
                          .elevatedButtonTheme
                          .style
                          ?.copyWith(backgroundColor: MaterialStateProperty.all(Colors.white)),
                      onPressed: () {
                        if (yourScoreController.text.isNotEmpty && opponentScoreController.text.isNotEmpty) {
                          yourGames.add(int.parse(yourScoreController.text));
                          opponentGames.add(int.parse(opponentScoreController.text));
                          yourScoreController.clear();
                          opponentScoreController.clear();
                          print(yourGames.toString());
                          print(opponentGames.toString());
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Missing a score'),
                            duration: const Duration(seconds: 1),
                          ));
                          setState(() {});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Add game',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: NetenColor.primaryColor)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: NetenColor.primaryColor, // header background color
                  onPrimary: NetenColor.blackText, // header text color
                  onSurface: NetenColor.primaryColor, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: NetenColor.blackText, // button text color
                  ),
                )),
            child: child!,
          );
        });
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveMatch(String? email) async {
    if (opponentGames.isEmpty || email == null || friend == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(friend == null ? "Missing opponent" : "Add at least one match"),
        duration: const Duration(seconds: 1),
      ));
      return;
    }
    int yourScore = 0;
    int opponentScore = 0;
    for (int i = 0; i < opponentGames.length; i++) {
      if (opponentGames[i] > yourGames[i]) {
        opponentScore++;
      } else if (opponentGames[i] < yourGames[i]) {
        yourScore++;
      } else {
        yourScore++;
        opponentScore++;
      }
    }
    Score score = Score(
      opponentEmail: friend?.email ?? '',
      yourScore: yourScore,
      opponentScore: opponentScore,
      date: 'x',
      uid: '',
      opponent: friend?.name ?? '',
    );
    createScore(date: selectedDate, score: score, yourEmail: email).then((value) => Navigator.of(context).pop());
  }
}
