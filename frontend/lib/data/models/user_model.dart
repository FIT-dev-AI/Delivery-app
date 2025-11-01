class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isOnline;
  final bool isActive; // ✅ NEW: For admin to activate/deactivate users

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.isOnline = true,
    this.isActive = true, // ✅ NEW: Default to active
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // ✅ SỬA LỖI: Thêm '?? 0' để tránh lỗi nếu id bị null
      id: json['id'] ?? 0,
      
      // ✅ SỬA LỖI: Thêm '?? '...' để tránh lỗi nếu name, email, role bị null
      name: json['name'] ?? 'Không có tên',
      email: json['email'] ?? 'Không có email',
      role: json['role'] ?? 'customer', // Mặc định là customer nếu role bị null

      phone: json['phone'], // Giữ nguyên, vì 'phone' đã là nullable (String?)
      
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      
      // Giữ nguyên logic 'isActive' của bạn, nó đã xử lý an toàn
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['active'] == 1 || json['active'] == true,
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
      'is_active': isActive, // ✅ NEW
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
    bool? isActive, // ✅ NEW
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isOnline: isOnline ?? this.isOnline,
      isActive: isActive ?? this.isActive, // ✅ NEW
    );
  }
}