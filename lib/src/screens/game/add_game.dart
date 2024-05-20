import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/src/providers/score_provider.dart';
import 'package:netten/src/widgets/gradient_text.dart';
import 'package:netten/theme.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/providers/auth_provider.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({Key? key, this.score}) : super(key: key);
  final Score? score;

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
  String? comment;

  final TextEditingController yourScoreController = TextEditingController();
  final TextEditingController opponentScoreController = TextEditingController();

  void initState() {
    if (widget.score != null) {
      yourGames = widget.score!.mySets ?? [];
      opponentGames = widget.score!.opponentSets ?? [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
        ),
        backgroundColor: NetenColor.backgroundColor,
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
                          style: Theme.of(context).textTheme.displayMedium,
                          gradient: LinearGradient(colors: [NetenColor.primaryColor, NetenColor.secondaryColor]))),
                  SizedBox(height: 8),
                  Text(widget.score != null ? 'Game' : 'Add game', style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () => widget.score != null ? null : _selectDate(context),
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
                                      style: Theme.of(context).textTheme.titleMedium),
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
                          return ref.watch(friendsStreamProvider).when(
                              data: (friends) {
                                return friends.isNotEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(Radius.circular(40)),
                                            border: Border.all(color: NetenColor.greyBorder)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: widget.score != null
                                              ? Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(widget.score?.opponent ?? ''),
                                                )
                                              : DropdownButton<Friend>(
                                                  hint: Text('Opponent'),
                                                  value: friend,
                                                  underline: SizedBox.shrink(),
                                                  onChanged: (value) {
                                                    friend = value;
                                                    setState(() {});
                                                  },
                                                  items: friends.map((friend) {
                                                    return DropdownMenuItem(
                                                      value: friend,
                                                      child: Text(
                                                        friend.name,
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
                  SizedBox(height: 15),
                  TextFormField(
                    enabled: widget.score == null,
                    initialValue: widget.score == null ? '' : widget.score?.comment ?? '',
                    maxLines: null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Comment',
                    ),
                    onChanged: (String? val){
                      comment = val;
                    },
                  ),
                  SizedBox(height: 8),
                  Text('Comments are only visible to you', style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 24),
                  Center(child: Text('SETS')),
                  if (widget.score != null) ...[Center(child: Text('Your scores are up and opponent scores are down'))],
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.score == null)
                              Row(children: [
                                SizedBox(width: 50, child: Text('YOU', style: Theme.of(context).textTheme.titleMedium)),
                                SizedBox(width: 14),
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
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 26),
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
                            if (widget.score == null)
                              Row(
                                children: [
                                  SizedBox(width: 90),
                                  Text((opponentGames.length + 1).toString(),
                                      style: Theme.of(context).textTheme.bodySmall)
                                ],
                              ),
                            SizedBox(height: 8),
                            if (widget.score == null)
                              Row(children: [
                                SizedBox(width: 50, child: Text('OPP.', style: Theme.of(context).textTheme.titleMedium)),
                                SizedBox(width: 14),
                                Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: NetenColor.lightGreyBorder), color: Colors.white),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                          controller: opponentScoreController,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 26),
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
                            thumbVisibility: true,
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
                                                  style: Theme.of(context).textTheme.bodyLarge),
                                            ]),
                                          ),
                                          SizedBox(height: 14),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: Row(
                                                children: [
                                                  Text(widget.score == null ? (yourGames.length - i).toString() : (i+1).toString(),
                                                      style: Theme.of(context).textTheme.bodySmall),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                              Text(opponentGames[i].toString(),
                                                  style: Theme.of(context).textTheme.bodyLarge),
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
                  if (widget.score == null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.copyWith(backgroundColor: WidgetStateProperty.all(Colors.white)),
                        onPressed: () {
                          if (yourScoreController.text.isNotEmpty && opponentScoreController.text.isNotEmpty) {
                            yourGames.add(int.parse(yourScoreController.text));
                            opponentGames.add(int.parse(opponentScoreController.text));
                            yourScoreController.clear();
                            opponentScoreController.clear();
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
                          child: Text('Add set',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: NetenColor.primaryColor)),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Consumer(
                      builder: (BuildContext context, WidgetRef ref, Widget? child) {
                        final User? user = ref.read(authenticationProvider).getUser();
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => saveMatch(user),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Save match',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NetenColor.buttonColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
                    foregroundColor: NetenColor.blackText, // button text color
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

  Future<void> saveMatch(User? user) async {
    if (opponentGames.isEmpty || user == null || friend == null) {
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
      }
    }
    Score score = Score(
        opponentEmail: friend?.email ?? '',
        yourScore: yourScore,
        opponentScore: opponentScore,
        date: 'x',
        uid: '',
        mySets: yourGames,
        opponentSets: opponentGames,
        opponent: friend?.name ?? '',
        comment: comment,
        friendId: friend?.id ?? '');
    createScore(date: selectedDate, score: score, user: user).then((value) => Navigator.of(context).pop());
  }
}
