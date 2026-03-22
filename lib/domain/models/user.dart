class User {
  final int id;
  final String name;
  final String email;
  final int? companyId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.companyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int? companyId;
    final companies = json['companies'] as List<dynamic>?;
    if (companies != null && companies.isNotEmpty) {
      companyId = companies[0]['id'] as int?;
    }
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      companyId: companyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
