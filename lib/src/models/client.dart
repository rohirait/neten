class Client {
  final String? email;
  final String? name;
  final String? uid;
  final String? url;

  Client({
    this.email,
    this.name,
    this.uid,
    this.url,
  });
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'uid': uid,
      'url': url,
    };
  }
}