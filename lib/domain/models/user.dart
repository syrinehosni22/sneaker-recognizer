class User {
  final String id;
  final String email;
  final String name;
  final bool isSubscribed;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.isSubscribed = false,
  });

  User copyWith({String? name, String? email, bool? isSubscribed}) {
    return User(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  /// ✅ CREATE USER FROM API JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isSubscribed: json['isSubscribed'] ?? false,
    );
  }

  /// OPTIONAL: SEND USER TO API
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "isSubscribed": isSubscribed,
    };
  }
}
