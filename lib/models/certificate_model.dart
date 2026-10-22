import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/utils/date_parser.dart';

enum CertificateTheme {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  celestial,
}

class CertificateTierDefinition {
  final int tier;
  final String title;
  final int requiredXp;
  final String crestBadge;
  final CertificateTheme theme;
  final String description;
  final String accolade;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final int decorationLevel; // 1: Basic Foundation, 2: Framed Vanguard, 3: Gilded Elite, 4: Grandmaster Ornate, 5: Sovereign Hall of Fame
  final String latinMotto;
  final String accreditationHeader;
  final String certificateHeading;
  final String sealTitle;
  final List<String> signatoryRoles;

  const CertificateTierDefinition({
    required this.tier,
    required this.title,
    required this.requiredXp,
    required this.crestBadge,
    required this.theme,
    required this.description,
    required this.accolade,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderColor,
    this.decorationLevel = 1,
    this.latinMotto = 'Gradus Primus Virtutis',
    this.accreditationHeader = 'KRICO ATHLETIC ACCREDITATION',
    this.certificateHeading = 'CERTIFICATE OF ATHLETIC MASTERY',
    this.sealTitle = 'OFFICIAL SEAL - VERIFIED',
    this.signatoryRoles = const ['Accredited Lead Coach'],
  });
}

class CertificateRegistry {
  static const List<CertificateTierDefinition> allTiers = [
    // --- LEVEL 1: FOUNDATION (TIERS 1-2) ---
    CertificateTierDefinition(
      tier: 1,
      title: 'Foundational Athlete',
      requiredXp: 100,
      crestBadge: '🥉',
      theme: CertificateTheme.bronze,
      description: 'Mastered athletic discipline, session attendance, and foundational conditioning.',
      accolade: 'Foundation Accredited',
      primaryColor: Color(0xFFCD7F32),
      secondaryColor: Color(0xFF8C531B),
      borderColor: Color(0xFFD49A6A),
      decorationLevel: 1,
      latinMotto: 'Gradus Primus Virtutis',
      accreditationHeader: 'KRICO FOUNDATIONAL ACCREDITATION',
      certificateHeading: 'CERTIFICATE OF ATHLETIC INITIATION',
      sealTitle: 'OFFICIAL INITIATE SEAL',
      signatoryRoles: ['Accredited Lead Coach'],
    ),
    CertificateTierDefinition(
      tier: 2,
      title: 'Dedicated Trainee',
      requiredXp: 300,
      crestBadge: '🌿',
      theme: CertificateTheme.bronze,
      description: 'Maintained training streak consistency and verified baseline drill metrics.',
      accolade: 'Consistency Verified',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFF92400E),
      borderColor: Color(0xFFF59E0B),
      decorationLevel: 1,
      latinMotto: 'Assiduitas et Constantia',
      accreditationHeader: 'KRICO FOUNDATIONAL ACCREDITATION',
      certificateHeading: 'CERTIFICATE OF TRAINING DISCIPLINE',
      sealTitle: 'CONSISTENCY VERIFIED SEAL',
      signatoryRoles: ['Accredited Lead Coach'],
    ),

