class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'user_id': userId, 'name': name, 'email': email, 'role': role};
  }
}
