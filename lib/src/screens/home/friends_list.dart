import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/src/providers/score_provider.dart';

import 'package:netten/src/models/score.dart';

class FriendsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var user = ref.watch(friendsStreamProvider);
    return user.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Text('Oops'),
      data: (friends) {
        return Expanded(
          child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                for(Friend friend in friends) ...[FriendCard(friend: friend), SizedBox(height: 8)]
              ],
            ),
          ),
      ),
        );
      },
    );
  }
}

class FriendCard extends StatelessWidget {
  final Friend friend;

  const FriendCard({Key? key, required this.friend}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: Text(friend.name, style: Theme.of(context).textTheme.bodyText1)),
        )

      ),
    );
  }

}


