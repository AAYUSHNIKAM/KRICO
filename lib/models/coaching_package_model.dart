import 'package:cloud_firestore/cloud_firestore.dart';

enum EscrowState {
  paymentPending,
  escrowHeld,
  partiallyReleased,
  completed,
  refunded,
  disputed;

  static EscrowState fromString(String? value) {
    switch (value) {
      case 'escrow_held':
        return EscrowState.escrowHeld;
      case 'partially_released':
        return EscrowState.partiallyReleased;
      case 'completed':
        return EscrowState.completed;
      case 'refunded':
        return EscrowState.refunded;
      case 'disputed':
        return EscrowState.disputed;
      default:
        return EscrowState.paymentPending;
    }
  }

  String get label {
    switch (this) {
      case EscrowState.paymentPending:
        return 'Payment Pending';
      case EscrowState.escrowHeld:
        return 'Funds in Escrow';
      case EscrowState.partiallyReleased:
        return 'In Progress';
      case EscrowState.completed:
        return 'Package Completed';
      case EscrowState.refunded:
        return 'Refunded';
      case EscrowState.disputed:
        return 'Under Dispute';
    }
  }
}

class CoachingPackageModel {
  final String id;
  final String title;
  final String coachId;
  final String coachName;
  final String playerId;
  final String playerName;
  final String sport;
  final int totalSessions;
  final int completedSessions;
  final double totalAmount;
  final double platformFeeRate;
  final EscrowState escrowState;
  final DateTime createdAt;
  final DateTime? lastSessionCompletedAt;

  CoachingPackageModel({
    required this.id,
    required this.title,
    required this.coachId,
    required this.coachName,
    required this.playerId,
    required this.playerName,
    required this.sport,
    required this.totalSessions,
    this.completedSessions = 0,
    required this.totalAmount,
    this.platformFeeRate = 0.10,
    this.escrowState = EscrowState.escrowHeld,
    required this.createdAt,
    this.lastSessionCompletedAt,
  });

  double get platformFee => totalAmount * platformFeeRate;
  double get netCoachAmount => totalAmount - platformFee;
  double get payoutPerSession => totalSessions > 0 ? netCoachAmount / totalSessions : 0;
  double get releasedAmount => completedSessions * payoutPerSession;
  double get remainingEscrow => netCoachAmount - releasedAmount;
  double get progressPercentage => totalSessions > 0 ? (completedSessions / totalSessions).clamp(0.0, 1.0) : 0.0;
  int get remainingSessions => (totalSessions - completedSessions).clamp(0, totalSessions);

  factory CoachingPackageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CoachingPackageModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Coaching Package',
      coachId: data['coachId'] as String? ?? '',
      coachName: data['coachName'] as String? ?? 'Coach',
      playerId: data['playerId'] as String? ?? '',
      playerName: data['playerName'] as String? ?? 'Athlete',
      sport: data['sport'] as String? ?? 'General',
      totalSessions: (data['totalSessions'] as num?)?.toInt() ?? 1,
      completedSessions: (data['completedSessions'] as num?)?.toInt() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      platformFeeRate: (data['platformFeeRate'] as num?)?.toDouble() ?? 0.10,
      escrowState: EscrowState.fromString(data['escrowState'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSessionCompletedAt: (data['lastSessionCompletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'coachId': coachId,
      'coachName': coachName,
      'playerId': playerId,
      'playerName': playerName,
      'sport': sport,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalAmount': totalAmount,
      'platformFeeRate': platformFeeRate,
      'escrowState': escrowState.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastSessionCompletedAt != null)
        'lastSessionCompletedAt': Timestamp.fromDate(lastSessionCompletedAt!),
    };
  }
}
