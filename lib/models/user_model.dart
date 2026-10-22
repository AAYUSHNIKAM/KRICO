import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

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
    this.handle,
    this.storedUsername,
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.sports,
    this.specialization,
    this.experience,
    this.hourlyRate,
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final String? city;
  final String? bio;
  final String? handle;
  final String? storedUsername;
  final int followersCount;
  final int followingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<String>? sports;
  final String? specialization;
  final int? experience;
  final double? hourlyRate;

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
      handle: data['handle'] as String?,
      storedUsername: data['username'] as String?,
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      isActive: data['isActive'] as bool? ?? true,
      sports: (data['sports'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      specialization: data['specialization'] as String?,
      experience: (data['experience'] as num?)?.toInt(),
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'phone': phone,
    'role': role.name,
    'photoUrl': photoUrl,
    'city': city,
    'bio': bio,
    'handle': handle,
    'username': storedUsername,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'isActive': isActive,
    if (sports != null) 'sports': sports,
    if (specialization != null) 'specialization': specialization,
    if (experience != null) 'experience': experience,
    if (hourlyRate != null) 'hourlyRate': hourlyRate,
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
    String? handle,
    String? storedUsername,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? sports,
    String? specialization,
    int? experience,
    double? hourlyRate,
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
        handle: handle ?? this.handle,
        storedUsername: storedUsername ?? this.storedUsername,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
        sports: sports ?? this.sports,
        specialization: specialization ?? this.specialization,
        experience: experience ?? this.experience,
        hourlyRate: hourlyRate ?? this.hourlyRate,
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

  /// Display username — prefers a stored `username` field, then the stored
  /// `handle`, otherwise a sanitized version of the display name
  /// (e.g. "Rahul Sharma" -> "rahulsharma").
  String get username {
    final stored = storedUsername?.trim() ?? '';
    if (stored.isNotEmpty) return stored;
    if (handle != null && handle!.trim().isNotEmpty) return handle!;
    final sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
    return sanitized.isNotEmpty ? sanitized : uid;
  }
}
