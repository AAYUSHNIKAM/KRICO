import 'package:cloud_firestore/cloud_firestore.dart';

class VenueModel {
  const VenueModel({
    required this.venueId,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.amenities,
    this.images,
    this.contactPhone,
    this.website,
    this.openingHours,
    this.sports,
    this.capacity,
    this.rating = 0,
    this.isGoogleSourced = false,
    this.googlePlaceId,
    this.isActive = true,
    this.addedBy,
    this.isVerified = false,
    this.pricePerHour,
    this.createdAt,
    this.updatedAt,
  });

  final String venueId;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final List<String>? amenities;
  final List<String>? images;
  final String? contactPhone;
  final String? website;
  final String? openingHours;
  final List<String>? sports;
  final int? capacity;
  final double rating;
  final bool isGoogleSourced;
  final String? googlePlaceId;
  final bool isActive;
  final String? addedBy;
  final bool isVerified;
  final double? pricePerHour;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VenueModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VenueModel(
      venueId: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      amenities: (data['amenities'] as List<dynamic>?)?.cast<String>(),
      images: (data['images'] as List<dynamic>?)?.cast<String>(),
      contactPhone: data['contactPhone'] as String?,
      website: data['website'] as String?,
      openingHours: data['openingHours'] as String?,
      sports: (data['sports'] as List<dynamic>?)?.cast<String>(),
      capacity: data['capacity'] as int?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      isGoogleSourced: data['isGoogleSourced'] as bool? ?? false,
      googlePlaceId: data['googlePlaceId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      addedBy: data['addedBy'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'address': address,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'amenities': amenities,
    'images': images,
    'contactPhone': contactPhone,
    'website': website,
    'openingHours': openingHours,
    'sports': sports,
    'capacity': capacity,
    'rating': rating,
    'isGoogleSourced': isGoogleSourced,
    'googlePlaceId': googlePlaceId,
    'isActive': isActive,
    'addedBy': addedBy,
    'isVerified': isVerified,
    'pricePerHour': pricePerHour,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
