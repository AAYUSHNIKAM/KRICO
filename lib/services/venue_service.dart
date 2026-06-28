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
