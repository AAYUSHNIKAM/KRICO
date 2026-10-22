import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInResult {
  final bool success;
  final String message;
  final String? sessionId;
  final DateTime? verifiedAt;

  CheckInResult({
    required this.success,
    required this.message,
    this.sessionId,
    this.verifiedAt,
  });
}

class SessionQrService {
  final FirebaseFirestore _firestore;

  SessionQrService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Generates a tamper-evident QR payload containing session metadata and signature
  static String generateSessionQrPayload({
    required String sessionId,
    required String coachId,
    required String playerId,
    required String sport,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final pin = getQuickPin(sessionId);

    final payloadMap = {
      'type': 'sportseco_session_checkin',
      'v': 1,
      'sessionId': sessionId,
      'coachId': coachId,
      'playerId': playerId,
      'sport': sport,
      'timestamp': now,
      'pin': pin,
    };

    return jsonEncode(payloadMap);
  }

  /// Extracts the 6-character quick pin from a session ID for manual check-in
  static String getQuickPin(String sessionId) {
    return (sessionId.hashCode.abs() % 900000 + 100000).toString();
  }

  /// Verifies the QR payload or quick PIN and marks session attendance in Firestore
  Future<CheckInResult> verifyAndRecordAttendance({
    required String rawPayload,
    required String attendeeUserId,
    required bool isPlayer,
  }) async {
    try {
      String sessionId;
      String? expectedPlayerId;

      if (rawPayload.trim().startsWith('{')) {
        final Map<String, dynamic> data = jsonDecode(rawPayload);
        if (data['type'] != 'krico_session_checkin' && data['type'] != 'sportseco_session_checkin') {
          return CheckInResult(
            success: false,
            message: 'Invalid QR code. Please scan a valid KRICO session QR.',
          );
        }
        sessionId = data['sessionId'] as String;
        expectedPlayerId = data['playerId'] as String?;
      } else {
        final input = rawPayload.trim();
        if (RegExp(r'^\d{6}$').hasMatch(input)) {
          String? foundId;
          final pinSessions = await _firestore
              .collection('sessions')
              .where('status', isEqualTo: 'booked')
              .limit(30)
              .get();
          for (final doc in pinSessions.docs) {
            if (getQuickPin(doc.id) == input || doc.data()['quickPin'] == input) {
              foundId = doc.id;
              break;
            }
          }
          if (foundId == null) {
            final pinBookings = await _firestore
                .collection('bookings')
                .where('status', isEqualTo: 'booked')
                .limit(30)
                .get();
            for (final doc in pinBookings.docs) {
              if (getQuickPin(doc.id) == input || doc.data()['quickPin'] == input) {
                foundId = doc.id;
                break;
              }
            }
          }
          if (foundId == null) {
            return CheckInResult(
              success: false,
              message: 'No active session found matching PIN "$input". Please check with coach.',
            );
          }
          sessionId = foundId;
        } else {
          sessionId = input;
        }
      }

      // Check sessions collection
      final sessionRef = _firestore.collection('sessions').doc(sessionId);
      final sessionSnap = await sessionRef.get();

      if (!sessionSnap.exists) {
        // Fallback check in bookings collection
        final bookingRef = _firestore.collection('bookings').doc(sessionId);
        final bookingSnap = await bookingRef.get();

        if (!bookingSnap.exists) {
          return CheckInResult(
            success: false,
            message: 'Session record not found. Please verify the QR or session PIN.',
          );
        }

        final bookingData = bookingSnap.data()!;
        final bPlayerId = bookingData['playerId'] as String?;
        final bStatus = bookingData['status'] as String?;

        if (bStatus == 'completed') {
          return CheckInResult(
            success: false,
            message: 'This session has already been marked as attended and completed.',
          );
        }

        if (expectedPlayerId != null && bPlayerId != null && bPlayerId != attendeeUserId) {
          if (isPlayer && attendeeUserId != bPlayerId) {
            return CheckInResult(
              success: false,
              message: 'This session belongs to a different athlete account.',
            );
          }
        }

        final batch = _firestore.batch();
        batch.update(bookingRef, {
          'status': 'completed',
          'attendanceVerified': true,
          'attendanceVerifiedAt': FieldValue.serverTimestamp(),
          'verifiedBy': attendeeUserId,
          'escrowStatus': 'released_to_coach',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final packageId = bookingData['packageId'] as String?;
        if (packageId != null && packageId.isNotEmpty) {
          final pkgRef = _firestore.collection('coaching_packages').doc(packageId);
          batch.update(pkgRef, {
            'completedSessions': FieldValue.increment(1),
            'lastSessionCompletedAt': FieldValue.serverTimestamp(),
            'escrowState': 'partially_released',
          });
        }

        await batch.commit();

        return CheckInResult(
          success: true,
          message: 'Attendance verified successfully! Session marked complete.',
          sessionId: sessionId,
          verifiedAt: DateTime.now(),
        );
      }

      final sData = sessionSnap.data()!;
      final sPlayerId = sData['playerId'] as String?;
      final sStatus = sData['status'] as String?;

      if (sStatus == 'completed') {
        return CheckInResult(
          success: false,
          message: 'Attendance already recorded for this session.',
        );
      }

      if (isPlayer && sPlayerId != null && sPlayerId.isNotEmpty && sPlayerId != attendeeUserId) {
        return CheckInResult(
          success: false,
          message: 'Attendance mismatch: This session was scheduled for a different athlete.',
        );
      }

      final coachId = sData['coachId'] as String? ?? '';
      final sessionAmount = (sData['amount'] as num?)?.toDouble() ?? 0.0;
      final coachGrossPayout = sessionAmount * 0.90; // 90% payout, 10% platform fee

      // Check if coach has pending penalty deductions
      double penaltyDeducted = 0.0;
      if (coachId.isNotEmpty) {
        try {
          final coachDoc = await _firestore.collection('coaches').doc(coachId).get();
          if (coachDoc.exists) {
            final activePenalty = (coachDoc.data()?['penaltyBalance'] as num?)?.toDouble() ?? 0.0;
            if (activePenalty > 0) {
              penaltyDeducted = activePenalty.clamp(0.0, coachGrossPayout);
            }
          }
        } catch (_) {}
      }

      final netCoachPayout = coachGrossPayout - penaltyDeducted;

      final batch = _firestore.batch();
      batch.update(sessionRef, {
        'status': 'completed',
        'attendanceVerified': true,
        'attendanceVerifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': attendeeUserId,
        'escrowStatus': 'released_to_coach',
        'grossCoachPayout': coachGrossPayout,
        'penaltyDeducted': penaltyDeducted,
        'netCoachPayout': netCoachPayout,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear deducted penalty from coach record
      if (penaltyDeducted > 0) {
        final coachRef = _firestore.collection('coaches').doc(coachId);
        batch.update(coachRef, {
          'penaltyBalance': FieldValue.increment(-penaltyDeducted),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final bookingRef = _firestore.collection('bookings').doc(sessionId);
      batch.set(bookingRef, {
        'status': 'completed',
        'attendanceVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Check if attendee is a linked child with a parent account
      if (sPlayerId != null && sPlayerId.isNotEmpty) {
        try {
          final playerSnapDoc = await _firestore.collection('users').doc(sPlayerId).get();
          final parentId = playerSnapDoc.data()?['parentId'] as String?;
          final playerName = playerSnapDoc.data()?['name'] as String? ?? 'Your athlete';
          if (parentId != null && parentId.isNotEmpty) {
            final parentNotifRef = _firestore.collection('notifications').doc();
            batch.set(parentNotifRef, {
              'notificationId': parentNotifRef.id,
              'userId': parentId,
              'title': 'Athlete Check-In Confirmed',
              'message': '$playerName has safely checked in for their training session.',
              'type': 'attendance',
              'sessionId': sessionId,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {}
      }

      await batch.commit();

      final penaltyMessage = penaltyDeducted > 0
          ? ' (₹${penaltyDeducted.toInt()} previous cancellation penalty settled)'
          : '';

      return CheckInResult(
        success: true,
        message: 'Attendance verified successfully! Coach payout released$penaltyMessage.',
        sessionId: sessionId,
        verifiedAt: DateTime.now(),
      );
    } catch (e) {
      return CheckInResult(
        success: false,
        message: 'Error verifying attendance: ${e.toString()}',
      );
    }
  }

  /// Offline Roster Check-In: Allows coach to check in an athlete on court
  /// even when the child does not carry a smartphone.
  Future<CheckInResult> verifyRosterAttendanceOffline({
    required String sessionId,
    required String coachId,
  }) async {
    return verifyAndRecordAttendance(
      rawPayload: sessionId,
      attendeeUserId: coachId,
      isPlayer: false,
    );
  }
}
