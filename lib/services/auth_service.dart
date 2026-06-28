import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService(this._auth, this._firestore, this._storage);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(credential.user!.uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    return _auth.signInWithProvider(googleProvider);
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? city,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final user = UserModel(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      role: role,
      city: city,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());

    if (role == UserRole.coach) {
      await _firestore.collection('coaches').doc(uid).set({
        'coachId': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'isSubscribed': false,
        'subscriptionTier': 'Starter',
        'rating': 0.0,
        'totalReviews': 0,
        'isVerified': false,
        'experience': 0,
        'hourlyRate': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (role == UserRole.academy) {
      await _firestore.collection('academies').doc(uid).set({
        'academyId': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'reputationPoints': 0,
        'coachPlacements': 0,
        'totalStudents': 0,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (role == UserRole.player) {
      await _firestore.collection('players').doc(uid).set({
        'playerId': uid,
        'parentId': uid,
        'name': name,
        'points': 0,
        'rank': 0,
        'championshipWins': 0,
        'tournamentPoints': 0,
        'level': 'Beginner',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<String?> uploadProfilePhoto(String uid, String filePath) async {
    try {
      final ref = _storage.ref('profile_photos/$uid');
      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      await updateProfile(uid, {'photoUrl': url});
      return url;
    } catch (e) {
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('User not logged in');
    final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  // --- Coupon Management ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoupons() {
    return _firestore.collection('coupons').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addCoupon({
    required String code,
    required String discount,
    required String eligibility,
  }) async {
    await _firestore.collection('coupons').add({
      'code': code.toUpperCase(),
      'discount': discount,
      'eligibility': eligibility,
      'status': 'Active',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleCouponStatus(String couponId, bool isActive) async {
    await _firestore.collection('coupons').doc(couponId).update({
      'isActive': isActive,
      'status': isActive ? 'Active' : 'Expired',
    });
  }

  // --- Admin Task Management ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getAdminTasks() {
    return _firestore.collection('adminTasks').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addAdminTask({
    required String title,
    required String status,
    required String priority,
  }) async {
    await _firestore.collection('adminTasks').add({
      'title': title,
      'status': status,
      'priority': priority,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Active Users ---

  Future<int> getActiveUsersCount() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snap = await _firestore
        .collection('users')
        .where('lastLoginAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();
    return snap.docs.length;
  }

  Stream<int> activeUsersStream() {
    return _firestore
        .collection('users')
        .where('lastLoginAt', isGreaterThan: Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 30)),
        ))
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
