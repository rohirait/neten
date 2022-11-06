class FriendRequest {
  String id;
  String recipientEmail;
  String senderName;
  String senderUid;
  String status;
  String email;

  FriendRequest.name(this.id, this.recipientEmail, this.senderName, this.senderUid, this.status, this.email);

  FriendRequest.fromMap(Map<String, dynamic>? data, {required String id})
      : id = id,
        recipientEmail = data?['recipient_email'] ?? '',
        senderName = data?['sender_name'] ?? '',
        senderUid = data?['sender_uid'] ?? '',
        email = data?['email'],
        status = data?['status'];
}
