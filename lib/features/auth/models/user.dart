class User {
  final String id;
  final String email;
  final String? displayName;
  final bool bioEnabled;
  final String? pinCode;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.bioEnabled = false,
    this.pinCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      bioEnabled: json['bio_enabled'] as bool? ?? false,
      pinCode: json['pin_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'bio_enabled': bioEnabled,
      'pin_code': pinCode,
    };
  }

  factory User.fromSupabase(Map<String, dynamic> json, String? email) {
    return User(
        id: json['id'] as String,
        email: email ?? '',
        displayName: json['display_name'] as String?,
        bioEnabled: json['bio_enabled'] as bool? ?? false,
        pinCode: json['pin_code'] as String?
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName &&
      other.bioEnabled == bioEnabled &&
      other.pinCode == pinCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      bioEnabled.hashCode ^
      pinCode.hashCode;
  }
}
