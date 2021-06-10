class Friend {
  final String name;
  final String email;
  final String uid;

  const Friend({this.name, this.email, this.uid});

  factory Friend.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final name = data['friend_name'] as String;
    if (name == null) {
      return null;
    }
    final email = data['friend_email'] as String;
    return Friend(name: name, email: email, uid: documentId);
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'email': email
    };
  }
}
