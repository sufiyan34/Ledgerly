class UserProfile {
  final String name;
  final String email;
  final String currency;
  final double monthlyLimit;

  UserProfile({
    required this.name,
    required this.email,
    this.currency = '\$',
    required this.monthlyLimit,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? currency,
    double? monthlyLimit,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'currency': currency,
    'monthlyLimit': monthlyLimit,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'User',
    email: json['email'] ?? 'user@ledgerly.com',
    currency: json['currency'] ?? '\$',
    monthlyLimit: (json['monthlyLimit'] ?? 3000.0).toDouble(),
  );
}
