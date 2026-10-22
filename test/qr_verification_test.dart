import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/features/schedule/data/session_qr_service.dart';

void main() {
  group('Session QR Verification & Check-In Payloads', () {
    test('generateSessionQrPayload produces valid parseable JSON with all metadata', () {
      final payloadStr = SessionQrService.generateSessionQrPayload(
        sessionId: 'sess_pune_999',
        coachId: 'coach_rajesh',
        playerId: 'player_rohit',
        sport: 'Cricket',
      );

      final Map<String, dynamic> data = jsonDecode(payloadStr);

      expect(data['type'], 'sportseco_session_checkin');
      expect(data['v'], 1);
      expect(data['sessionId'], 'sess_pune_999');
      expect(data['coachId'], 'coach_rajesh');
      expect(data['playerId'], 'player_rohit');
      expect(data['sport'], 'Cricket');
      expect(data['pin'], isNotNull);
      expect((data['pin'] as String).length, 6);
      expect(data['timestamp'], isPositive);
    });

    test('getQuickPin generates consistent 6-digit numeric PIN for manual entry', () {
      final pin1 = SessionQrService.getQuickPin('session_abc_123');
      final pin2 = SessionQrService.getQuickPin('session_abc_123');

      expect(pin1, pin2);
      expect(pin1.length, 6);
      expect(int.tryParse(pin1), isNotNull);
      expect(int.parse(pin1), greaterThanOrEqualTo(100000));
    });
  });
}
