import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarSelectionDialog extends StatefulWidget {
  final String userId;
  final String? url;
  AvatarSelectionDialog(this.userId, this.url);

  @override
  State<AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends State<AvatarSelectionDialog> {


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Avatar'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatar('avatar1.jpg'),
                _buildAvatar('avatar2.jpg'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatar('avatar3.jpg'),
                _buildAvatar('avatar4.jpg'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatar('avatar5.jpg'),
                _buildAvatar('avatar6.jpg'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatar('avatar7.jpg'),
                _buildAvatar('avatar8.jpg'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatar('avatar9.jpg'),
                _buildAvatar('avatar10.jpg'),
              ],
            ),
            if (widget.url != null)
              GestureDetector(
                onTap: () => _updateAvatar(context, widget.url!),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.url!),
                  radius: 50,
                ),
              ),
          ],
        ),
      ),
    );

  }

  Widget _buildAvatar(String avatarImagePath) {
    return GestureDetector(
      onTap: () => _updateAvatar(context, avatarImagePath),
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/img/' + avatarImagePath),
        radius: 50,
      ),
    );
  }

  Future<void> _updateAvatar(BuildContext context, String avatarName) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

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