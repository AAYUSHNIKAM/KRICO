import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class AcademyModel {
  const AcademyModel({
    required this.academyId,
    required this.name,
    required this.email,
    required this.phone,
    this.logoUrl,
    this.description,
    this.address,
    this.city,
    this.sports,
    this.website,
    this.socialLinks,
    this.reputationPoints = 0,
    this.coachPlacements = 0,
    this.totalStudents = 0,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String academyId;
  final String name;
  final String email;
  final String phone;
  final String? logoUrl;
  final String? description;
  final String? address;
  final String? city;
  final List<String>? sports;
  final String? website;
  final Map<String, String>? socialLinks;
  final int reputationPoints;
  final int coachPlacements;
  final int totalStudents;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AcademyModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AcademyModel(
      academyId: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      description: data['description'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      sports: (data['sports'] as List<dynamic>?)?.cast<String>(),
      website: data['website'] as String?,
      socialLinks: (data['socialLinks'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      reputationPoints: (data['reputationPoints'] as num?)?.toInt() ?? 0,
      coachPlacements: (data['coachPlacements'] as num?)?.toInt() ?? 0,
      totalStudents: (data['totalStudents'] as num?)?.toInt() ?? 0,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'logoUrl': logoUrl,
    'description': description,
    'address': address,
    'city': city,
    'sports': sports,
    'website': website,
    'socialLinks': socialLinks,
    'reputationPoints': reputationPoints,
    'coachPlacements': coachPlacements,
    'totalStudents': totalStudents,
    'isVerified': isVerified,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
