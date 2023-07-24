import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarSelectionDialog extends StatelessWidget {
  final String userId;
  final String? url;
  AvatarSelectionDialog(this.userId, this.url);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Avatar'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _updateAvatar(context, 'avatar1.png'),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/img/avatar1.png'),
                radius: 50,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _updateAvatar(context, 'avatar2.png'),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/img/avatar2.png'),
                radius: 50,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _updateAvatar(context, 'avatar6.png'),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/img/avatar6.png'),
                radius: 50,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _updateAvatar(context, 'avatar5.png'),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/img/avatar5.png'),
                radius: 50,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _updateAvatar(context, 'avatar3.png'),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/img/avatar3.png'),
                radius: 50,
              ),
            ),
            if(url != null) ...[
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _updateAvatar(context, url!),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(url!),
                  radius: 50,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _updateAvatar(BuildContext context, String avatarName) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await userDoc.update({'url': avatarName});
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avatar updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar')),
      );
    }
  }
}