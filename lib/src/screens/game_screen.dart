import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netten/src/widgets/app_bar.dart';

class AddGame extends StatefulWidget {
  final String name;
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
  final databaseReference = Firestore.instance;
  User user;
  var dropdownValue;
  List<int> yourGames = List<int>();
  List<int> opponentGames = List<int>();
  List<Widget> _phoneWidgets = List<Widget>();
  int sets = 0;
  String currentSetsString = "0 : 0";
  TextEditingController opponentScoreController;
  TextEditingController yourScoreController;

  void addNewField() {
    sets++;
    if (yourGames.last > opponentGames.last)
      yourScore++;
    else if (opponentGames.last > yourGames.last)
      opponentScore++;
    else {
      opponentScore++;
      yourScore++;
    }
    Widget scoreRow =
    Container(
      margin: EdgeInsets.all(8),
      child:
      Text(yourGames.last.toString() + " : " + opponentGames.last.toString(), style: TextStyle(
          color: Colors.white,
          fontSize: 22
      ),),
    );
    _phoneWidgets.add(scoreRow);
    currentSetsString = yourScore.toString() + " : " + opponentScore.toString();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this.dropdownValue = widget.name;
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
            new Container(
                height: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/raster.jpg"),
                        fit: BoxFit.cover)),
                child: new SingleChildScrollView(
                  child: user != null
                      ? new Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: FormUI(_width),
                  )
                      : Text('Loading...'),
                )),
          ])),
    );
  }

  Widget FormUI(double width) {
    return Column(
      children: [
        Container(
          margin: new EdgeInsets.all(15.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: AppBar().preferredSize.height + 20),
              dateRow(),
              buildOpponentDropdown(),
              SizedBox(height: 10),
              buildSets(),
              SizedBox(height: 10),
              Opacity(
                opacity: 0.5,
                child: Container(
                  color: Color(0xFF00A6FF),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text('Games: ',
                            style: TextStyle(
                              fontSize: 20.0, // insert your font size here
                            )),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('You'),
                            Text('Opponent'),
                          ]),
                      buildGame(),
                      Column(
                        children: List.generate(_phoneWidgets.length, (i) {
                          return _phoneWidgets[i];
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonTheme(
                  minWidth: 200,
                  height: 60.0,
                  child: RaisedButton(
                    onPressed: _validateInputs,
                    child: Text("Send"),
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
      Text(' : '),
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

    if(otherGames.length <= sets && controller.text != "" ){
      otherGames.add(int.parse(controller.text));
    }

    if (yourGames.length == opponentGames.length) {
      yourScoreController.clear();
      opponentScoreController.clear();
      addNewField();
    }
  }

  Widget buildSets() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        color: Color(0xFF00A6FF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sets: ',
                style: TextStyle(
                  fontSize: 20.0, // insert your font size here
                )),
            Text(currentSetsString,
                style: TextStyle(
                  fontSize: 20.0, // insert your font size here
                )),
          ],
        ),
      ),
    );
  }

  Widget buildOpponentDropdown() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friends')
            .where('email', isEqualTo: user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data == null) return Text('Loading...');
          return DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: snapshot.data.docs.map((DocumentSnapshot document) {
              return DropdownMenuItem<String>(
                  value: document.get('friend_name'),
                  child: new Container(
                    decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(5.0)),
                    padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                    //color: primaryColor,
                    child: new Text(document.get('friend_name')),
                  ));
            }).toList(),
          );
        });
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
            child: RaisedButton(
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
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      sendForm();
      Navigator.pop(context);
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
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
      'opponent': dropdownValue,
      'your_score': yourScore,
      'opponent_score': opponentScore,
      'you': user.email
    });
    print(ref.documentID);
  }
}
