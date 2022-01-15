import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/widgets/app_bar.dart';
import 'dart:math';

class AddGame extends StatefulWidget {
  final Friend name;
  final TextEditingController yourScoreController = TextEditingController();
  final TextEditingController opponentScoreController = TextEditingController();

  AddGame({
    Key key,
    this.name,
  }) : super(key: key);

  Add createState() => Add();
}

class Add extends State<AddGame> {
  final df = new DateFormat('dd-MM-yyyy');
  DateTime selectedDate = DateTime.now();
  int yourScore = 0;
  int opponentScore = 0;
  String userEmail;
  final databaseReference = FirebaseFirestore.instance;
  User user;
  var dropdownValue;
  List<int> yourGames = <int>[];
  List<int> opponentGames = <int>[];
  List<Widget> _phoneWidgets = <Widget>[];
  int sets = 0;
  String currentSetsString = "0 : 0";
  TextEditingController opponentScoreController;
  TextEditingController yourScoreController;
  bool selected = false;
  List<DropdownMenuItem<Friend>> friends = [];

  void addNewField() {
    yourScoreController.clear();
    opponentScoreController.clear();
    sets++;
    if (yourGames.last > opponentGames.last)
      yourScore++;
    else if (opponentGames.last > yourGames.last)
      opponentScore++;
    else {
      opponentScore++;
      yourScore++;
    }
    Widget scoreRow = Container(
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              (max(yourGames.length, opponentGames.length)).toString() + '. ',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          Text(
            yourGames.last.toString() + " : " + opponentGames.last.toString(),
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
    _phoneWidgets.add(scoreRow);
    currentSetsString = yourScore.toString() + " : " + opponentScore.toString();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this.dropdownValue = widget.name ?? null;
    this.opponentScoreController = widget.opponentScoreController;
    this.yourScoreController = widget.yourScoreController;
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    this.user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: appBar(context, 'Add game'),
          body: Stack(children: <Widget>[
            Container(
                height: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/raster.jpg"),
                        fit: BoxFit.cover)),
                child: new SingleChildScrollView(
                  child: user != null
                      ? Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: FormUI(_width),
                        )
                      : Text('Loading...'),
                )),
          ])),
    );
  }

  Widget FormUI(double width) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          margin: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: AppBar().preferredSize.height + 20),
              dateRow(),
              buildOpponentDropdown(),
              SizedBox(height: 10),
              buildSets(),
              SizedBox(height: 10),
              Container(
                color: Color(0xFF00A6FF).withOpacity(0.5),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Games: ',
                            style: TextStyle(
                              fontSize: 20.0, // insert your font size here
                            )),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('You',
                              style: TextStyle(
                                fontSize: 16.0, // insert your font size here
                              )),
                          Text('Opponent',
                              style: TextStyle(
                                fontSize: 16.0, // insert your font size here
                              )),
                        ]),
                    Column(
                      children: List.generate(_phoneWidgets.length, (i) {
                        return _phoneWidgets[i];
                      }),
                    ),
                    buildGame(),
                    ElevatedButton(
                      onPressed: () {
                        if (yourScoreController.text != '' &&
                            opponentScoreController.text != '') {
                          addNewField();
                        }
                      },
                      child: Text('Add game'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonTheme(
                  minWidth: 200,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: _validateInputs,
                    child: Text('Save match'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGame() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Text((max(yourGames.length, opponentGames.length) + 1).toString(),
                style: TextStyle(
                  fontSize: 16.0, // insert your font size here
                )),
      ),
      SizedBox(
        width: 50,
        child: new TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          controller: yourScoreController,
          onSubmitted: (String value) {
            addGameValues(true, value);
          },
        ),
      ),
      Text(' : ',
          style: TextStyle(
            fontSize: 16.0, // insert your font size here
          )),
      SizedBox(
        width: 50,
        child: new TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          controller: opponentScoreController,
          onSubmitted: (String value) {
            addGameValues(false, value);
          },
          onChanged: (String value) {
            addGameValues(false, value);
          },
        ),
      ),
    ]);
  }

  void addGameValues(bool isYourScore, String value) {
    List<int> games = isYourScore ? yourGames : opponentGames;
    List<int> otherGames = isYourScore ? opponentGames : yourGames;
    TextEditingController controller =
        isYourScore ? opponentScoreController : yourScoreController;

    if (games.length <= sets) {
      games.add(int.parse(value));
    } else {
      games[sets] = int.parse(value);
    }

    if (otherGames.length <= sets && controller.text != "") {
      otherGames.add(int.parse(controller.text));
    }

    // if (yourGames.length == opponentGames.length) {
    //   yourScoreController.clear();
    //   opponentScoreController.clear();
    // }
  }

  Widget buildSets() {
    return Container(
      color: Color(0xFF00A6FF).withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Sets: ',
                style: TextStyle(
                  fontSize: 20.0, // insert your font size here
                )),
          ),
          Text(currentSetsString,
              style: TextStyle(
                fontSize: 20.0, // insert your font size here
              )),
        ],
      ),
    );
  }

  Widget buildOpponentDropdown() {
    return Container(
      color: Color(0xFF00A6FF).withOpacity(0.5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Opponent',
                style: TextStyle(
                  fontSize: 20.0, // insert your font size here
                )),
          ),
          Spacer(),
          if (friends.length == 0) FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('friends')
                      .where('email', isEqualTo: user.email)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) return Text('Loading...');
                    return DropdownButton<Friend>(
                      value: selected ? dropdownValue : null,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (Friend newValue) {
                        setState(() {
                          selected = true;
                          dropdownValue = newValue;
                        });
                      },
                      items: friends.length > 0
                          ? friends
                          : snapshot.data.docs.map((DocumentSnapshot document) {
                              friends.add(DropdownMenuItem<Friend>(
                                  value: Friend(
                                      name: document.get('friend_name'),
                                      email: document.get('friend_email'),
                                      uid: document.id),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 2.0, 10.0, 0.0),
                                    //color: primaryColor,
                                    child: Text(document.get('friend_name')),
                                  )));
                              return DropdownMenuItem<Friend>(
                                  value: Friend(
                                      name: document.get('friend_name'),
                                      email: document.get('friend_email'),
                                      uid: document.id),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 2.0, 10.0, 0.0),
                                    //color: primaryColor,
                                    child: Text(document.get('friend_name')),
                                  ));
                            }).toList(),
                    );
                  })
          else DropdownButton<Friend>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (Friend newValue) {
                    setState(() {
                      selected = true;
                      dropdownValue = newValue;
                    });
                  },
                  items: friends)
        ],
      ),
    );
  }

  Widget dateRow() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ButtonTheme(
            minWidth: 100,
            height: 40.0,
            child: ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Date"),
            ),
          ),
        ),
        Ink(
          color: Colors.blueAccent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${df.format(selectedDate.toUtc())}".split(' ')[0],
              style: TextStyle(
                fontSize: 20.0, // insert your font size here
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _validateInputs() {
    if (_formKey.currentState.validate() && dropdownValue != null) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      confirmDialog();
    } else {
//    If all data are not valid then start auto validation.
      String error =
          currentSetsString == "0 : 0" ? 'Add games' : 'Add opponent';
      showError(error);
      // setState(() {
      //   _autoValidate = true;
      // });
    }
  }

  Future<void> showError(String error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Missing info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(error)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Would you like to add this match?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                sendForm();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  void sendForm() async {
    DocumentReference ref = await databaseReference.collection("scores").add({
      'date': selectedDate,
      'opponent': dropdownValue.name,
      'your_score': yourScore,
      'opponent_score': opponentScore,
      'you': user.email,
      'created': FieldValue.serverTimestamp()
    });
    DocumentReference ref2 =
        await databaseReference.collection("score_request").add({
      'date': selectedDate,
      'opponent': user.email,
      'your_score': opponentScore,
      'opponent_score': yourScore,
      'you': dropdownValue.email,
      'created': FieldValue.serverTimestamp(),
          'accepted':'PENDING'
    });
    print(ref.id);
  }
}
