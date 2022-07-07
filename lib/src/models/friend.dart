class Friend {
  final String name;
  final String email;
  final String uid;

  const Friend({required this.name, required this.email, required this.uid});

  Friend.fromMap(Map<String, dynamic>? data)
      : name = data?['friend_name'] ?? '',
        email = data?['friend_email'] ?? '',
        uid = data?['uid'] ?? '';
  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'email': email,
      'uid':uid
    };
  }

  @override
  bool operator ==(other) {
    return (other is Friend)
        && other.name == name
        && other.email == email && other.uid == uid;
  }
}
