import 'package:cloud_firestore/cloud_firestore.dart';

enum ContractStatus { draft, pending, active, completed, cancelled, disputed }

enum ContractType { coaching, academy, subscription }

class ContractModel {
  const ContractModel({
    required this.contractId,
    required this.type,
    required this.partyAId,
    required this.partyBId,
    required this.partyARole,
    required this.partyBRole,
    this.amount = 0,
    this.platformFee = 0,
    this.opportunityFee = 0,
    this.contractSavings = 0,
    this.totalAmount = 0,
    this.status = ContractStatus.draft,
    this.startDate,
    this.endDate,
    this.terms,
    this.digitalSignatureA,
    this.digitalSignatureB,
    this.signedAtA,
    this.signedAtB,
    this.isEscrowActive = false,
    this.escrowReleaseDate,
    this.createdAt,
    this.updatedAt,
  });

  final String contractId;
  final ContractType type;
  final String partyAId;
  final String partyBId;
  final String partyARole;
  final String partyBRole;
  final double amount;
  final double platformFee;
  final double opportunityFee;
  final double contractSavings;
  final double totalAmount;
  final ContractStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? terms;
  final String? digitalSignatureA;
  final String? digitalSignatureB;
  final DateTime? signedAtA;
  final DateTime? signedAtB;
  final bool isEscrowActive;
  final DateTime? escrowReleaseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ContractModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ContractModel(
      contractId: doc.id,
      type: _parseType(data['type'] as String? ?? 'coaching'),
      partyAId: data['partyAId'] as String? ?? '',
      partyBId: data['partyBId'] as String? ?? '',
      partyARole: data['partyARole'] as String? ?? '',
      partyBRole: data['partyBRole'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      platformFee: (data['platformFee'] as num?)?.toDouble() ?? 0,
      opportunityFee: (data['opportunityFee'] as num?)?.toDouble() ?? 0,
      contractSavings: (data['contractSavings'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(data['status'] as String? ?? 'draft'),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      terms: data['terms'] as String?,
      digitalSignatureA: data['digitalSignatureA'] as String?,
      digitalSignatureB: data['digitalSignatureB'] as String?,
      signedAtA: (data['signedAtA'] as Timestamp?)?.toDate(),
      signedAtB: (data['signedAtB'] as Timestamp?)?.toDate(),
      isEscrowActive: data['isEscrowActive'] as bool? ?? false,
      escrowReleaseDate: (data['escrowReleaseDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'partyAId': partyAId,
    'partyBId': partyBId,
    'partyARole': partyARole,
    'partyBRole': partyBRole,
    'amount': amount,
    'platformFee': platformFee,
    'opportunityFee': opportunityFee,
    'contractSavings': contractSavings,
    'totalAmount': totalAmount,
    'status': status.name,
    'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'terms': terms,
    'digitalSignatureA': digitalSignatureA,
    'digitalSignatureB': digitalSignatureB,
    'signedAtA': signedAtA != null ? Timestamp.fromDate(signedAtA!) : null,
    'signedAtB': signedAtB != null ? Timestamp.fromDate(signedAtB!) : null,
    'isEscrowActive': isEscrowActive,
    'escrowReleaseDate': escrowReleaseDate != null ? Timestamp.fromDate(escrowReleaseDate!) : null,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static ContractType _parseType(String type) {
    switch (type) {
      case 'coaching':
        return ContractType.coaching;
      case 'academy':
        return ContractType.academy;
      case 'subscription':
        return ContractType.subscription;
      default:
        return ContractType.coaching;
    }
  }

  static ContractStatus _parseStatus(String status) {
    switch (status) {
      case 'draft':
        return ContractStatus.draft;
      case 'pending':
        return ContractStatus.pending;
      case 'active':
        return ContractStatus.active;
      case 'completed':
        return ContractStatus.completed;
      case 'cancelled':
        return ContractStatus.cancelled;
      case 'disputed':
        return ContractStatus.disputed;
      default:
        return ContractStatus.draft;
    }
  }
}
