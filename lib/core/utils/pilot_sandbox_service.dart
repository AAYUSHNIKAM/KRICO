import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/coach_model.dart';
import '../../models/user_model.dart';
import '../../models/venue_model.dart';

class PilotSandboxService {
  PilotSandboxService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const bool isPilotVersion = true;
  static const String pilotNotice =
      'KRICO v0.0 Pilot Release - Free Early Access with Simulated Escrow';

  /// Switch the current tester's role seamlessly
  Future<void> switchRole(String uid, UserRole newRole, {String? displayName, String? email}) async {
    final roleName = newRole.name;
    await _firestore.collection('users').doc(uid).set({
      'role': roleName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // If switching to Coach role, ensure a coach record exists in coaches collection
    if (newRole == UserRole.coach) {
      final coachDoc = await _firestore.collection('coaches').doc(uid).get();
      if (!coachDoc.exists) {
        final coach = CoachModel(
          coachId: uid,
          name: (displayName != null && displayName.isNotEmpty) ? displayName : 'Coach Tester',
          email: email ?? 'coach@krico.app',
          phone: '+91 98765 43210',
          city: 'Pune',
          specialization: 'Multi-Sport Training',
          sports: ['Badminton', 'Football', 'Cricket'],
          experience: 5,
          hourlyRate: 600,
          bio: 'KRICO Pilot Coach profile for testing scheduling, attendance, and student progress.',
          rating: 4.9,
          totalReviews: 12,
          isVerified: true,
          subscriptionTier: 'Elite',
          isSubscribed: true,
        );
        await _firestore.collection('coaches').doc(uid).set(coach.toMap());
      }
    }
  }

  /// Seeds real Pune pilot data (Coaches & Venues) if absent or requested
  Future<int> seedPunePilotData() async {
    int seededCount = 0;

    // 1. Seed Pune Coaches
    final puneCoaches = [
      CoachModel(
        coachId: 'pune_coach_rohan',
        name: 'Rohan Kulkarni',
        email: 'rohan.badminton@krico.pune',
        phone: '+91 98220 11223',
        city: 'Pune',
        specialization: 'Badminton Advanced Tactics',
        sports: ['Badminton'],
        experience: 8,
        hourlyRate: 750,
        bio: 'BWF certified coach training state-level juniors at Balewadi and Kothrud arenas.',
        rating: 4.92,
        totalReviews: 28,
        isVerified: true,
        subscriptionTier: 'Elite',
        isSubscribed: true,
      ),
      CoachModel(
        coachId: 'pune_coach_amit',
        name: 'Amit Deshmukh',
        email: 'amit.football@krico.pune',
        phone: '+91 98221 44556',
        city: 'Pune',
        specialization: 'Football Striker & Midfield',
        sports: ['Football'],
        experience: 6,
        hourlyRate: 600,
        bio: 'AIFF-C Licensed youth tactical trainer operating in KP and Kalyani Nagar turfs.',
        rating: 4.85,
        totalReviews: 34,
        isVerified: true,
        subscriptionTier: 'Professional',
        isSubscribed: true,
      ),
      CoachModel(
        coachId: 'pune_coach_vikram',
        name: 'Vikram Joshi',
        email: 'vikram.cricket@krico.pune',
        phone: '+91 98222 77889',
        city: 'Pune',
        specialization: 'Cricket Fast Bowling & Batting Form',
        sports: ['Cricket'],
        experience: 11,
        hourlyRate: 900,
        bio: 'Ex-Ranji squad player focused on pace bowling mechanics and mental match prep at Deccan Gymkhana.',
        rating: 4.95,
        totalReviews: 52,
        isVerified: true,
        subscriptionTier: 'Elite',
        isSubscribed: true,
      ),
      CoachModel(
        coachId: 'pune_coach_priya',
        name: 'Priya Shinde',
        email: 'priya.tennis@krico.pune',
        phone: '+91 98223 99001',
        city: 'Pune',
        specialization: 'Tennis Baseline Power',
        sports: ['Tennis'],
        experience: 7,
        hourlyRate: 850,
        bio: 'AITA certified high-performance tennis trainer specializing in serve power and junior agility.',
        rating: 4.88,
        totalReviews: 24,
        isVerified: true,
        subscriptionTier: 'Professional',
        isSubscribed: true,
      ),
      CoachModel(
        coachId: 'pune_coach_neha',
        name: 'Neha Patil',
        email: 'neha.athletics@krico.pune',
        phone: '+91 98224 22334',
        city: 'Pune',
        specialization: 'Athletics & Sprint Mechanics',
        sports: ['Athletics & Running', 'Strength & Conditioning'],
        experience: 5,
        hourlyRate: 500,
        bio: 'National sprint medalist coaching speed, endurance, and injury-prevention mechanics.',
        rating: 4.78,
        totalReviews: 19,
        isVerified: true,
        subscriptionTier: 'Starter',
        isSubscribed: true,
      ),
    ];

    for (final coach in puneCoaches) {
      await _firestore.collection('coaches').doc(coach.coachId).set(coach.toMap(), SetOptions(merge: true));
      seededCount++;
    }

    // 2. Seed Pune Venues
    final puneVenues = [
      const VenueModel(
        venueId: 'pune_venue_balewadi',
        name: 'Shree Shiv Chhatrapati Sports Complex',
        description: 'World-class multi-sport stadium with indoor badminton courts, Olympic pools, and synthetic tracks.',
        address: 'National Games Park, Balewadi, Pune, Maharashtra 411045',
        city: 'Pune',
        latitude: 18.5744,
        longitude: 73.7667,
        sports: ['Badminton', 'Tennis', 'Swimming', 'Athletics & Running'],
        pricePerHour: 400,
        rating: 4.9,
        capacity: 120,
        amenities: ['Floodlights', 'Parking', 'Changing Rooms', 'Drinking Water', 'First Aid'],
        isVerified: true,
        isActive: true,
      ),
      const VenueModel(
        venueId: 'pune_venue_deccan',
        name: 'Deccan Gymkhana Sports Ground',
        description: 'Historic sports complex featuring dedicated cricket nets, clay tennis courts, and fitness center.',
        address: 'Prabhat Road, Deccan Gymkhana, Pune, Maharashtra 411004',
        city: 'Pune',
        latitude: 18.5173,
        longitude: 73.8415,
        sports: ['Cricket', 'Tennis', 'Basketball'],
        pricePerHour: 600,
        rating: 4.8,
        capacity: 80,
        amenities: ['Parking', 'Changing Rooms', 'Drinking Water', 'Cafeteria'],
        isVerified: true,
        isActive: true,
      ),
      const VenueModel(
        venueId: 'pune_venue_kp_turf',
        name: 'Koregaon Park All-Weather Turf',
        description: 'Premium FIFA-standard astro turf for 5v5 & 7v7 football, box cricket, and weekend pick-up matches.',
        address: 'North Main Road, Koregaon Park, Pune, Maharashtra 411001',
        city: 'Pune',
        latitude: 18.5362,
        longitude: 73.8940,
        sports: ['Football', 'Cricket', 'Pickleball'],
        pricePerHour: 1200,
        rating: 4.75,
        capacity: 30,
        amenities: ['Floodlights', 'Drinking Water', 'Equipment Rental'],
        isVerified: true,
        isActive: true,
      ),
      const VenueModel(
        venueId: 'pune_venue_kothrud',
        name: 'Kothrud Indoor Badminton Arena',
        description: 'BWF-approved synthetic rubberized courts with specialized LED non-glare illumination.',
        address: 'Paud Road, Ideal Colony, Kothrud, Pune, Maharashtra 411038',
        city: 'Pune',
        latitude: 18.5074,
        longitude: 73.8077,
        sports: ['Badminton', 'Table Tennis'],
        pricePerHour: 350,
        rating: 4.85,
        capacity: 40,
        amenities: ['Air Conditioning', 'Changing Rooms', 'Drinking Water'],
        isVerified: true,
        isActive: true,
      ),
    ];

    for (final venue in puneVenues) {
      await _firestore.collection('venues').doc(venue.venueId).set(venue.toMap(), SetOptions(merge: true));
      seededCount++;
    }

    return seededCount;
  }
}
