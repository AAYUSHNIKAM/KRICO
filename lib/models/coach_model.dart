import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class CoachModel {
  const CoachModel({
    required this.coachId,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.city,
    this.specialization,
    this.experience = 0,
    this.hourlyRate = 0,
    this.bio,
    this.rating = 0,
    this.totalReviews = 0,
    this.subscriptionTier = 'Starter',
    this.isSubscribed = false,
    this.subscriptionExpiry,
    this.certificates,
    this.workExperience,
    this.isVerified = false,
    this.academyId,
    this.createdAt,
    this.updatedAt,
  });

  final String coachId;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? city;
  final String? specialization;
  final int experience;
  final double hourlyRate;
  final String? bio;
  final double rating;
  final int totalReviews;
  final String subscriptionTier;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final List<String>? certificates;
  final List<Map<String, dynamic>>? workExperience;
  final bool isVerified;
  final String? academyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CoachModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CoachModel(
      coachId: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      city: data['city'] as String?,
      specialization: data['specialization'] as String?,
      experience: (data['experience'] as num?)?.toInt() ?? 0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0,
      bio: data['bio'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
      subscriptionTier: data['subscriptionTier'] as String? ?? 'Starter',
      isSubscribed: data['isSubscribed'] as bool? ?? false,
      subscriptionExpiry: _parseTimestamp(data['subscriptionExpiry']),
      certificates: (data['certificates'] as List<dynamic>?)?.cast<String>(),
      workExperience: (data['workExperience'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      isVerified: data['isVerified'] as bool? ?? false,
      academyId: data['academyId'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'photoUrl': photoUrl,
    'city': city,
    'specialization': specialization,
    'experience': experience,
    'hourlyRate': hourlyRate,
    'bio': bio,
    'rating': rating,
    'totalReviews': totalReviews,
    'subscriptionTier': subscriptionTier,
    'isSubscribed': isSubscribed,
    'subscriptionExpiry': subscriptionExpiry != null
        ? Timestamp.fromDate(subscriptionExpiry!)
        : null,
    'certificates': certificates,
    'workExperience': workExperience,
    'isVerified': isVerified,
    'academyId': academyId,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
