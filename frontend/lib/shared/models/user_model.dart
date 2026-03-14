class UserModel {
  final String id;
  final String societyId;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.societyId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        societyId: json['society_id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'society_id': societyId,
        'email': email,
        'full_name': fullName,
        'role': role,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}
