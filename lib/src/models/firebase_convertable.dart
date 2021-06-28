abstract class FirebaseConverter<T> {
  String id;
  FirebaseConverter(Map snapshot, String id);

  FirebaseConverter.fromMap(Map<String, dynamic> snapshot, String id);

  Map<String, dynamic> toJson();

  T parseFromMap(Map<String, dynamic> snapshot, String id);
}