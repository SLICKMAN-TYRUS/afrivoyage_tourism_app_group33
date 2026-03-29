class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String role; // 'tourist' or 'provider'

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      role: json['role'] ?? 'tourist',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'role': role,
  };
}