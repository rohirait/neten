import 'package:flutter/material.dart';
import 'package:netten/src/screens/add_friends.dart';

Widget friendFloat(BuildContext context){
  return  FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchFriends()),
      );
    },
    child: Icon(Icons.add),
    backgroundColor: Colors.blueAccent,
  );
}