    // --- LEVEL 2: COMPETITIVE VANGUARD (TIERS 3-5) ---
    CertificateTierDefinition(
      tier: 3,
      title: 'Rising Competitor',
      requiredXp: 600,
      crestBadge: '🥈',
      theme: CertificateTheme.silver,
      description: 'Demonstrated tactical awareness and sharp technical execution under coach observation.',
      accolade: 'Tactical Competence',
      primaryColor: Color(0xFFCBD5E1),
      secondaryColor: Color(0xFF64748B),
      borderColor: Color(0xFF94A3B8),
      decorationLevel: 2,
      latinMotto: 'In Proelio Crescit',
      accreditationHeader: 'KRICO COMPETITIVE VANGUARD',
      certificateHeading: 'CERTIFICATE OF TACTICAL COMPETENCE',
      sealTitle: 'TACTICAL ACCREDITATION SEAL',
      signatoryRoles: ['Accredited Lead Coach', 'Technical Supervisor'],
    ),
    CertificateTierDefinition(
      tier: 4,
      title: 'Disciplined Athlete',
      requiredXp: 1000,
      crestBadge: '🛡️',
      theme: CertificateTheme.silver,
      description: 'Surpassed 1,000 career XP milestone through dedicated training camps and personal records.',
      accolade: 'Milestone Vanguard',
      primaryColor: Color(0xFF94A3B8),
      secondaryColor: Color(0xFF475569),
      borderColor: Color(0xFFE2E8F0),
      decorationLevel: 2,
      latinMotto: 'Disciplina Vincit Omnia',
      accreditationHeader: 'KRICO COMPETITIVE VANGUARD',
      certificateHeading: 'CERTIFICATE OF ADVANCED DISCIPLINE',
      sealTitle: '1,000 XP VANGUARD SEAL',
      signatoryRoles: ['Accredited Lead Coach', 'Technical Supervisor'],
    ),
    CertificateTierDefinition(
      tier: 5,
      title: 'Consistent Striker',
      requiredXp: 1500,
      crestBadge: '⚔️',
      theme: CertificateTheme.silver,
      description: 'Exceptional consistency in multi-drill performance and endurance training.',
      accolade: 'Performance Ironclad',
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF0369A1),
      borderColor: Color(0xFF7DD3FC),
      decorationLevel: 2,
      latinMotto: 'Impetus et Fides',
      accreditationHeader: 'KRICO COMPETITIVE VANGUARD',
      certificateHeading: 'CERTIFICATE OF ENDURANCE & STRIKING',
      sealTitle: 'IRONCLAD COMPETITIVE SEAL',
      signatoryRoles: ['Accredited Lead Coach', 'Technical Supervisor'],
    ),

    // --- LEVEL 3: GILDED ELITE (TIERS 6-8) ---
    CertificateTierDefinition(
      tier: 6,
      title: 'Advanced Performer',
      requiredXp: 2200,
      crestBadge: '🥇',
      theme: CertificateTheme.gold,
      description: 'Mastered high-intensity rally and match-play drills with superior focus ratings.',
      accolade: 'High Performance',
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFB45309),
      borderColor: Color(0xFFFDE68A),
      decorationLevel: 3,
      latinMotto: 'Excellens in Corpore et Animo',
      accreditationHeader: 'KRICO HIGH PERFORMANCE DIVISION',
      certificateHeading: 'CERTIFICATE OF HIGH PERFORMANCE MASTERY',
      sealTitle: '24K GOLD PERFORMANCE SEAL',
      signatoryRoles: ['Accredited Lead Coach', 'Academy Coaching Director'],
    ),
    CertificateTierDefinition(
      tier: 7,
      title: 'Tournament Candidate',
      requiredXp: 3000,
      crestBadge: '🦅',
      theme: CertificateTheme.gold,
      description: 'Certified tournament-ready by academy coaching staff for competitive circuit entries.',
      accolade: 'Tournament Certified',
      primaryColor: Color(0xFFEAB308),
      secondaryColor: Color(0xFFA16207),
      borderColor: Color(0xFFFEF08A),
      decorationLevel: 3,
      latinMotto: 'Agmen Ducere',
      accreditationHeader: 'KRICO HIGH PERFORMANCE DIVISION',
      certificateHeading: 'CERTIFICATE OF TOURNAMENT ACCREDITATION',
      sealTitle: 'OFFICIAL TOURNAMENT SEAL',
      signatoryRoles: ['Accredited Lead Coach', 'Academy Coaching Director'],
    ),
    CertificateTierDefinition(
      tier: 8,
      title: 'Elite Competitor',
      requiredXp: 4000,
      crestBadge: '🏅',
      theme: CertificateTheme.gold,
      description: 'Superlative stamina, strategic acumen, and repeatable personal best achievements.',
      accolade: 'Elite Accreditation',
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFFD97706),
      borderColor: Color(0xFFFFFBEB),
      decorationLevel: 3,
      latinMotto: 'Virtus sine Fine',
      accreditationHeader: 'KRICO HIGH PERFORMANCE DIVISION',
      certificateHeading: 'DIPLOMA OF ELITE ATHLETIC EXCELLENCE',
      sealTitle: 'STARBURST ROSETTE GOLD SEAL',
      signatoryRoles: ['Accredited Lead Coach', 'Academy Coaching Director'],
    ),

    // --- LEVEL 4: GRANDMASTER ORNATE (TIERS 9-12) ---
    CertificateTierDefinition(
      tier: 9,
      title: 'Mastery Vanguard',
      requiredXp: 5500,
      crestBadge: '💠',
      theme: CertificateTheme.platinum,
      description: 'Exemplary leadership, work ethic, and superior coach rating scorecards.',
      accolade: 'Mastery Vanguard',
      primaryColor: Color(0xFF2DD4BF),
      secondaryColor: Color(0xFF0F766E),
      borderColor: Color(0xFF99F6E4),
      decorationLevel: 4,
      latinMotto: 'Apex Magisterii',
      accreditationHeader: 'KRICO NATIONAL GRANDMASTER ACADEMY',
      certificateHeading: 'DIPLOMA OF MASTERY VANGUARD',
      sealTitle: 'PLATINUM LAUREL ROSETTE',
      signatoryRoles: ['Master Lead Coach', 'Academy Technical Director', 'State Athletic Board'],
    ),
    CertificateTierDefinition(
      tier: 10,
      title: 'Academy Champion',
      requiredXp: 7500,
      crestBadge: '👑',
      theme: CertificateTheme.platinum,
      description: 'Ranked in the top echelon of academy athletes across endurance and technical benchmarks.',
      accolade: 'Academy Champion',
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF0E7490),
      borderColor: Color(0xFFA5F3FC),
      decorationLevel: 4,
      latinMotto: 'Corona Victoriae',
      accreditationHeader: 'KRICO NATIONAL GRANDMASTER ACADEMY',
      certificateHeading: 'CHAMPION OF THE ACADEMY CONFERRAL',
      sealTitle: 'CROWN EMBOSSED GRANDMASTER SEAL',
      signatoryRoles: ['Master Lead Coach', 'Academy Technical Director', 'State Athletic Board'],
    ),
    CertificateTierDefinition(
      tier: 11,
      title: 'Grandmaster Athlete',
      requiredXp: 10000,
      crestBadge: '💎',
      theme: CertificateTheme.diamond,
      description: 'Deca-Millennium career accomplishment. Demonstrated supreme athletic command.',
      accolade: 'Grandmaster Rank',
      primaryColor: Color(0xFF818CF8),
      secondaryColor: Color(0xFF4338CA),
      borderColor: Color(0xFFC7D2FE),
      decorationLevel: 4,
      latinMotto: 'Decem Millia Virtutis',
      accreditationHeader: 'KRICO NATIONAL GRANDMASTER ACADEMY',
      certificateHeading: 'ORDER OF THE GRANDMASTER ATHLETE',
      sealTitle: 'DECA-MILLENNIUM DIAMOND SEAL',
      signatoryRoles: ['Master Lead Coach', 'Academy Technical Director', 'State Athletic Board'],
    ),
    CertificateTierDefinition(
      tier: 12,
      title: 'State-Level Contender',
      requiredXp: 13000,
      crestBadge: '🔷',
      theme: CertificateTheme.diamond,
      description: 'Certified state-caliber competitor backed by extensive coach evaluations and verified PBs.',
      accolade: 'State Accreditation',
      primaryColor: Color(0xFFA855F7),
      secondaryColor: Color(0xFF6B21A8),
      borderColor: Color(0xFFE9D5FF),
      decorationLevel: 4,
      latinMotto: 'Robur Civitatis',
      accreditationHeader: 'KRICO NATIONAL GRANDMASTER ACADEMY',
      certificateHeading: 'STATE-TIER PREMIER ACCREDITATION',
      sealTitle: 'STATE ATHLETIC DIRECTIVE SEAL',
      signatoryRoles: ['Master Lead Coach', 'Academy Technical Director', 'State Athletic Board'],
    ),

    // --- LEVEL 5: SOVEREIGN & HALL OF FAME (TIERS 13-15) ---
    CertificateTierDefinition(
      tier: 13,
      title: 'National Prospect',
      requiredXp: 16500,
      crestBadge: '☀️',
      theme: CertificateTheme.diamond,
      description: 'Demonstrated exceptional sports acumen worthy of national-level development camps.',
      accolade: 'National Prospect',
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFF9D174D),
      borderColor: Color(0xFFFBCFE8),
      decorationLevel: 5,
      latinMotto: 'Fulgur Patriam Decorat',
      accreditationHeader: 'KRICO SUPREME COUNCIL & HALL OF FAME',
      certificateHeading: 'NATIONAL ELITE PROSPECT DIPLOMA',
      sealTitle: 'NATIONAL COUNCIL IMPERIAL SEAL',
      signatoryRoles: ['Master Coach Emeritus', 'Technical Director', 'Council President'],
    ),
    CertificateTierDefinition(
      tier: 14,
      title: 'Legendary Athlete',
      requiredXp: 20500,
      crestBadge: '🌌',
      theme: CertificateTheme.celestial,
      description: 'Pinnacle of athleticism. Unmatched work ethic, peer mentorship, and tournament mastery.',
      accolade: 'Legendary Distinction',
      primaryColor: Color(0xFFF43F5E),
      secondaryColor: Color(0xFF881337),
      borderColor: Color(0xFFFECDD3),
      decorationLevel: 5,
      latinMotto: 'Monumentum Aere Perennius',
      accreditationHeader: 'KRICO SUPREME COUNCIL & HALL OF FAME',
      certificateHeading: 'SOVEREIGN ORDER OF THE LEGENDARY ATHLETE',
      sealTitle: 'CELESTIAL IMPERIAL CREST',
      signatoryRoles: ['Master Coach Emeritus', 'Technical Director', 'Council President'],
    ),
    CertificateTierDefinition(
      tier: 15,
      title: 'Hall of Fame Sovereign',
      requiredXp: 25000,
      crestBadge: '🪐',
      theme: CertificateTheme.celestial,
      description: 'Immortalized in the KRICO Athletics Hall of Fame. Master of the Craft.',
      accolade: 'Hall of Fame Immortal',
      primaryColor: Color(0xFFCCFF00),
      secondaryColor: Color(0xFF4D7C0F),
      borderColor: Color(0xFFECFCCB),
      decorationLevel: 5,
      latinMotto: 'Ad Astra Per Aspera - In Aeternum',
      accreditationHeader: 'KRICO SUPREME COUNCIL & HALL OF FAME',
      certificateHeading: 'SOVEREIGN HALL OF FAME INDUCTION',
      sealTitle: 'PERPETUAL HALL OF FAME GOLD SEAL',
      signatoryRoles: ['Master Coach Emeritus', 'Academy Dean', 'Council President'],
    ),
  ];

  static CertificateTierDefinition? getTierByXp(int xp) {
    CertificateTierDefinition? highest;
    for (final tier in allTiers) {
      if (xp >= tier.requiredXp) {
        highest = tier;
      }
    }
    return highest;
  }

  static CertificateTierDefinition? getNextTier(int xp) {
    for (final tier in allTiers) {
      if (xp < tier.requiredXp) {
        return tier;
      }
    }
    return null;
  }

  static double getProgressToNextTier(int xp) {
    final current = getTierByXp(xp);
    final next = getNextTier(xp);
    if (next == null) return 1.0;
    final base = current?.requiredXp ?? 0;
    final totalSpan = next.requiredXp - base;
    if (totalSpan <= 0) return 1.0;
    final progress = (xp - base) / totalSpan;
    return progress.clamp(0.0, 1.0);
  }
}

