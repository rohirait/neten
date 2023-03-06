import 'package:flutter/material.dart';
import 'package:netten/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;
  final String privacyUrl = 'https://neten.ee/privacy.html';
  final String termsUrl = 'https://neten.ee/terms.html';

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () async {
                        if (await canLaunchUrlString(termsUrl))
                          await launchUrlString(termsUrl);
                        else
                          throw "Could not launch";
                      },
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(padding: const EdgeInsets.all(12.0), child: Center(child: Text('Terms')))),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () async {
                        if (await canLaunchUrlString(privacyUrl))
                          await launchUrlString(privacyUrl);
                        else
                          throw "Could not launch";
                      },
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(padding: const EdgeInsets.all(12.0), child: Center(child: Text('Privacy')))),
                    ),
                  ),
                  SizedBox(height: 64),
                  Center(
                      child: TextButton(
                          child: Text('Delete profile'),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete my profile'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: const <Widget>[
                                          Text(
                                              'Are you sure you want to delete your profile?'),
                                          Text('This action is permanent!'),
                                          Text('Please allow 1 week for deletion request to be processed')
                                        ],
                                      ),
                                    ),
                                    actionsAlignment: MainAxisAlignment.spaceBetween,
                                    actions: <Widget>[
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel',
                                              style: TextStyle(color: Colors.black))),
                                      TextButton(
                                        child: Text('Delete my profile',
                                            style: TextStyle(color: Colors.black)),
                                        onPressed: () {
                                          deleteUser(uid);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });

                          }))
                ]),
          ),
        ),
      ),
    );
  }
}
