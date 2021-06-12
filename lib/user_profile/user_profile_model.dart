class UserProfile {
  final String id;
  final String email;

  UserProfile({this.id, this.email});

  @override
  String toString() {
    return '{ id: $id, email: $email }';
  }
}
