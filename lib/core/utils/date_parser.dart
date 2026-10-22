import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}
