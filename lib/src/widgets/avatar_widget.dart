import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_provider.dart';

class AvatarWidget extends ConsumerWidget {

  final List<String> acceptedAvatarUrls = ['avatar1.png', 'avatar2.png', 'avatar3.png', 'avatar4.png', 'avatar5.png', 'avatar6.png'];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientProvider);

    return CircleAvatar(
      backgroundImage: client.value != null && client.value!.url != null && !acceptedAvatarUrls.contains(client.value!.url)
          ? NetworkImage(client.value!.url!)
          : AssetImage('assets/img/'+(client.value?.url != null ? client.value!.url! : '')) as ImageProvider<Object>,
      radius: 50,
    );
  }
}