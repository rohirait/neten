class Client {
  final String? email;
  final String? name;
  final String? uid;
  final String? url;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? displayName;

  Client({
    this.email,
    this.name,
    this.uid,
    this.url,
    this.firstName,
    this.lastName,
    this.displayName,
  }) : fullName = firstName != null && lastName != null ? '$firstName $lastName' : null;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'uid': uid,
      'url': url,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'displayName': displayName
    };
  }
}
