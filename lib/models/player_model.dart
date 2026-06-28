import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

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
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
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
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
