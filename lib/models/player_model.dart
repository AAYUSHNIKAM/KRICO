import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class PlayerModel {
  const PlayerModel({
    required this.playerId,
    required this.parentId,
    required this.name,
    this.age,
    this.sports,
    this.level,
    this.rank = 0,
    this.points = 0,
    this.championshipWins = 0,
    this.tournamentPoints = 0,
    this.avatarUrl,
    this.coachId,
    this.academyId,
    this.readinessStatus = 'Fundamentals',
    this.consistencyStreak = 1,
    this.lastSessionTime,
    this.highestCertificateTitle,
    this.highestCertificateTier,
    this.totalPbs = 0,
    this.totalDrills = 0,
    this.emergencyContact,
    this.medicalNotes,
    this.bloodGroup,
    this.schoolOrClub,
    this.createdAt,
    this.updatedAt,
  });

  final String playerId;
  final String parentId;
  final String name;
  final int? age;
  final List<String>? sports;
  final String? level;
  final int rank;
  final int points;
  final int championshipWins;
  final int tournamentPoints;
  final String? avatarUrl;
  final String? coachId;
  final String? academyId;
  final String readinessStatus;
  final int consistencyStreak;
  final DateTime? lastSessionTime;
  final String? highestCertificateTitle;
  final int? highestCertificateTier;
  final int totalPbs;
  final int totalDrills;
  final String? emergencyContact;
  final String? medicalNotes;
  final String? bloodGroup;
  final String? schoolOrClub;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PlayerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PlayerModel(
      playerId: doc.id,
      parentId: data['parentId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      age: data['age'] as int?,
      sports: (data['sports'] as List<dynamic>?)?.cast<String>(),
      level: data['level'] as String?,
      rank: (data['rank'] as num?)?.toInt() ?? 0,
      points: (data['points'] as num?)?.toInt() ?? 0,
      championshipWins: (data['championshipWins'] as num?)?.toInt() ?? 0,
      tournamentPoints: (data['tournamentPoints'] as num?)?.toInt() ?? 0,
      avatarUrl: data['avatarUrl'] as String?,
      coachId: data['coachId'] as String?,
      academyId: data['academyId'] as String?,
      readinessStatus: data['readinessStatus'] as String? ?? 'Fundamentals',
      consistencyStreak: (data['consistencyStreak'] as num?)?.toInt() ?? 1,
      lastSessionTime: parseTimestamp(data['lastSessionTime']),
      highestCertificateTitle: data['highestCertificateTitle'] as String?,
      highestCertificateTier: (data['highestCertificateTier'] as num?)?.toInt(),
      totalPbs: (data['totalPbs'] as num?)?.toInt() ?? 0,
      totalDrills: (data['totalDrills'] as num?)?.toInt() ?? 0,
      emergencyContact: data['emergencyContact'] as String?,
      medicalNotes: data['medicalNotes'] as String?,
      bloodGroup: data['bloodGroup'] as String?,
      schoolOrClub: data['schoolOrClub'] as String?,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'parentId': parentId,
    'name': name,
    'age': age,
    'sports': sports,
    'level': level,
    'rank': rank,
    'points': points,
    'championshipWins': championshipWins,
    'tournamentPoints': tournamentPoints,
    'avatarUrl': avatarUrl,
    'coachId': coachId,
    'academyId': academyId,
    'readinessStatus': readinessStatus,
    'consistencyStreak': consistencyStreak,
    'lastSessionTime': lastSessionTime != null ? Timestamp.fromDate(lastSessionTime!) : null,
    'highestCertificateTitle': highestCertificateTitle,
    'highestCertificateTier': highestCertificateTier,
    'totalPbs': totalPbs,
    'totalDrills': totalDrills,
    'emergencyContact': emergencyContact,
    'medicalNotes': medicalNotes,
    'bloodGroup': bloodGroup,
    'schoolOrClub': schoolOrClub,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  PlayerModel copyWith({
    String? playerId,
    String? parentId,
    String? name,
    int? age,
    List<String>? sports,
    String? level,
    int? rank,
    int? points,
    int? championshipWins,
    int? tournamentPoints,
    String? avatarUrl,
    String? coachId,
    String? academyId,
    String? readinessStatus,
    int? consistencyStreak,
    DateTime? lastSessionTime,
    String? highestCertificateTitle,
    int? highestCertificateTier,
    int? totalPbs,
    int? totalDrills,
    String? emergencyContact,
    String? medicalNotes,
    String? bloodGroup,
    String? schoolOrClub,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PlayerModel(
        playerId: playerId ?? this.playerId,
        parentId: parentId ?? this.parentId,
        name: name ?? this.name,
        age: age ?? this.age,
        sports: sports ?? this.sports,
        level: level ?? this.level,
        rank: rank ?? this.rank,
        points: points ?? this.points,
        championshipWins: championshipWins ?? this.championshipWins,
        tournamentPoints: tournamentPoints ?? this.tournamentPoints,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        coachId: coachId ?? this.coachId,
        academyId: academyId ?? this.academyId,
        readinessStatus: readinessStatus ?? this.readinessStatus,
        consistencyStreak: consistencyStreak ?? this.consistencyStreak,
        lastSessionTime: lastSessionTime ?? this.lastSessionTime,
        highestCertificateTitle: highestCertificateTitle ?? this.highestCertificateTitle,
        highestCertificateTier: highestCertificateTier ?? this.highestCertificateTier,
        totalPbs: totalPbs ?? this.totalPbs,
        totalDrills: totalDrills ?? this.totalDrills,
        emergencyContact: emergencyContact ?? this.emergencyContact,
        medicalNotes: medicalNotes ?? this.medicalNotes,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        schoolOrClub: schoolOrClub ?? this.schoolOrClub,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
