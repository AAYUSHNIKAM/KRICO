import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/certificate_model.dart';

final progressAndGamificationServiceProvider = Provider<ProgressAndGamificationService>((ref) {
  return ProgressAndGamificationService(FirebaseFirestore.instance);
});

final playerCertificatesProvider = StreamProvider.family<List<PlayerCertificateModel>, String>((ref, playerId) {
  return ref.watch(progressAndGamificationServiceProvider).getCertificatesStream(playerId);
});

class ProgressAndGamificationService {
  final FirebaseFirestore _firestore;

  ProgressAndGamificationService(this._firestore);

  Stream<List<PlayerCertificateModel>> getCertificatesStream(String playerId) {
    return _firestore
        .collection('player_certificates')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snap) {
      final certs = snap.docs.map((d) => PlayerCertificateModel.fromDoc(d)).toList();
      certs.sort((a, b) => b.tier.compareTo(a.tier));
      return certs;
    });
  }

  /// Calculates PB bonus XP based on student's current career PB count:
  /// - PBs 1-5: +2 XP each
  /// - PBs 6-15: +5 XP each
  /// - PBs 16-40: +7 XP each
  /// - PBs 41+: +10 XP each
  int calculatePbBonusXp(int currentPbCount) {
    if (currentPbCount < 5) return 2;
    if (currentPbCount < 15) return 5;
    if (currentPbCount < 40) return 7;
    return 10;
  }

  /// 1. Log Session Progress Evaluation & Award Earned XP
  Future<Map<String, dynamic>> logSessionProgress({
    required String coachId,
    required String coachName,
    String? academyName,
    required String playerId,
    required String playerName,
    required String sport,
    required int workEthicRating, // 1 to 5 -> 1 to 5 XP
    required int technicalRating, // 1 to 5 -> 1 to 5 XP
    List<String> verifiedDrills = const [], // 4 XP each, max 8 XP
    Map<String, double> newPbMetrics = const {}, // Progressive PB XP
    String? coachNotes,
    String? nextSessionGoal,
    String? readinessStatus,
  }) async {
    // 1. Coach evaluation XP capped strictly at 10 XP
    final workXp = workEthicRating.clamp(1, 5);
    final techXp = technicalRating.clamp(1, 5);
    final coachRatingXp = (workXp + techXp).clamp(1, 10);

    // 2. Concrete drill XP: 4 XP per verified drill (max 2 drills = 8 XP)
    final drillXp = (verifiedDrills.length * 4).clamp(0, 8);

    final playerRef = _firestore.collection('players').doc(playerId);
    final playerSnap = await playerRef.get();
    final playerData = playerSnap.data() ?? {};
    final currentPoints = (playerData['points'] as num?)?.toInt() ?? 0;
    int currentPbCount = (playerData['totalPbs'] as num?)?.toInt() ?? 0;
    final currentDrills = (playerData['totalDrills'] as num?)?.toInt() ?? 0;

    // 3. PB Calculation
    int pbXp = 0;
    for (final _ in newPbMetrics.entries) {
      pbXp += calculatePbBonusXp(currentPbCount);
      currentPbCount++;
    }

    final totalSessionXp = coachRatingXp + drillXp + pbXp;
    final newPoints = currentPoints + totalSessionXp;

    // 4. Save Session Progress Log
    final progressDocRef = _firestore.collection('studentProgress').doc();
    await progressDocRef.set({
      'progressId': progressDocRef.id,
      'coachId': coachId,
      'coachName': coachName,
      'academyName': academyName ?? 'KRICO Academy',
      'playerId': playerId,
      'playerName': playerName,
      'sport': sport,
      'workEthicRating': workEthicRating,
      'technicalRating': technicalRating,
      'coachRatingXp': coachRatingXp,
      'verifiedDrills': verifiedDrills,
      'drillXp': drillXp,
      'newPbMetrics': newPbMetrics,
      'pbXp': pbXp,
      'totalXpAwarded': totalSessionXp,
      'coachNotes': coachNotes ?? '',
      'nextSessionGoal': nextSessionGoal ?? '',
      'readinessStatus': readinessStatus ?? (playerData['readinessStatus'] as String? ?? 'Fundamentals'),
      'loggedAt': FieldValue.serverTimestamp(),
    });

    // 5. Save PB metrics to player_metrics collection
    for (final entry in newPbMetrics.entries) {
      final metricRef = _firestore.collection('player_metrics').doc();
      await metricRef.set({
        'id': metricRef.id,
        'playerId': playerId,
        'metricName': entry.key,
        'value': entry.value,
        'sport': sport,
        'coachId': coachId,
        'recordedAt': FieldValue.serverTimestamp(),
      });
    }

    // 6. Update Player Profile
    final updates = <String, dynamic>{
      'points': FieldValue.increment(totalSessionXp),
      'totalPbs': currentPbCount,
      'totalDrills': currentDrills + verifiedDrills.length,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (readinessStatus != null && readinessStatus.isNotEmpty) {
      updates['readinessStatus'] = readinessStatus;
    }
    await playerRef.update(updates);

    // 7. Auto-issue any newly earned Certificate milestones
    final newCerts = await _checkAndAwardCertificates(
      playerId: playerId,
      playerName: playerName,
      sport: sport,
      newPoints: newPoints,
      coachId: coachId,
      coachName: coachName,
      academyName: academyName,
    );

    return {
      'totalSessionXp': totalSessionXp,
      'coachRatingXp': coachRatingXp,
      'drillXp': drillXp,
      'pbXp': pbXp,
      'newPoints': newPoints,
      'newCertificates': newCerts,
    };
  }

  /// 2. Session Attendance Verification & 76-Hour Streak Consistency XP
  /// - Base: 20 XP
  /// - Streak: +1 XP per consecutive day/session (capped at 30 XP)
  /// - 76-Hour Reset: If gap > 76 hours, streak resets to 1 (20 XP)
  Future<Map<String, dynamic>> awardSessionAttendanceXp({
    required String playerId,
    required String sessionId,
    String? coachId,
    String? coachName,
    String? academyName,
    String sport = 'Athletics',
  }) async {
    final playerRef = _firestore.collection('players').doc(playerId);
    final playerSnap = await playerRef.get();
    if (!playerSnap.exists) return {'earnedXp': 20, 'streak': 1};

    final data = playerSnap.data()!;
    final playerName = data['name'] as String? ?? 'Athlete';
    final currentPoints = (data['points'] as num?)?.toInt() ?? 0;
    final currentStreak = (data['consistencyStreak'] as num?)?.toInt() ?? 1;
    final lastSessionTime = (data['lastSessionTime'] as Timestamp?)?.toDate();

    final now = DateTime.now();
    int newStreak;

    if (lastSessionTime == null) {
      newStreak = 1;
    } else {
      final hoursSinceLast = now.difference(lastSessionTime).inHours;
      if (hoursSinceLast <= 76) {
        // Maintained consistency streak within 76 hours
        newStreak = (currentStreak + 1).clamp(1, 15);
      } else {
        // Consistency streak broken beyond 76 hours window
        newStreak = 1;
      }
    }

    // Base 20 XP + streak bonus (max 30 XP)
    final earnedXp = (20 + (newStreak - 1)).clamp(20, 30);
    final newPoints = currentPoints + earnedXp;

    await playerRef.update({
      'points': FieldValue.increment(earnedXp),
      'consistencyStreak': newStreak,
      'lastSessionTime': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Check certificate milestones
    final newCerts = await _checkAndAwardCertificates(
      playerId: playerId,
      playerName: playerName,
      sport: sport,
      newPoints: newPoints,
      coachId: coachId,
      coachName: coachName,
      academyName: academyName,
    );

    return {
      'earnedXp': earnedXp,
      'streak': newStreak,
      'newPoints': newPoints,
      'newCertificates': newCerts,
    };
  }

  /// Checks for milestone crossing and auto-generates digital certificate documents
  Future<List<PlayerCertificateModel>> _checkAndAwardCertificates({
    required String playerId,
    required String playerName,
    required String sport,
    required int newPoints,
    String? coachId,
    String? coachName,
    String? academyName,
  }) async {
    final newlyAwarded = <PlayerCertificateModel>[];
    final qualifyingTiers = CertificateRegistry.allTiers.where((t) => newPoints >= t.requiredXp).toList();

    for (final tierDef in qualifyingTiers) {
      final certDocId = 'cert_${tierDef.requiredXp}_$playerId';
      final certRef = _firestore.collection('player_certificates').doc(certDocId);
      final docSnap = await certRef.get();

      if (!docSnap.exists) {
        final randomHash = 'SEC-${DateTime.now().year}-${(1000 + Random().nextInt(8999))}-${tierDef.tier.toString().padLeft(2, '0')}';
        final cert = PlayerCertificateModel(
          id: certDocId,
          playerId: playerId,
          playerName: playerName,
          sport: sport,
          tier: tierDef.tier,
          title: tierDef.title,
          requiredXp: tierDef.requiredXp,
          awardedAt: DateTime.now(),
          verifyingCoachId: coachId,
          coachName: coachName ?? 'Accredited Sports Coach',
          academyName: academyName ?? 'KRICO Athletic Academy',
          verificationHash: randomHash,
        );

        await certRef.set(cert.toMap());
        newlyAwarded.add(cert);

        // Update player's highest certificate title and tier
        await _firestore.collection('players').doc(playerId).update({
          'highestCertificateTitle': tierDef.title,
          'highestCertificateTier': tierDef.tier,
        });

        // Notify player of new certificate
        await _firestore.collection('notifications').add({
          'userId': playerId,
          'title': '🏆 New Certificate Unlocked: ${tierDef.title}!',
          'body': 'Congratulations! You unlocked the ${tierDef.title} certificate (${tierDef.requiredXp} XP milestone).',
          'type': 'certificate_unlocked',
          'metadata': {'certificateId': certDocId, 'tier': tierDef.tier},
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return newlyAwarded;
  }
}
