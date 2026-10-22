import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contract_model.dart';
import 'contract_service.dart';

class BookingResult {
  final String sessionId;
  final String? contractId;

  const BookingResult({required this.sessionId, this.contractId});
}

class BookingService {
  BookingService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<BookingResult> createBooking({
    required String coachId,
    required String playerId,
    required DateTime dateTime,
    required String sport,
    required double amount,
    String? bookedBy,
    String? notes,
    String? couponCode,
    double? discountAmount,
  }) async {
    if (coachId.isEmpty || playerId.isEmpty || sport.trim().isEmpty ||
        !dateTime.isAfter(DateTime.now()) || !amount.isFinite || amount < 0) {
      throw ArgumentError('A valid coach, player, sport, future time and price are required.');
    }
    final sessionId = _firestore.collection('sessions').doc().id;
    await _firestore.collection('sessions').doc(sessionId).set({
      'sessionId': sessionId,
      'coachId': coachId,
      'playerId': playerId,
      'bookedBy': bookedBy ?? playerId,
      'sport': sport,
      'dateTime': Timestamp.fromDate(dateTime),
      'amount': amount,
      'status': 'confirmed',
      'escrowStatus': 'held_in_escrow',
      'notes': notes ?? '',
      'couponCode': ?couponCode,
      if (discountAmount != null && discountAmount > 0) 'discountAmount': discountAmount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    String? contractId;
    try {
      final contract = ContractService.draftContract(
        partyAId: coachId,
        partyBId: bookedBy ?? playerId,
        partyARole: 'coach',
        partyBRole: bookedBy != null && bookedBy != playerId ? 'parent' : 'player',
        type: ContractType.coaching,
        amount: amount,
        terms: 'Coaching session for $sport on ${dateTime.toIso8601String()}',
      );
      final contractService = ContractService(_firestore);
      await contractService.createContract(contract);
      await _firestore.collection('sessions').doc(sessionId).update({
        'contractId': contract.contractId,
      });
      contractId = contract.contractId;
    } catch (_) {}

    return BookingResult(sessionId: sessionId, contractId: contractId);
  }

  /// Cancels a session from the coach's side.
  /// Player is 100% refunded instantly from platform escrow.
  /// Unless it is bad weather or force majeure, the coach incurs a cancellation penalty
  /// added to their [penaltyBalance] to be deducted from their next session payout.
  Future<Map<String, dynamic>> cancelBookingByCoach({
    required String sessionId,
    required String coachId,
    required String reason,
    bool isWeatherOrForceMajeure = false,
  }) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);
    final sessionSnap = await sessionRef.get();
    if (!sessionSnap.exists) {
      throw Exception('Session $sessionId not found');
    }
    final sessionData = sessionSnap.data()!;
    final amount = (sessionData['amount'] as num?)?.toDouble() ?? 0.0;
    final playerId = sessionData['playerId'] as String? ?? '';

    // Penalty: 20% of session amount, min ₹150, max ₹500
    final double penalty = isWeatherOrForceMajeure
        ? 0.0
        : (amount * 0.20).clamp(150.0, 500.0);

    final batch = _firestore.batch();
    batch.update(sessionRef, {
      'status': 'cancelled_by_coach',
      'escrowStatus': 'refunded_to_player',
      'cancellationReason': reason,
      'isWeatherOrForceMajeure': isWeatherOrForceMajeure,
      'penaltyApplied': penalty,
      'refundedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (penalty > 0) {
      final coachRef = _firestore.collection('coaches').doc(coachId);
      batch.update(coachRef, {
        'penaltyBalance': FieldValue.increment(penalty),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Record notification for the player
    if (playerId.isNotEmpty) {
      final notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'notificationId': notifRef.id,
        'userId': playerId,
        'title': 'Session Cancelled • 100% Refund Issued',
        'message': isWeatherOrForceMajeure
            ? 'Your coach reported weather/unfit ground. 100% refund of ₹${amount.toInt()} has been processed to your payment method.'
            : 'Coach was unable to take your session. 100% refund of ₹${amount.toInt()} has been returned to your original payment method.',
        'type': 'refund',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    return {
      'success': true,
      'refundAmount': amount,
      'penaltyChargedToCoach': penalty,
    };
  }

  /// Cancels a session from the player/parent's side with asymmetric fair windows:
  /// > 6 hours before session: 100% refund to player
  /// < 2 hours before session: 50% refund to player, 50% released to coach for reserved court/prep time
  /// 2-6 hours before session: 80% refund to player, 20% partial compensation to coach
  Future<Map<String, dynamic>> cancelBookingByPlayer({
    required String sessionId,
    required String playerId,
    required String reason,
  }) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);
    final sessionSnap = await sessionRef.get();
    if (!sessionSnap.exists) {
      throw Exception('Session $sessionId not found');
    }
    final sessionData = sessionSnap.data()!;
    final amount = (sessionData['amount'] as num?)?.toDouble() ?? 0.0;
    final dateTime = (sessionData['dateTime'] as Timestamp).toDate();
    final hoursRemaining = dateTime.difference(DateTime.now()).inMinutes / 60.0;

    double refundPercentage;
    if (hoursRemaining >= 6.0) {
      refundPercentage = 1.0; // 100%
    } else if (hoursRemaining <= 2.0) {
      refundPercentage = 0.50; // 50%
    } else {
      refundPercentage = 0.80; // 80%
    }

    final refundAmount = amount * refundPercentage;
    final coachShare = amount - refundAmount;

    await sessionRef.update({
      'status': 'cancelled_by_player',
      'escrowStatus': coachShare > 0 ? 'partially_released' : 'refunded_to_player',
      'cancellationReason': reason,
      'refundAmount': refundAmount,
      'coachCompensation': coachShare,
      'refundedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return {
      'success': true,
      'refundAmount': refundAmount,
      'coachCompensation': coachShare,
      'hoursBeforeSession': hoursRemaining,
    };
  }

  /// Freezes session escrow payout due to unplayable weather/rainout and grants a 14-day reschedule token.
  Future<void> reportWeatherInterruption({
    required String sessionId,
    required String reportedBy,
    required String details,
  }) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);
    await sessionRef.update({
      'status': 'weather_delayed',
      'escrowStatus': 'frozen_pending_reschedule',
      'weatherReportedBy': reportedBy,
      'weatherDetails': details,
      'reschedulePassValidUntil': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Requests a verified substitute coach when the primary coach has sudden emergency or illness.
  Future<void> requestSubstituteCoach({
    required String sessionId,
    required String currentCoachId,
    required String substituteCoachId,
    required String substituteCoachName,
    required String reason,
  }) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);
    await sessionRef.update({
      'status': 'substitute_requested',
      'originalCoachId': currentCoachId,
      'substituteCoachId': substituteCoachId,
      'substituteCoachName': substituteCoachName,
      'substituteReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Player responds to substitute request: either accepts new coach or claims instant 100% refund.
  Future<void> respondToSubstitute({
    required String sessionId,
    required bool accept,
  }) async {
    final sessionRef = _firestore.collection('sessions').doc(sessionId);
    final sessionSnap = await sessionRef.get();
    if (!sessionSnap.exists) return;
    final sessionData = sessionSnap.data()!;

    if (accept) {
      final subId = sessionData['substituteCoachId'] as String?;
      await sessionRef.update({
        'coachId': subId ?? sessionData['coachId'],
        'status': 'confirmed',
        'isSubstituteAccepted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await cancelBookingByCoach(
        sessionId: sessionId,
        coachId: sessionData['coachId'] as String? ?? '',
        reason: 'Athlete declined substitute coach proposal',
        isWeatherOrForceMajeure: true, // No penalty for declining sub
      );
    }
  }

  /// Automated pro-rata refund for multi-session packages when coach relocates or abandons.
  Future<Map<String, dynamic>> claimPackageProRataRefund({
    required String packageId,
    required String playerId,
    required String reason,
  }) async {
    final pkgRef = _firestore.collection('coaching_packages').doc(packageId);
    final pkgSnap = await pkgRef.get();
    if (!pkgSnap.exists) {
      throw Exception('Package $packageId not found');
    }
    final data = pkgSnap.data()!;
    final totalSessions = (data['totalSessions'] as num?)?.toInt() ?? 1;
    final completedSessions = (data['completedSessions'] as num?)?.toInt() ?? 0;
    final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

    final remainingSessions = (totalSessions - completedSessions).clamp(0, totalSessions);
    final refundAmount = (remainingSessions / totalSessions) * totalAmount;
    final coachEarned = totalAmount - refundAmount;

    await pkgRef.update({
      'escrowState': 'refunded',
      'refundAmount': refundAmount,
      'coachEarned': coachEarned,
      'refundReason': reason,
      'refundedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return {
      'success': true,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'refundAmount': refundAmount,
      'coachEarned': coachEarned,
    };
  }

  Future<Map<String, dynamic>> getBookingSummary({
    required String coachId,
    required String playerId,
    required DateTime dateTime,
    required String sport,
    required double amount,
  }) async {
    final platformFee = amount * 0.10;
    final totalAmount = amount + platformFee;

    return {
      'coachId': coachId,
      'playerId': playerId,
      'sport': sport,
      'dateTime': dateTime,
      'amount': amount,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
    };
  }
}
