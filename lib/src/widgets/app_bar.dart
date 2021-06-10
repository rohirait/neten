import 'package:flutter/material.dart';

Widget appBar(BuildContext context, String text) {
  return AppBar(
      title: Text('$text'),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, false),
      ));
}
