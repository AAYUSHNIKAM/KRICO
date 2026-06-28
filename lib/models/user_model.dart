import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { parent, player, coach, academy, admin }

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.city,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final String? city;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: _parseRole(data['role'] as String? ?? 'parent'),
      photoUrl: data['photoUrl'] as String?,
      city: data['city'] as String?,
      bio: data['bio'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'phone': phone,
    'role': role.name,
    'photoUrl': photoUrl,
    'city': city,
    'bio': bio,
    'isActive': isActive,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    String? photoUrl,
    String? city,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        photoUrl: photoUrl ?? this.photoUrl,
        city: city ?? this.city,
        bio: bio ?? this.bio,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'parent':
        return UserRole.parent;
      case 'player':
        return UserRole.player;
      case 'coach':
        return UserRole.coach;
      case 'academy':
        return UserRole.academy;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.parent;
    }
  }
}
