import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/models/score.dart';
import 'package:netten/src/providers/client_provider.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/src/providers/score_provider.dart';
import 'package:netten/src/screens/home/games_list.dart';

import '../../../theme.dart';
import '../../models/client.dart';
import '../../models/friend.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_text.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key, this.friend, this.user}) : super(key: key);

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
  final Friend? friend;
  final User? user;
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? name;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
        ),
        backgroundColor: NetenColor.backgroundColor,
        bottomNavigationBar: (widget.friend == null || widget.friend!.email.isEmpty)
            ? Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final Client? user = ref.read(clientProvider).value;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (user != null && widget.friend != null) {
                          validateFormAndUpdateFriend(widget.friend!, user);
                        } else if (user != null) {
                          validateFormAndAddFriend(user);
                        }
                        ;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Add friend',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white)),
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
              )
            : null,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(children: [
              SizedBox(height: 20),
              Center(
                  child: GradientText("NeteN",
                      style: Theme.of(context).textTheme.headline2,
                      gradient: LinearGradient(colors: [NetenColor.primaryColor, NetenColor.secondaryColor]))),
              SizedBox(height: 40),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    initialValue: widget.friend != null ? widget.friend!.name : '',
                    enabled: widget.friend == null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.person, color: NetenColor.primaryColor),
                      hintText: 'Name of your friend',
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter friend\'s name';
                      }
                      return null;
                    },
                    onSaved: (String? val) {
                      name = val;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    enabled: widget.friend == null || widget.friend!.email.isEmpty,
                    initialValue: widget.friend != null ? widget.friend!.email : '',
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      fillColor: NetenColor.primaryColor,
                      icon: Icon(Icons.email, color: NetenColor.primaryColor),
                      hintText: 'Friend\'s email',
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      return validateEmail(val, strict: widget.friend == null);
                    },
                    onSaved: (String? val) {
                      email = val;
                    },
                  ),
                ),
              ),
              if (widget.friend != null && widget.user != null)
                StreamBuilder(
                  stream: friendScores(widget.friend!, widget.user!),
                  builder: (BuildContext context, AsyncSnapshot<List<Score>> snapshot) {
                    if (snapshot.data != null)
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 16),
                        Text('Scores'),
                        SizedBox(height: 16),
                        for (Score score in snapshot.data!) ...[ScoreView(score: score, user: widget.user!)]
                      ]);
                    else
                      return SizedBox.shrink();
                  },
                )
            ]),
          ),
        ))));
  }

  void validateFormAndAddFriend(Client s) {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      if (email != null && name != null) {
        addFriend(email: email!, name: name!, user: s);
      }
      Navigator.of(context).pop();
    }
  }

  void validateFormAndUpdateFriend(Friend friend, Client user) {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      if (email != null) {
        updateFriend(email: email!, friendId: friend.id, user: user);
      }
      Navigator.of(context).pop();
    }
  }

  String? validateEmail(String? value, {bool strict = true}) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if ((value == null || value.isEmpty) && strict) return null;
    if (value == null || !regex.hasMatch(value))
      return 'Please enter valid email';
    else
      return null;
  }
}
