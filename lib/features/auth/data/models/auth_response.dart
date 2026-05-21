class AuthResponse {
  final String token;
  final String name;

  const AuthResponse({required this.token, required this.name});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        name: json['name'] as String,
      );
}
