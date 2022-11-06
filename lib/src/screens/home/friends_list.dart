import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/models/friend_request.dart';
import 'package:netten/src/providers/auth_provider.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/src/screens/friends/add_friend.dart';
import 'package:netten/theme.dart';

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
                  FriendRequestWidget(),
                  for (Friend friend in friends) ...[FriendCard(friend: friend), SizedBox(height: 8)]
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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AddFriendScreen(friend: friend);
        }));
      },
      child: SizedBox(
        width: double.infinity,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text(friend.name, style: Theme.of(context).textTheme.bodyText1)),
            )),
      ),
    );
  }
}

class FriendRequestWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can also use "ref" to listen to a provider inside the build method
    final counter = ref.watch(friendRequestProvider);
    return counter.when(
        loading: () => SizedBox.shrink(),
        error: (error, stack) => SizedBox.shrink(),
        data: (List<FriendRequest> data) => Column(children: [
              for (FriendRequest d in data) ...[FriendRequestCard(request: d)]
            ]));
  }
}

class FriendRequestCard extends ConsumerWidget {
  const FriendRequestCard({Key? key, required this.request}) : super(key: key);

  final FriendRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
        width: double.infinity,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.senderName.isNotEmpty ? request.senderName : request.email,
                                style: Theme.of(context).textTheme.bodyText1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (request.senderName.isNotEmpty)
                                Text(request.email, style: Theme.of(context).textTheme.bodyText2)
                            ]),
                      ),
                      ElevatedButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            addFriendFromRequest(
                              id: request.id,
                              email: request.email,
                              name: request.senderName,
                              user: ref.read(authenticationProvider).getUser(),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: NetenColor.primaryColor)),
                      SizedBox(width: 24),
                      ElevatedButton(
                          child: Icon(Icons.clear),
                          onPressed: () {
                            denyRequest(id: request.id);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent)),
                    ]))));
  }
}
