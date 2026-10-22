import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Aggregates everything needed to render a public profile for any role
/// (player / coach / academy / parent) and provides the follow system
/// plus streak computation.
class ProfileService {
  ProfileService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  /// The role-specific profile document (players / coaches / academies).
  Future<Map<String, dynamic>?> getRoleProfile(String uid, String role) async {
    final collection = switch (role) {
      'player' => 'players',
      'coach' => 'coaches',
      'academy' => 'academies',
      _ => null,
    };
    if (collection == null) return null;
    final doc = await _firestore.collection(collection).doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Stream<List<Map<String, dynamic>>> getUserPosts(String uid) {
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final posts = snap.docs
              .map((d) => {...d.data(), 'docId': d.id})
              .toList();
          posts.sort((a, b) {
            final aT = a['createdAt'] as Timestamp?;
            final bT = b['createdAt'] as Timestamp?;
            if (aT == null && bT == null) return 0;
            if (aT == null) return 1;
            if (bT == null) return -1;
            return bT.toDate().compareTo(aT.toDate());
          });
          return posts;
        });
  }

  Stream<List<Map<String, dynamic>>> getUserMetrics(String uid) {
    return _firestore
        .collection('playerMetrics')
        .where('playerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'docId': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> getUserAchievements(String uid) {
    return _firestore
        .collection('playerAchievements')
        .where('playerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'docId': d.id}).toList());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserSessions(String uid) {
    return _firestore
        .collection('sessions')
        .where('playerId', isEqualTo: uid)
        .snapshots();
  }

  // ---------------------------------------------------------------------
  // Follow system
  // ---------------------------------------------------------------------

  Future<void> follow(String followerId, String followedId) async {
    final ref = _firestore.collection('follows').doc('${followerId}_$followedId');
    final batch = _firestore.batch();
    batch.set(ref, {
      'followerId': followerId,
      'followedId': followedId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('users').doc(followedId), {
      'followersCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('users').doc(followerId), {
      'followingCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> unfollow(String followerId, String followedId) async {
    final ref = _firestore.collection('follows').doc('${followerId}_$followedId');
    final batch = _firestore.batch();
    batch.delete(ref);
    batch.update(_firestore.collection('users').doc(followedId), {
      'followersCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('users').doc(followerId), {
      'followingCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<bool> isFollowing(String followerId, String followedId) async {
    final doc = await _firestore
        .collection('follows')
        .doc('${followerId}_$followedId')
        .get();
    return doc.exists;
  }

  Stream<List<UserModel>> getFollowers(String uid) {
    return _firestore
        .collection('follows')
        .where('followedId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snap) async {
          final users = <UserModel>[];
          for (final d in snap.docs) {
            final followerId = d.data()['followerId'] as String?;
            if (followerId == null) continue;
            final user = await getUserProfile(followerId);
            if (user != null) users.add(user);
          }
          users.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0);
          return users;
        });
  }

  Stream<List<UserModel>> getFollowing(String uid) {
    return _firestore
        .collection('follows')
        .where('followerId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snap) async {
          final users = <UserModel>[];
          for (final d in snap.docs) {
            final followedId = d.data()['followedId'] as String?;
            if (followedId == null) continue;
            final user = await getUserProfile(followedId);
            if (user != null) users.add(user);
          }
          users.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0);
          return users;
        });
  }

  // ---------------------------------------------------------------------
  // Streaks
  // ---------------------------------------------------------------------

  /// Computes the current consecutive-day activity streak for a user based
  /// on their posts, logged metrics and booked sessions.
  Future<int> getCurrentStreak(String uid) async {
    final dates = <DateTime>{};

    final postsSnap = await _firestore
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .get();
    for (final d in postsSnap.docs) {
      _addDate(dates, d.data()['createdAt']);
    }

    final metricsSnap = await _firestore
        .collection('playerMetrics')
        .where('playerId', isEqualTo: uid)
        .get();
    for (final d in metricsSnap.docs) {
      _addDate(dates, d.data()['loggedAt']);
    }

    final sessionsSnap = await _firestore
        .collection('sessions')
        .where('playerId', isEqualTo: uid)
        .get();
    for (final d in sessionsSnap.docs) {
      _addDate(dates, d.data()['dateTime']);
    }

    return _computeStreak(dates.toList());
  }

  void _addDate(Set<DateTime> dates, dynamic value) {
    if (value is Timestamp) {
      final t = value.toDate();
      dates.add(DateTime(t.year, t.month, t.day));
    }
  }

  int _computeStreak(List<DateTime> dateTimes) {
    final dates = dateTimes
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();
    if (dates.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? cursor;
    if (dates.contains(today)) {
      cursor = today;
    } else if (dates.contains(yesterday)) {
      cursor = yesterday;
    }

    var streak = 0;
    while (cursor != null && dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
