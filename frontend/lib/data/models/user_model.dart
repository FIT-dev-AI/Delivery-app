class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isOnline; // ✅ NEW

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.isOnline = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'is_online': isOnline,
    };
  }
  
  bool get isCustomer => role == 'customer';
  bool get isShipper => role == 'shipper';
  bool get isAdmin => role == 'admin';

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
