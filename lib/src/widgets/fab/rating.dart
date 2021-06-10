import 'package:flutter/material.dart';
import 'package:netten/src/screens/add_game.dart';

Widget ratingFloat(BuildContext context){
  return  FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddGame()),
      );
    },
    child: Icon(Icons.add),
    backgroundColor: Colors.blueAccent,
  );
}