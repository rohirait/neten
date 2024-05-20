import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_provider.dart';

class AvatarWidget extends ConsumerWidget {
  final List<String> acceptedAvatarUrls = [
    'avatar1.jpg',
    'avatar2.jpg',
    'avatar3.jpg',
    'avatar4.jpg',
    'avatar5.jpg',
    'avatar6.jpg',
    'avatar7.jpg',
    'avatar8.jpg',
    'avatar9.jpg',
    'avatar10.jpg'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientProvider);

    return client.isLoading ? SizedBox.shrink() : CircleAvatar(
      backgroundImage: client.value != null && client.value!.url != null && !acceptedAvatarUrls.contains(client.value!.url)
          ? NetworkImage(client.value!.url!)
          : AssetImage('assets/img/' + (client.value?.url != null ? client.value!.url! : 'random.jpg')) as ImageProvider<Object>,
      radius: 50,
    );
  }
}

class FriendAvatarWidget extends StatelessWidget{
   FriendAvatarWidget({Key? key, required this.url}) : super(key: key);
  final String url;
  final List<String> acceptedAvatarUrls = [
    'avatar1.jpg',
    'avatar2.jpg',
    'avatar3.jpg',
    'avatar4.jpg',
    'avatar5.jpg',
    'avatar6.jpg',
    'avatar7.jpg',
    'avatar8.jpg',
    'avatar9.jpg',
    'avatar10.jpg'
  ];



  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage:!acceptedAvatarUrls.contains(url)
          ? NetworkImage(url)
          : AssetImage('assets/img/' + (url)) as ImageProvider<Object>,
      radius: 15,
    );
  }
}
