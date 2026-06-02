class UserModel {
  final int? id;
  final String name;
  final String role;
  final String username;
  final String password;
  final String createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.role,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'username': username,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      username: map['username'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }
}
