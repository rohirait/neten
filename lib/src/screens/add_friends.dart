import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchFriends extends StatefulWidget {
  NewFriends createState() => NewFriends();
}

class NewFriends extends State<SearchFriends> {
  User user;
  String _name;
  String _email;
  var friendNames = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  final databaseReference = Firestore.instance;
  var documents;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

  }

  void _loadCurrentUser() {
    this.user = FirebaseAuth.instance.currentUser;
    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: new AppBar(
              title: const Text('Friends'),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, false),
              )),
          body: new Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/raster.jpg"),
                      fit: BoxFit.cover)),
              child: new Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: FormUI(_width),
              ))),
    );
  }

  Widget FormUI(double width) {
    return Container(
      margin: new EdgeInsets.all(15.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //Center Column contents vertically,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: AppBar().preferredSize.height + 20),
            Opacity(
              opacity: 0.5,
              child: Container(
                color: Color(0xFF00A6FF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
                      child: Text('Name: ',
                          style: TextStyle(
                            fontSize: 20.0, // insert your font size here
                          )),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new TextFormField(
                          validator : validateName,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          onSaved: (String val) {
                            _name = val;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.5,
              child: Container(
                color: Color(0xFF00A6FF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
                      child: Text('Email: ',
                          style: TextStyle(
                            fontSize: 20.0, // insert your font size here
                          )),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          onSaved: (String val) {
                            _email = val;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ButtonTheme(
                minWidth: 200,
                height: 60.0,
                child: RaisedButton(
                  onPressed: _validateInputs,
                  child: Text("Add friend"),
                ),
              ),
            ),
          ]),
    );
  }
  String validateName(String value){
    if(value == ""){
      return 'Please enter a name';
    } else if(friendNames.contains(value) ){
      return 'Friend already exists';
    }

    return null;

  }
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value!="" && !regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      sendForm();
      Navigator.pop(context);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void sendForm() async {
      DocumentReference ref = await databaseReference.collection("friends")
          .add({
        'email': user.email,
        'friend_email': _email,
        'friend_name': _name,
        'uid': user.uid
      });
     if(_email != null && _email != ""){
       DocumentReference ref = await databaseReference.collection("friend_request")
           .add({
         'email': user.email,
         'recipient_email': _email,
         'recipient_name': _name,
         'sender_uid': user.uid,
         'sender_name': user.displayName,
         'status': "PENDING"
       });
     }
  }

  Future<void> _loadFriends() async {
    QuerySnapshot querySnapshot = await databaseReference.collection('friends').where('email', isEqualTo: user.email).getDocuments().then((value){
      value.documents.forEach((element) {
        friendNames.add(element.get('friend_name'));
      });
    });
  }
}
