import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/models/certificate_model.dart';
import 'package:sports_app/services/certificate_pdf_service.dart';

void main() {
  test('Export all 15 certificate PDFs into certificates_showcase/pdfs', () async {
    final outputDir = Directory('certificates_showcase/pdfs');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final tiers = CertificateRegistry.allTiers;
    expect(tiers.length, 15);

    for (final tier in tiers) {
      final paddedTier = tier.tier.toString().padLeft(2, '0');
      final safeName = tier.title.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
      final hashSuffix = (tier.tier * 1337).toRadixString(16).toUpperCase().padLeft(4, '0');

      final cert = PlayerCertificateModel(
        id: 'cert_sample_${tier.tier}',
        playerId: 'player_alex_rivera',
        playerName: 'Alex Rivera',
        sport: 'Badminton',
        tier: tier.tier,
        title: tier.title,
        requiredXp: tier.requiredXp,
        awardedAt: DateTime(2026, 10, 10),
        verifyingCoachId: 'coach_david_vance',
        coachName: 'Coach David Vance',
        academyName: 'KRICO Premier Coaching Academy',
        verificationHash: 'KRC-2026-T$paddedTier-$hashSuffix',
      );

      final pdfBytes = await CertificatePdfService.generateCertificatePdf(cert);
      final filename = 'tier_${paddedTier}_$safeName.pdf';
      final file = File('${outputDir.path}/$filename');
      file.writeAsBytesSync(pdfBytes);
      // ignore: avoid_print
      print('Generated: ${file.path} (${pdfBytes.length} bytes)');
    }

    final generatedFiles = outputDir.listSync().whereType<File>().toList();
    expect(generatedFiles.length, 15);
  });
}
