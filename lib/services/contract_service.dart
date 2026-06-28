import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/contract_model.dart';

class ContractService {
  ContractService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ContractModel>> getUserContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('partyAId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final contracts = snap.docs.map((doc) => ContractModel.fromDoc(doc)).toList();
          contracts.sort((a, b) {
            final aTime = a.createdAt ?? DateTime(0);
            final bTime = b.createdAt ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
          return contracts;
        });
  }

  Stream<ContractModel> getContract(String contractId) {
    return _firestore
        .collection('contracts')
        .doc(contractId)
        .snapshots()
        .map((doc) => ContractModel.fromDoc(doc));
  }

  Future<String> createContract(ContractModel contract) async {
    final docRef = _firestore.collection('contracts').doc(contract.contractId);
    await docRef.set(contract.toMap());
    return contract.contractId;
  }

  Future<void> signContract(String contractId, String party, String signature) async {
    final update = <String, dynamic>{
      if (party == 'A') ...{
        'digitalSignatureA': signature,
        'signedAtA': FieldValue.serverTimestamp(),
      } else ...{
        'digitalSignatureB': signature,
        'signedAtB': FieldValue.serverTimestamp(),
      },
    };
    await _firestore.collection('contracts').doc(contractId).update(update);
  }

  Future<void> updateStatus(String contractId, ContractStatus status) async {
    await _firestore.collection('contracts').doc(contractId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<double> getTotalRevenueStream() {
    return _firestore
        .collection('contracts')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) {
      double total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        total += (data['platformFee'] as num?)?.toDouble() ?? 0;
      }
      return total;
    });
  }

  static ContractModel draftContract({
    required String partyAId,
    required String partyBId,
    required String partyARole,
    required String partyBRole,
    required ContractType type,
    required double amount,
    String? terms,
  }) {
    final contractId = const Uuid().v4();
    final platformFee = amount * 0.10;
    final opportunityFee = amount * 0.10;
    final contractSavings = amount * 0.10;
    final totalAmount = amount + platformFee + opportunityFee - contractSavings;

    return ContractModel(
      contractId: contractId,
      type: type,
      partyAId: partyAId,
      partyBId: partyBId,
      partyARole: partyARole,
      partyBRole: partyBRole,
      amount: amount,
      platformFee: platformFee,
      opportunityFee: opportunityFee,
      contractSavings: contractSavings,
      totalAmount: totalAmount,
      status: ContractStatus.draft,
      terms: terms,
      isEscrowActive: true,
      createdAt: DateTime.now(),
    );
  }
}
