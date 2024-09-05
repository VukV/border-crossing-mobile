class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? accessToken;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      accessToken: json.containsKey('accessToken') ? json['accessToken'] : null,
    );
  }

}
