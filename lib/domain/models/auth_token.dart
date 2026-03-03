class AuthToken {
  final String token;
  // Crater API might return token type as well, typically 'Bearer'
  final String type;

  AuthToken({
    required this.token,
    this.type = 'Bearer',
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'] as String? ?? json['access_token'] as String,
      type: json['type'] as String? ?? json['token_type'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
    };
  }
}
