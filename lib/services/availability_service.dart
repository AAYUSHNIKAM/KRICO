import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/availability_model.dart';

class AvailabilityService {
  AvailabilityService(this._firestore);

  final FirebaseFirestore _firestore;

  static const List<String> defaultSlots = [
    '07:00 AM',
    '08:30 AM',
    '10:00 AM',
    '11:30 AM',
    '03:00 PM',
    '04:30 PM',
    '06:00 PM',
    '07:30 PM',
  ];

  Stream<List<AvailabilityModel>> getCoachAvailability(String coachId) {
    if (coachId.trim().isEmpty) return Stream.value([]);
    return _firestore
        .collection('availability')
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AvailabilityModel.fromDoc(doc)).toList());
  }

  Future<List<String>> getAvailableTimeSlots(
    String coachId,
    DateTime date, {
    int? leadTimeHours,
  }) async {
    final targetDay = DateTime(date.year, date.month, date.day);
    final available = <String>{};
    final bookedSlots = <String>{};

    try {
      if (coachId.trim().isNotEmpty) {
        final snapFuture = _firestore
            .collection('availability')
            .where('coachId', isEqualTo: coachId)
            .get();

        final sessionsFuture = _firestore
            .collection('sessions')
            .where('coachId', isEqualTo: coachId)
            .get();

        final coachFuture = (leadTimeHours == null)
            ? _firestore.collection('coaches').doc(coachId).get()
            : Future.value(null);

        final results = await Future.wait([
          snapFuture,
          sessionsFuture,
          coachFuture,
        ]).timeout(const Duration(seconds: 3));

        final snap = results[0] as QuerySnapshot<Map<String, dynamic>>?;
        final bookedSnap = results[1] as QuerySnapshot<Map<String, dynamic>>?;
        final coachDoc = results[2] as DocumentSnapshot<Map<String, dynamic>>?;

        // 1. Process coach availability configurations
        if (snap != null && snap.docs.isNotEmpty) {
          for (final doc in snap.docs) {
            final data = doc.data();
            final docDate = (data['date'] as Timestamp?)?.toDate();
            final isRecurring = data['isRecurring'] as bool? ?? false;
            final recurringDays = (data['recurringDays'] as List<dynamic>?)?.cast<int>();

            bool matches = false;
            if (docDate != null && DateUtils.isSameDay(docDate, targetDay)) {
              matches = true;
            } else if (isRecurring && recurringDays != null && recurringDays.contains(targetDay.weekday)) {
              matches = true;
            }

            if (matches) {
              final slots = (data['timeSlots'] as List<dynamic>?)?.cast<String>() ?? [];
              for (final s in slots) {
                available.add(_standardizeSlot(s));
              }
            }
          }
        }

        // 2. Process booked sessions for collision detection
        if (bookedSnap != null && bookedSnap.docs.isNotEmpty) {
          for (final doc in bookedSnap.docs) {
            final data = doc.data();
            final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
            if (dateTime != null && DateUtils.isSameDay(dateTime, targetDay)) {
              final status = data['status'] as String? ?? '';
              if (status != 'cancelled' && status != 'rejected') {
                bookedSlots.add(_formatToAmPm(dateTime.hour, dateTime.minute));
                bookedSlots.add('${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}');
              }
            }
          }
        }

        // 3. Extract lead time notice window
        if (leadTimeHours == null && coachDoc != null && coachDoc.exists) {
          leadTimeHours = (coachDoc.data()?['leadTimeHours'] as num?)?.toInt() ?? 2;
        }
      }
    } catch (_) {
      // In case of timeout or offline mode, proceed safely with defaults
    }

    final effectiveLead = leadTimeHours ?? 2;
    final now = DateTime.now();
    final earliestAllowed = now.add(Duration(hours: effectiveLead));

    final pool = available.isNotEmpty ? available.toList() : defaultSlots;

    final filtered = pool.where((slot) {
      if (bookedSlots.contains(slot)) return false;
      final parsed = _parseSlot(targetDay, slot);
      return parsed.isAfter(earliestAllowed);
    }).toList();

    filtered.sort((a, b) => _parseSlot(targetDay, a).compareTo(_parseSlot(targetDay, b)));
    return filtered.isNotEmpty ? filtered : defaultSlots;
  }

  Future<void> setAvailability({
    required String coachId,
    required DateTime date,
    required List<String> timeSlots,
    bool isRecurring = false,
    List<int>? recurringDays,
  }) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    try {
      final existingSnap = await _firestore
          .collection('availability')
          .where('coachId', isEqualTo: coachId)
          .get()
          .timeout(const Duration(seconds: 4));

      QueryDocumentSnapshot<Map<String, dynamic>>? match;
      for (final doc in existingSnap.docs) {
        final docDate = (doc.data()['date'] as Timestamp?)?.toDate();
        if (docDate != null && DateUtils.isSameDay(docDate, targetDate)) {
          match = doc;
          break;
        }
      }

      if (match != null) {
        await match.reference.update({
          'timeSlots': timeSlots,
          'isRecurring': isRecurring,
          'recurringDays': recurringDays,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final availabilityId = _firestore.collection('availability').doc().id;
        await _firestore.collection('availability').doc(availabilityId).set(AvailabilityModel(
          availabilityId: availabilityId,
          coachId: coachId,
          date: targetDate,
          timeSlots: timeSlots,
          isRecurring: isRecurring,
          recurringDays: recurringDays,
        ).toMap());
      }
    } catch (_) {
      rethrow;
    }
  }

  static bool isWithin24Hours(DateTime date, [String? timeSlot]) {
    DateTime targetDateTime;
    if (timeSlot != null && timeSlot.contains(':')) {
      final parts = timeSlot.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      targetDateTime = DateTime(date.year, date.month, date.day, hour, minute);
    } else {
      targetDateTime = DateTime(date.year, date.month, date.day, 23, 59);
    }
    return targetDateTime.isBefore(DateTime.now().add(const Duration(hours: 24)));
  }

  Future<void> setBulkAvailability({
    required String coachId,
    required List<DateTime> dates,
    required List<String> timeSlots,
  }) async {
    try {
      final existingSnap = await _firestore
          .collection('availability')
          .where('coachId', isEqualTo: coachId)
          .get()
          .timeout(const Duration(seconds: 4));

      final batch = _firestore.batch();

      for (final date in dates) {
        final targetDate = DateTime(date.year, date.month, date.day);
        QueryDocumentSnapshot<Map<String, dynamic>>? match;
        for (final doc in existingSnap.docs) {
          final docDate = (doc.data()['date'] as Timestamp?)?.toDate();
          if (docDate != null && DateUtils.isSameDay(docDate, targetDate)) {
            match = doc;
            break;
          }
        }

        if (match != null) {
          batch.update(match.reference, {
            'timeSlots': timeSlots,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final availabilityId = _firestore.collection('availability').doc().id;
          final docRef = _firestore.collection('availability').doc(availabilityId);
          batch.set(
            docRef,
            AvailabilityModel(
              availabilityId: availabilityId,
              coachId: coachId,
              date: targetDate,
              timeSlots: timeSlots,
            ).toMap(),
          );
        }
      }

      await batch.commit().timeout(const Duration(seconds: 6));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAvailability(String coachId, DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    try {
      final snap = await _firestore
          .collection('availability')
          .where('coachId', isEqualTo: coachId)
          .get()
          .timeout(const Duration(seconds: 4));

      for (final doc in snap.docs) {
        final docDate = (doc.data()['date'] as Timestamp?)?.toDate();
        if (docDate != null && DateUtils.isSameDay(docDate, targetDate)) {
          await doc.reference.delete();
        }
      }
    } catch (_) {}
  }

  Future<Set<DateTime>> getAvailableDates(String coachId, int monthsAhead) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = DateTime(now.year, now.month + monthsAhead, 0);
    final dates = <DateTime>{};

    try {
      if (coachId.trim().isNotEmpty) {
        final snap = await _firestore
            .collection('availability')
            .where('coachId', isEqualTo: coachId)
            .get()
            .timeout(const Duration(seconds: 3));

        for (final doc in snap.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp?)?.toDate();
          final slots = (data['timeSlots'] as List<dynamic>?)?.cast<String>() ?? [];
          final isRecurring = data['isRecurring'] as bool? ?? false;
          final recurringDays = (data['recurringDays'] as List<dynamic>?)?.cast<int>();

          if (slots.isNotEmpty) {
            if (date != null && !date.isBefore(today) && !date.isAfter(maxDate)) {
              dates.add(DateTime(date.year, date.month, date.day));
            }
            if (isRecurring && recurringDays != null && recurringDays.isNotEmpty) {
              for (DateTime d = today; !d.isAfter(maxDate); d = d.add(const Duration(days: 1))) {
                if (recurringDays.contains(d.weekday)) {
                  dates.add(DateTime(d.year, d.month, d.day));
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    if (dates.isEmpty) {
      for (int i = 0; i <= 30; i++) {
        dates.add(today.add(Duration(days: i)));
      }
    }
    return dates;
  }

  static String _standardizeSlot(String slot) {
    final trimmed = slot.trim();
    if (trimmed.toUpperCase().contains('AM') || trimmed.toUpperCase().contains('PM')) {
      return trimmed;
    }
    final parts = trimmed.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return _formatToAmPm(hour, minute);
    }
    return trimmed;
  }

  static String _formatToAmPm(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  static DateTime _parseSlot(DateTime date, String slotStr) {
    try {
      final parts = slotStr.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final isPm = slotStr.toLowerCase().contains('pm');
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return DateTime(date.year, date.month, date.day, 10, 0);
    }
  }
}
