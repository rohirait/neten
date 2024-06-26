import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:netten/src/models/friend.dart';
import 'package:netten/src/models/friend_request.dart';
import 'package:netten/src/providers/auth_provider.dart';
import 'package:netten/src/providers/client_provider.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/src/screens/friends/add_friend.dart';
import 'package:netten/src/widgets/avatar_widget.dart';
import 'package:netten/theme.dart';

class FriendsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var friendsList = ref.watch(friendsStreamProvider);
    return friendsList.when(
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
                  for (Friend friend in friends) ...[
                    FriendCard(friend: friend, user: ref.watch(authenticationProvider).getUser()!, ref: ref),
                    SizedBox(height: 8)
                  ]
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
  final User user;
  final WidgetRef ref;

  const FriendCard({Key? key, required this.friend, required this.user, required this.ref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(15.0),
            onPressed: (context) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Remove friend'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('Are you sure you want to remove this friend?'),
                            Text('This action is permanent!')
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: <Widget>[
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel', style: TextStyle(color: Colors.black))),
                        TextButton(
                          child: Text('Delete friend', style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            deleteFriend(user, friend.id, friend.email);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return AddFriendScreen(friend: friend, user: user);
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
                child: Row(
                  children: [
                    if (friend.uid != '') getAvatar(friend.email),
                    Expanded(
                        child: Text(friend.name,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyLarge)),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget getAvatar(String email) {
    return FutureBuilder<String?>(
        future: getUserAvatarUrl(email),
        builder: (context, snap) {
          if (snap.data != null)
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FriendAvatarWidget(url: snap.data!),
            );
          else
            return SizedBox.shrink();
        });
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
                                style: Theme.of(context).textTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (request.senderName.isNotEmpty)
                                Text(request.email, style: Theme.of(context).textTheme.bodyMedium)
                            ]),
                      ),
                      ElevatedButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            if (request.senderName.isNotEmpty) {
                              addFriendFromRequest(
                                id: request.id,
                                email: request.email,
                                name: request.senderName,
                                user: ref.read(clientProvider).value,
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    String name = '';
                                    return StatefulBuilder(builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text('Please add the name of the friend'),
                                        content: TextFormField(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            fillColor: NetenColor.primaryColor,
                                            icon: Icon(Icons.email, color: NetenColor.primaryColor),
                                            hintText: "Friend's name",
                                            labelText: 'Name',
                                          ),
                                          onChanged: (value) {
                                            name = value;
                                            setState(() {});
                                          },
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (val) {
                                            if (name.isEmpty) {
                                              return 'Name cannot be empty';
                                            }
                                            return null;
                                          },
                                        ),
                                        actionsAlignment: MainAxisAlignment.center,
                                        actions: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: NetenColor.primaryColor,
                                                  disabledBackgroundColor: Colors.grey),
                                              onPressed: name.isNotEmpty
                                                  ? () {
                                                      addFriendFromRequest(
                                                        id: request.id,
                                                        email: request.email,
                                                        name: name,
                                                        user: ref.read(clientProvider).value,
                                                      ).then((value) => Navigator.of(context).pop());
                                                    }
                                                  : null,
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Save',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ))
                                        ],
                                      );
                                    });
                                  });
                            }
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