class PlayerCertificateModel {
  final String id;
  final String playerId;
  final String playerName;
  final String sport;
  final int tier;
  final String title;
  final int requiredXp;
  final DateTime awardedAt;
  final String? verifyingCoachId;
  final String? coachName;
  final String? academyName;
  final String verificationHash;

  const PlayerCertificateModel({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.sport,
    required this.tier,
    required this.title,
    required this.requiredXp,
    required this.awardedAt,
    this.verifyingCoachId,
    this.coachName,
    this.academyName,
    required this.verificationHash,
  });

  CertificateTierDefinition get tierDefinition {
    return CertificateRegistry.allTiers.firstWhere(
      (t) => t.tier == tier,
      orElse: () => CertificateRegistry.allTiers.first,
    );
  }

  factory PlayerCertificateModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlayerCertificateModel(
      id: doc.id,
      playerId: data['playerId'] as String? ?? '',
      playerName: data['playerName'] as String? ?? 'Athlete',
      sport: data['sport'] as String? ?? 'Athletics',
      tier: (data['tier'] as num?)?.toInt() ?? 1,
      title: data['title'] as String? ?? 'Certificate of Achievement',
      requiredXp: (data['requiredXp'] as num?)?.toInt() ?? 100,
      awardedAt: parseTimestamp(data['awardedAt']) ?? DateTime.now(),
      verifyingCoachId: data['verifyingCoachId'] as String?,
      coachName: data['coachName'] as String?,
      academyName: data['academyName'] as String?,
      verificationHash: data['verificationHash'] as String? ?? 'SEC-2026-VAL',
    );
  }

  Map<String, dynamic> toMap() => {
    'playerId': playerId,
    'playerName': playerName,
    'sport': sport,
    'tier': tier,
    'title': title,
    'requiredXp': requiredXp,
    'awardedAt': Timestamp.fromDate(awardedAt),
    'verifyingCoachId': verifyingCoachId,
    'coachName': coachName,
    'academyName': academyName,
    'verificationHash': verificationHash,
  };
}
