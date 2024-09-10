class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        currency: json['currency'] as String? ?? 'PKR',
      );

  final int id;
  final String name;
  final String email;
  final String currency;

  String get firstName => name.split(' ').first;
}
