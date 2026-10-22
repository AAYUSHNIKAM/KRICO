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

class VenueTimeSlot {
  const VenueTimeSlot({required this.startTime, required this.endTime, required this.price});

  final String startTime;
  final String endTime;
  final int price;

  String get label => '$startTime - $endTime';

  String get displayLabel => '${_format(startTime)} - ${_format(endTime)}';

  static String _format(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString().padLeft(2, '0')}:$minute $period';
  }

  static const List<VenueTimeSlot> slots = [
    VenueTimeSlot(startTime: '06:00', endTime: '07:00', price: 500),
    VenueTimeSlot(startTime: '07:00', endTime: '08:00', price: 500),
    VenueTimeSlot(startTime: '16:00', endTime: '17:00', price: 600),
    VenueTimeSlot(startTime: '17:00', endTime: '18:00', price: 600),
    VenueTimeSlot(startTime: '18:00', endTime: '19:00', price: 700),
    VenueTimeSlot(startTime: '19:00', endTime: '20:00', price: 700),
  ];
}

class VenueBookingModel {
  const VenueBookingModel({
    required this.bookingId,
    required this.venueId,
    required this.venueName,
    required this.userId,
    required this.userName,
    required this.date,
    required this.startTime,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  final String bookingId;
  final String venueId;
  final String venueName;
  final String userId;
  final String userName;
  final DateTime date;
  final String startTime;
  final double amount;
  final String status;
  final DateTime? createdAt;

  String get dateKey => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  factory VenueBookingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VenueBookingModel(
      bookingId: doc.id,
      venueId: data['venueId'] as String? ?? '',
      venueName: data['venueName'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'booked',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'venueId': venueId,
    'venueName': venueName,
    'userId': userId,
    'userName': userName,
    'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
    'startTime': startTime,
    'amount': amount,
    'status': status,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
  };
}
