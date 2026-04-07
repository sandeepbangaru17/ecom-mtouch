class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final DateTime createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
