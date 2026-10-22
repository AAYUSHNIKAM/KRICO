import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Rapid media picking, compression and upload service.
/// Compresses images on-device before uploading to ensure lightning-fast operations.
class MediaUploadService {
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final ImagePicker _picker = ImagePicker();

  MediaUploadService(this._storage, this._firestore);

  /// Picks an image from gallery or camera with high-speed native compression.
  /// Downsamples to max 900x900 at 70% quality (~80-150KB output).
  Future<Uint8List?> pickCompressedImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 65,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (picked == null) return null;
      return await picked.readAsBytes();
    } catch (e) {
      debugPrint('MediaUploadService.pickCompressedImage error: $e');
      rethrow;
    }
  }

  /// Rapidly uploads bytes to Firebase Storage with automatic data-URL fallback.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String storagePath,
    String contentType = 'image/jpeg',
    Duration timeout = const Duration(milliseconds: 3200),
  }) async {
    try {
      final ref = _storage.ref(storagePath);
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      final snapshot = await uploadTask.timeout(timeout);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Storage upload failed ($e). Falling back to optimized base64 data URI.');
      // Fallback: If under 900KB, return base64 data URI so user is never blocked
      if (bytes.lengthInBytes <= 950 * 1024) {
        return 'data:$contentType;base64,${base64Encode(bytes)}';
      }
      rethrow;
    }
  }

  /// Uploads user profile picture (DP) and synchronizes users and role collections.
  Future<String> updateUserProfilePicture({
    required String userId,
    required Uint8List bytes,
  }) async {
    final path = 'profile_photos/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final photoUrl = await uploadBytes(
      bytes: bytes,
      storagePath: path,
      contentType: 'image/jpeg',
    );

    // Update users collection
    await _firestore.collection('users').doc(userId).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Synchronize role collections in parallel
    final batch = _firestore.batch();
    batch.set(_firestore.collection('players').doc(userId), {'photoUrl': photoUrl}, SetOptions(merge: true));
    batch.set(_firestore.collection('coaches').doc(userId), {'photoUrl': photoUrl}, SetOptions(merge: true));
    batch.set(_firestore.collection('academies').doc(userId), {'photoUrl': photoUrl, 'logoUrl': photoUrl}, SetOptions(merge: true));
    await batch.commit();

    return photoUrl;
  }
}
