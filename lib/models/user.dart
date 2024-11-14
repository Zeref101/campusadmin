class User {
  final String id;
  final String email;
  final String rollNo;

  User({required this.id, required this.email, required this.rollNo});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['\$id'],
      email: map['email'],
      rollNo: map['rollNo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': id,
      'email': email,
      'rollNo': rollNo,
    };
  }
}
