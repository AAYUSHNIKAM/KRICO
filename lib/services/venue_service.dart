import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue_model.dart';

class VenueService {
  VenueService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<VenueModel>> getVenues() {
    return _firestore
        .collection('venues')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => VenueModel.fromDoc(doc)).toList());
  }

  Stream<VenueModel> getVenue(String venueId) {
    return _firestore
        .collection('venues')
        .doc(venueId)
        .snapshots()
        .map((doc) => VenueModel.fromDoc(doc));
  }

  Future<String> addVenue(VenueModel venue) async {
    final docRef = _firestore.collection('venues').doc();
    final data = venue.toMap();
    data['venueId'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  Future<void> updateVenue(String venueId, Map<String, dynamic> data) {
    return _firestore.collection('venues').doc(venueId).update(data);
  }

  Future<String> createVenueBooking({
    required String venueId,
    required String venueName,
    required String userId,
    required String userName,
    required DateTime date,
    required String startTime,
    required double amount,
  }) async {
    final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final slotClean = startTime.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final slotLockDocId = '${venueId}_${dateKey}_$slotClean';
    final lockRef = _firestore.collection('venueSlotLocks').doc(slotLockDocId);

    return _firestore.runTransaction((transaction) async {
      final lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists && lockSnap.data()?['status'] == 'booked') {
        throw StateError('This court slot ($startTime on $dateKey) has just been booked. Please pick another available time slot.');
      }

      final docRef = _firestore.collection('venueBookings').doc();
      final booking = VenueBookingModel(
        bookingId: docRef.id,
        venueId: venueId,
        venueName: venueName,
        userId: userId,
        userName: userName,
        date: DateTime(date.year, date.month, date.day),
        startTime: startTime,
        amount: amount,
        status: 'booked',
        createdAt: DateTime.now(),
      );

      transaction.set(lockRef, {
        'venueId': venueId,
        'dateKey': dateKey,
        'startTime': startTime,
        'bookingId': docRef.id,
        'bookedBy': userId,
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(docRef, booking.toMap());

      return docRef.id;
    });
  }

  Future<void> cancelVenueBooking({
    required String bookingId,
    required String venueId,
    required DateTime date,
    required String startTime,
  }) async {
    final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final slotClean = startTime.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final slotLockDocId = '${venueId}_${dateKey}_$slotClean';

    final batch = _firestore.batch();
    batch.update(_firestore.collection('venueBookings').doc(bookingId), {
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_firestore.collection('venueSlotLocks').doc(slotLockDocId));
    await batch.commit();
  }

  Stream<List<VenueBookingModel>> getVenueBookings(String venueId) {
    return _firestore
        .collection('venueBookings')
        .where('venueId', isEqualTo: venueId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => VenueBookingModel.fromDoc(doc)).toList());
  }

  Future<List<VenueModel>> searchVenues(String query) async {
    final snap = await _firestore
        .collection('venues')
        .where('isActive', isEqualTo: true)
        .get();
    final venues = snap.docs.map((doc) => VenueModel.fromDoc(doc)).toList();
    if (query.isEmpty) return venues;
    final lower = query.toLowerCase();
    return venues.where((v) =>
      v.name.toLowerCase().contains(lower) ||
      (v.sports?.any((s) => s.toLowerCase().contains(lower)) ?? false) ||
      (v.city?.toLowerCase().contains(lower) ?? false) ||
      (v.address?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }
}
