import '../../../design_system/colors/app_colors.dart';
import '../../../models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../models/post_model.dart';
import '../../../models/certificate_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_providers.dart';
import '../../../services/providers.dart';
import '../../../services/firebase_service.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _postCtrl = TextEditingController();
  bool _isPosting = false;
  String _selectedSport = 'All';
  String _postingSport = 'General';
  bool _isMatchInvite = false;
  Uint8List? _attachedBytes;
  String? _attachedFileName;
  bool _isVideo = false;

  static const List<String> _sportsList = [
    'All',
    'General',
    'Badminton',
    'Cricket',
    'Football',
    'Tennis',
    'Athletics',
    'Basketball',
    'Swimming',
  ];

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment({required bool isVideo}) async {
    final picker = ImagePicker();
    XFile? file;
    try {
      if (!isVideo) {
        final compressed = await ref.read(mediaUploadServiceProvider).pickCompressedImage(
          maxWidth: 900,
          maxHeight: 900,
          imageQuality: 70,
        );
        if (compressed != null) {
          setState(() {
            _attachedBytes = compressed;
            _attachedFileName = 'photo_\.jpg';
            _isVideo = false;
          });
          return;
        }
      }
      file = await picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final maxBytes = isVideo ? 25 * 1024 * 1024 : 5 * 1024 * 1024; // 25 MB video, 5 MB image
      if (bytes.lengthInBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File exceeds ${isVideo ? '25 MB' : '5 MB'} limit (${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)} MB). Please choose a smaller ${isVideo ? 'video' : 'image'}.',
              ),
              backgroundColor: const Color(0xFFE11D48),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() {
        _attachedBytes = bytes;
        _attachedFileName = file!.name;
        _isVideo = isVideo;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createPost(String currentUserId, String authorName, String authorRole, String? authorAvatar) async {
    final text = _postCtrl.text.trim();
    if (text.isEmpty && _attachedBytes == null) return;

    setState(() => _isPosting = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('posts').doc();
      String? mediaUrl;

      if (_attachedBytes != null) {
        try {
          final storage = ref.read(storageProvider);
          final ext = _isVideo ? 'mp4' : 'jpg';
          final mimeType = _isVideo ? 'video/mp4' : 'image/jpeg';
          final sRef = storage.ref('community_posts/${docRef.id}_${DateTime.now().millisecondsSinceEpoch}.$ext');
          final uploadTask = sRef.putData(
            _attachedBytes!,
            SettableMetadata(contentType: mimeType),
          );
          final snap = await uploadTask.timeout(const Duration(milliseconds: 3200));
          mediaUrl = await snap.ref.getDownloadURL();
        } catch (storageError) {
          debugPrint('Storage upload error: $storageError');
          // Fallback: If image and under 800KB, embed data URI so media is never lost
          if (!_isVideo && _attachedBytes != null && _attachedBytes!.lengthInBytes <= 800 * 1024) {
            mediaUrl = 'data:image/jpeg;base64,${base64Encode(_attachedBytes!)}';
          }
        }
      }

      String? certBadge;
      String? certTitle;
      if (authorRole.toLowerCase() == 'player') {
        try {
          final pSnap = await FirebaseFirestore.instance.collection('players').doc(currentUserId).get();
          if (pSnap.exists) {
            certTitle = pSnap.data()?['highestCertificateTitle'] as String?;
            final certTier = (pSnap.data()?['highestCertificateTier'] as num?)?.toInt();
            if (certTier != null) {
              certBadge = CertificateRegistry.allTiers.firstWhere((t) => t.tier == certTier, orElse: () => CertificateRegistry.allTiers.first).crestBadge;
            }
          }
        } catch (_) {}
      }

      final post = CommunityPostModel(
        id: docRef.id,
        authorId: currentUserId,
        authorName: authorName,
        authorRole: authorRole,
        authorAvatarUrl: authorAvatar,
        authorCertificateBadge: certBadge,
        authorCertificateTitle: certTitle,
        content: text,
        sport: _postingSport,
        mediaUrl: mediaUrl,
        createdAt: DateTime.now(),
      );

      await docRef.set(post.toMap());

      if (mounted) {
        _postCtrl.clear();
        setState(() {
          _isMatchInvite = false;
          _attachedBytes = null;
          _attachedFileName = null;
          _isVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFFCCFF00), size: 20),
                SizedBox(width: 8),
                Text('Published to Sports Community!'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share post: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _confirmDeletePost(CommunityPostModel post) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131D31) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Post?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this post? This action is permanent and cannot be undone.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Delete Post', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFFCCFF00), size: 18),
                  SizedBox(width: 8),
                  Text('Post deleted successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete post: $e'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleLike(CommunityPostModel post, String? currentUserId) async {
    if (currentUserId == null) return;
    final isLiked = post.likedUserIds.contains(currentUserId);
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);

    HapticFeedback.lightImpact();
    try {
      if (isLiked) {
        await postRef.update({
          'likesCount': FieldValue.increment(-1),
          'likedUserIds': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        await postRef.update({
          'likesCount': FieldValue.increment(1),
          'likedUserIds': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (_) {}
  }

  void _openComments(CommunityPostModel post, String? currentUserId, String currentUserName, String? currentUserAvatar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentsSheet(
        post: post,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
      ),
    );
  }

  void _showStoryHighFivesSheet(BuildContext parentContext, String? storyId, List<dynamic> highFivers) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        Widget buildContent(List<dynamic> currentHighFivers) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.65),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D31) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✋', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'High-Fives Received (${currentHighFivers.length})',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (currentHighFivers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      children: [
                        Icon(Icons.pan_tool_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No High-Fives Yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to cheer and celebrate this story!',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: currentHighFivers.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      ),
                      itemBuilder: (c, idx) {
                        final item = currentHighFivers[idx] is Map<String, dynamic>
                            ? (currentHighFivers[idx] as Map<String, dynamic>)
                            : <String, dynamic>{};
                        return _HighFiverTile(
                          item: item,
                          isDark: isDark,
                          onTap: () {
                            Navigator.pop(ctx);
                            final fiverUid = item['uid'] as String? ?? '';
                            if (fiverUid.isNotEmpty) {
                              context.push('/profile/$fiverUid');
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }

        if (storyId != null && storyId.isNotEmpty) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('community_stories').doc(storyId).snapshots(),
            builder: (context, snapshot) {
              final docData = snapshot.data?.data();
              final list = (docData?['highFivers'] as List<dynamic>?) ?? highFivers;
              return buildContent(list);
            },
          );
        }
        return buildContent(highFivers);
      },
    );
  }

  void _openStoryDialog(
    String name,
    String sport,
    String imagePath,
    String caption, {
    String? recipientId,
    String? storyId,
    List<dynamic>? initialHighFivers,
  }) {
    final liveHighFivers = List<dynamic>.from(initialHighFivers ?? []);
    final currentUserId = ref.read(authStateProvider).value?.uid ?? '';
    final isAuthor = currentUserId.isNotEmpty && recipientId == currentUserId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 620),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: (imagePath.startsWith('http')
                    ? NetworkImage(imagePath)
                    : (imagePath.startsWith('data:')
                        ? MemoryImage(base64Decode(imagePath.split(',').last))
                        : AssetImage(imagePath))) as ImageProvider,
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: (imagePath.startsWith('http')
                            ? NetworkImage(imagePath)
                            : (imagePath.startsWith('data:')
                                ? MemoryImage(base64Decode(imagePath.split(',').last))
                                : AssetImage(imagePath))) as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(sport.toUpperCase(), style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const Spacer(),
                      // High-Fives Viewer Pill (Eye / Hand Symbol)
                      InkWell(
                        onTap: () => _showStoryHighFivesSheet(context, storyId, liveHighFivers),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✋', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '${liveHighFivers.length}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.visibility_rounded, size: 14, color: Color(0xFFCCFF00)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caption,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      if (isAuthor)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _showStoryHighFivesSheet(context, storyId, liveHighFivers);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCCFF00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Text('✋', style: TextStyle(fontSize: 16)),
                            label: Text('View High-Fives (${liveHighFivers.length})', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  final authState = ref.read(authStateProvider);
                                  final senderId = authState.value?.uid ?? 'guest';
                                  final userProfile = senderId.isNotEmpty
                                      ? (ref.read(publicUserProfileProvider(senderId)).value)
                                      : null;
                                  final senderName = userProfile?.name.trim().isNotEmpty == true
                                      ? userProfile!.name
                                      : (ref.read(authServiceProvider).currentUser?.displayName?.trim().isNotEmpty == true
                                          ? ref.read(authServiceProvider).currentUser!.displayName!
                                          : 'Athlete');
                                  final senderUsername = userProfile?.username ??
                                      (senderName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''));
                                  final senderAvatar = userProfile?.photoUrl ?? ref.read(authServiceProvider).currentUser?.photoURL;
                                  final senderRole = userProfile?.role.name ?? 'player';
                                  final targetId = recipientId ?? name.toLowerCase().replaceAll(' ', '_');

                                  // 1. Record High Five in Firestore Story document
                                  if (storyId != null && storyId.isNotEmpty) {
                                    try {
                                      await FirebaseFirestore.instance.collection('community_stories').doc(storyId).set({
                                        'highFivers': FieldValue.arrayUnion([
                                          {
                                            'uid': senderId,
                                            'name': senderName,
                                            'username': senderUsername,
                                            'avatar': senderAvatar ?? '',
                                            'role': senderRole,
                                            'timestamp': Timestamp.now(),
                                          }
                                        ]),
                                        'highFivesCount': FieldValue.increment(1),
                                      }, SetOptions(merge: true));
                                    } catch (e) {
                                      debugPrint('Failed to save high five in story: $e');
                                    }
                                  }

                                  // 2. Send decorated chat message and in-app notification
                                  try {
                                    final chatId = await ref.read(chatServiceProvider).getOrCreateDirectChat(
                                      senderId,
                                      targetId,
                                      starterMessage: '✋ High-Five from $senderName (@$senderUsername)! Crushing it in $sport! Keep pushing! 🔥',
                                      starterSenderId: senderId,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("✋ High-Five & decorated message sent to $name's inbox! 🚀"),
                                          backgroundColor: const Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            label: 'View Chat',
                                            textColor: Colors.black,
                                            onPressed: () => context.push('/chat/$chatId'),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('High-five sent to $name! ✋')),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCCFF00),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Text('✋', style: TextStyle(fontSize: 16)),
                                label: const Text('Send High-Five', style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'View High-Fivers',
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _showStoryHighFivesSheet(context, storyId, liveHighFivers);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white24,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.remove_red_eye_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid;
    final userProfileAsync = currentUserId != null ? ref.watch(publicUserProfileProvider(currentUserId)) : null;
    final currentUserModel = userProfileAsync?.value;

    final authorName = currentUserModel?.name ?? 'Athlete';
    final authorRole = currentUserModel?.role.name ?? 'player';
    final authorAvatar = currentUserModel?.photoUrl;

    final postsAsync = ref.watch(typedCommunityPostsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0E14) : const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: CustomScrollView(
            slivers: [
              // 1. Dynamic Athletic Header
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                elevation: 0,
                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/backgrounds/athletic_track.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              (isDark ? const Color(0xFF0B0E14) : Colors.white).withValues(alpha: 0.96),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFF00),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/animations/live_pulse.gif',
                                        width: 14,
                                        height: 14,
                                        errorBuilder: (_, _, _) => const Icon(Icons.circle, size: 8, color: Colors.black),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'ATHLETIC COMMUNITY FEED',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_alt_rounded, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        '520+ Online',
                                        style: AppTextStyles.captionXs.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Community Hub',
                              style: AppTextStyles.heading2.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Training Stories Reel with Dynamic Stories + Add Story
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: SizedBox(
                    height: 104,
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('community_stories')
                          .orderBy('createdAt', descending: true)
                          .limit(15)
                          .snapshots(),
                      builder: (ctx, snapshot) {
                        final dynamicStories = snapshot.data?.docs ?? [];
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildAddStoryBubble(currentUserModel),
                            for (final d in dynamicStories) ...[
                              _buildStoryBubble(
                                name: d.data()['authorName'] ?? 'Athlete',
                                sport: d.data()['sport'] ?? 'Training',
                                image: (d.data()['mediaUrl'] != null && (d.data()['mediaUrl'] as String).isNotEmpty)
                                    ? d.data()['mediaUrl']
                                    : (d.data()['authorAvatar'] != null && (d.data()['authorAvatar'] as String).isNotEmpty)
                                        ? d.data()['authorAvatar']
                                        : 'assets/avatars/athlete_youth.jpg',
                                hasUnseen: true,
                                onTap: () => _openStoryDialog(
                                  d.data()['authorName'] ?? 'Athlete',
                                  d.data()['sport'] ?? 'Training',
                                  (d.data()['mediaUrl'] != null && (d.data()['mediaUrl'] as String).isNotEmpty)
                                      ? d.data()['mediaUrl']
                                      : 'assets/images/sports/football_action.jpeg',
                                  d.data()['caption'] ?? 'Hard work beats talent when talent fails to work hard! 🔥',
                                  recipientId: d.data()['authorId'],
                                  storyId: d.id,
                                  initialHighFivers: (d.data()['highFivers'] as List<dynamic>?) ?? [],
                                ),
                              ),
                            ],
                            _buildStoryBubble(
                              name: 'Coach Vikram',
                              sport: 'Football',
                              image: 'assets/avatars/coach_trainer.jpg',
                              hasUnseen: true,
                              onTap: () => _openStoryDialog(
                                'Coach Vikram',
                                'Football Drill',
                                'assets/images/sports/football_action.jpeg',
                                'Speed ladder & cone drills session this evening at Balewadi Turf! ⚽🔥',
                                recipientId: 'coach_vikram',
                              ),
                            ),
                            _buildStoryBubble(
                              name: 'Ananya S.',
                              sport: 'Badminton',
                              image: 'assets/avatars/athlete_sprinter.jpg',
                              hasUnseen: true,
                              onTap: () => _openStoryDialog(
                                'Ananya S.',
                                'Badminton',
                                'assets/images/sports/badminton_smash.jpg',
                                'Working on overhead smash angles. 3 sets down, feeling explosive! 🏸⚡',
                                recipientId: 'ananya_s',
                              ),
                            ),
                            _buildStoryBubble(
                              name: 'Coach Rahul',
                              sport: 'Tennis',
                              image: 'assets/avatars/coach_experienced.jpg',
                              hasUnseen: false,
                              onTap: () => _openStoryDialog(
                                'Coach Rahul',
                                'Tennis Pro',
                                'assets/images/sports/tennis_racket.jpg',
                                'Grip tension & string elasticity testing for National Open.',
                                recipientId: 'coach_rahul',
                              ),
                            ),
                            _buildStoryBubble(
                              name: 'Aman K.',
                              sport: 'Basketball',
                              image: 'assets/avatars/athlete_youth.jpg',
                              hasUnseen: true,
                              onTap: () => _openStoryDialog(
                                'Aman K.',
                                'Basketball',
                                'assets/images/sports/basketball_hoop.webp',
                                'Sunset shooting practice. 80/100 from beyond the arc! 🏀',
                                recipientId: 'aman_k',
                              ),
                            ),
                            _buildStoryBubble(
                              name: 'Sports Hub',
                              sport: 'Academy',
                              image: 'assets/backgrounds/stadium_floodlights.jpg',
                              hasUnseen: true,
                              onTap: () => _openStoryDialog(
                                'Sports Hub',
                                'Weekend Tourney',
                                'assets/backgrounds/stadium_floodlights.jpg',
                                'Box Cricket & Turf Football Weekend registrations closing tonight!',
                                recipientId: 'sports_hub_academy',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 3. Featured Athlete of the Week Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Opacity(
                              opacity: 0.15,
                              child: Image.asset(
                                'assets/animations/trophy_badge.gif',
                                width: 140,
                                height: 140,
                                errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, size: 100, color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFCCFF00), width: 2),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/avatars/athlete_sprinter.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFCCFF00),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'SPOTLIGHT ATHLETE',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'NATIONAL U-19',
                                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Ananya Sen • 14 Sessions Completed',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Badminton singles district quarter-finalist.',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Modern Post Composer
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D31) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFCCFF00), width: 1.5),
                            ),
                            child: ClipOval(
                              child: authorAvatar != null
                                  ? Image.network(authorAvatar, fit: BoxFit.cover)
                                  : Image.asset(
                                      'assets/avatars/athlete_1.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(
                                          authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _postCtrl,
                              maxLines: 3,
                              minLines: 1,
                              style: AppTextStyles.body.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: _isMatchInvite
                                    ? 'Need players? (e.g. 2 players needed for football turf at 8 PM...)'
                                    : 'Share a training win, drill highlight, or match invitation...',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_attachedBytes != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCCFF00), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_isVideo ? Icons.videocam_rounded : Icons.image_rounded, size: 16, color: const Color(0xFFCCFF00)),
                              const SizedBox(width: 6),
                              Text(
                                '${_attachedFileName ?? (_isVideo ? "Video" : "Photo")} (${(_attachedBytes!.lengthInBytes / 1024).toStringAsFixed(0)} KB)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _attachedBytes = null;
                                  _attachedFileName = null;
                                  _isVideo = false;
                                }),
                                child: const Icon(Icons.close, size: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      // Responsive Action Bar
                      Row(
                        children: [
                          // Sport Tag Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _postingSport,
                                isDense: true,
                                icon: const Icon(Icons.arrow_drop_down, size: 16),
                                dropdownColor: isDark ? const Color(0xFF131D31) : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                                items: _sportsList.where((s) => s != 'All').map((sport) {
                                  return DropdownMenuItem(
                                    value: sport,
                                    child: Text(sport),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _postingSport = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Media attach icons (<500KB)
                          IconButton(
                            tooltip: 'Attach Photo (<500KB)',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(Icons.photo_camera_outlined, size: 18, color: isDark ? Colors.white70 : Colors.black87),
                            onPressed: () => _pickAttachment(isVideo: false),
                          ),
                          IconButton(
                            tooltip: 'Attach Video (<500KB)',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(Icons.videocam_outlined, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                            onPressed: () => _pickAttachment(isVideo: true),
                          ),
                          // Pickup Match Toggle
                          GestureDetector(
                            onTap: () => setState(() => _isMatchInvite = !_isMatchInvite),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isMatchInvite
                                    ? const Color(0xFFFF4D00).withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: _isMatchInvite ? Border.all(color: const Color(0xFFFF4D00)) : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sports_score_rounded,
                                    size: 14,
                                    color: _isMatchInvite ? const Color(0xFFFF4D00) : Colors.grey,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Invite',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _isMatchInvite ? const Color(0xFFFF4D00) : (isDark ? Colors.white60 : Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Post Button (compact and clean, impossible to overflow)
                          ElevatedButton(
                            onPressed: (_isPosting || currentUserId == null)
                                ? null
                                : () => _createPost(currentUserId, authorName, authorRole, authorAvatar),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCCFF00),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: _isPosting
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Text(
                                    'POST',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Sport Filter Horizontal Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    itemCount: _sportsList.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final sport = _sportsList[index];
                      final isSelected = _selectedSport == sport;
                      return ChoiceChip(
                        label: Text(sport),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSport = sport);
                        },
                        selectedColor: const Color(0xFFCCFF00),
                        backgroundColor: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFCCFF00) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            width: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 6. Community Feed Stream
              postsAsync.when(
                data: (allPosts) {
                  final posts = _selectedSport == 'All'
                      ? allPosts
                      : allPosts.where((p) => p.sport.toLowerCase() == _selectedSport.toLowerCase()).toList();

                  if (posts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(SpacingScale.s32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/animations/sports_ball.gif',
                                width: 80,
                                height: 80,
                                errorBuilder: (_, _, _) => const Icon(Icons.sports_rounded, size: 48, color: Color(0xFFCCFF00)),
                              ),
                              const SizedBox(height: SpacingScale.s16),
                              Text(
                                _selectedSport == 'All' ? 'No posts yet' : 'No posts in $_selectedSport',
                                style: AppTextStyles.title2.copyWith(color: isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: SpacingScale.s6),
                              Text(
                                'Be the first athlete or coach to ignite the community feed!',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySm.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          final isLiked = currentUserId != null && post.likedUserIds.contains(currentUserId);

                          return _AthleticPostCard(
                            post: post,
                            isLiked: isLiked,
                            currentUserId: currentUserId,
                            isDark: isDark,
                            onLike: () => _toggleLike(post, currentUserId),
                            onComment: () => _openComments(post, currentUserId, authorName, authorAvatar),
                            onDelete: () => _confirmDeletePost(post),
                          ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.04, end: 0);
                        },
                        childCount: posts.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00))),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error loading posts: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildAddStoryBubble(UserModel? user) {
    final avatar = user?.photoUrl;

    return GestureDetector(
      onTap: () => _showAddStoryModal(context, user),
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFFCCFF00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F172A),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF1E293B),
                      backgroundImage: (avatar != null && avatar.isNotEmpty
                          ? (avatar.startsWith('http')
                              ? NetworkImage(avatar)
                              : (avatar.startsWith('data:')
                                  ? MemoryImage(base64Decode(avatar.split(',').last))
                                  : AssetImage(avatar)))
                          : const AssetImage('assets/avatars/athlete_youth.jpg')) as ImageProvider,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStoryModal(BuildContext context, UserModel? user) {
    final statusCtrl = TextEditingController();
    Uint8List? storyImageBytes;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded, color: Color(0xFF00E5FF), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Post Training Status / Story',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: statusCtrl,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "What's your workout highlight today? (e.g. Hit 5k in 21 mins! 🔥)",
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                if (storyImageBytes != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.memory(storyImageBytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          top: 4, right: 4,
                          child: InkWell(
                            onTap: () => setModalState(() => storyImageBytes = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final compressed = await ref.read(mediaUploadServiceProvider).pickCompressedImage(
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 70,
                        );
                        if (compressed != null) {
                          setModalState(() => storyImageBytes = compressed);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00E5FF),
                        side: const BorderSide(color: Color(0xFF00E5FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                      label: const Text('Add Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : () async {
                        final text = statusCtrl.text.trim();
                        if (text.isEmpty && storyImageBytes == null) return;
                        setModalState(() => isSubmitting = true);
                        try {
                          final currentUserId = user?.uid ?? 'guest';
                          final authorName = (user?.name != null && user!.name.trim().isNotEmpty) ? user.name : 'Athlete';
                          final authorUsername = user?.username ?? (authorName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''));
                          final authorAvatar = user?.photoUrl ?? '';
                          final authorRole = user?.role.name ?? 'player';
                          final sport = 'Training';

                          String mediaUrl = '';
                          if (storyImageBytes != null) {
                            try {
                              mediaUrl = await ref.read(mediaUploadServiceProvider).uploadBytes(
                                storagePath: 'community_stories/${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                bytes: storyImageBytes!,
                                contentType: 'image/jpeg',
                              );
                            } catch (_) {
                              mediaUrl = 'data:image/jpeg;base64,' + base64Encode(storyImageBytes!);
                            }
                          }

                          await FirebaseFirestore.instance.collection('community_stories').add({
                            'authorId': currentUserId,
                            'authorName': authorName,
                            'authorUsername': authorUsername,
                            'authorAvatar': authorAvatar,
                            'authorRole': authorRole,
                            'sport': sport,
                            'caption': text,
                            'mediaUrl': mediaUrl,
                            'highFivers': [],
                            'highFivesCount': 0,
                            'createdAt': FieldValue.serverTimestamp(),
                            'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
                          });

                          if (bCtx.mounted) Navigator.pop(bCtx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚡ Story posted to Community Reel!'),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (bCtx.mounted) {
                            setModalState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to post story: ' + e.toString())),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Share Story', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

Widget _buildStoryBubble({
    required String name,
    required String sport,
    required String image,
    required bool hasUnseen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnseen
                    ? const LinearGradient(
                        colors: [Color(0xFFCCFF00), Color(0xFF00F59B), Color(0xFFFF4D00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F172A),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: (image.startsWith('http')
                      ? NetworkImage(image)
                      : (image.startsWith('data:')
                          ? MemoryImage(base64Decode(image.split(',').last))
                          : AssetImage(image))) as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name.split(' ').first,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AthleticPostCard extends StatelessWidget {
  final CommunityPostModel post;
  final bool isLiked;
  final String? currentUserId;
  final bool isDark;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onDelete;

  const _AthleticPostCard({
    required this.post,
    required this.isLiked,
    required this.currentUserId,
    required this.isDark,
    required this.onLike,
    required this.onComment,
    this.onDelete,
  });

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final isMatchInvite = post.content.toLowerCase().contains('match') ||
        post.content.toLowerCase().contains('players needed') ||
        post.content.toLowerCase().contains('sparring');
    final isAuthor = currentUserId != null && currentUserId == post.authorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isMatchInvite ? const Color(0xFFFF4D00).withValues(alpha: 0.35) : borderColor,
          width: isMatchInvite ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Author Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCCFF00), width: 1.5),
                    ),
                    child: ClipOval(
                      child: post.authorAvatarUrl != null
                          ? Image.network(post.authorAvatarUrl!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/avatars/athlete_1.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'A',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: post.authorRole.toLowerCase() == 'coach'
                                    ? Colors.blue.withValues(alpha: 0.15)
                                    : const Color(0xFFCCFF00).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                post.authorRole.toUpperCase(),
                                style: TextStyle(
                                  color: post.authorRole.toLowerCase() == 'coach'
                                      ? Colors.blue
                                      : (isDark ? const Color(0xFFCCFF00) : const Color(0xFF15803D)),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            if (post.authorCertificateBadge != null) ...[
                              const SizedBox(width: 4),
                              Tooltip(
                                message: post.authorCertificateTitle ?? 'Prestige Athlete',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFEAB308).withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(post.authorCertificateBadge!, style: const TextStyle(fontSize: 10)),
                                      if (post.authorCertificateTitle != null) ...[
                                        const SizedBox(width: 3),
                                        Text(
                                          post.authorCertificateTitle!,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFEAB308),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatTime(post.createdAt),
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            const SizedBox(width: 6),
                            Text(
                              post.sport.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isMatchInvite) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D00),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, size: 12, color: Colors.white),
                          SizedBox(width: 2),
                          Text('MATCH INVITE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (isAuthor && onDelete != null)
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Post Content Text
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  post.content,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
              ),

            // 3. User's Attached Media (ONLY shown if mediaUrl is not null & not empty)
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    child: post.mediaUrl!.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(post.mediaUrl!.split(',').last),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          )
                        : Image.network(
                            post.mediaUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 160,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(color: Color(0xFFCCFF00)),
                              );
                            },
                            errorBuilder: (_, _, _) => Container(
                              height: 120,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image_rounded, size: 32, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Text('Media unavailable', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),

            // 4. Pickup Match Card (If it's a match invite)
            if (isMatchInvite)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D00).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFF4D00).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.sports_score_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OPEN MATCH INVITATION',
                              style: TextStyle(
                                color: Color(0xFFFF4D00),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${post.sport} Sparring Partner Needed',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Joined match group! Chat opened.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCFF00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('JOIN MATCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ),

            // 4. Action Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    label: '${post.likesCount}',
                    color: isLiked ? Colors.redAccent : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    onTap: onLike,
                  ),
                  const SizedBox(width: 6),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.commentsCount}',
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    onTap: onComment,
                  ),
                  const Spacer(),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '${post.authorName} on KRICO: "${post.content}"'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post link copied!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final CommunityPostModel post;
  final String? currentUserId;
  final String currentUserName;
  final String? currentUserAvatar;

  const _CommentsSheet({
    required this.post,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatar,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || widget.currentUserId == null) return;

    setState(() => _isSending = true);
    try {
      final commentsRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments');

      final newComment = PostCommentModel(
        id: commentsRef.doc().id,
        postId: widget.post.id,
        authorId: widget.currentUserId!,
        authorName: widget.currentUserName,
        authorAvatarUrl: widget.currentUserAvatar,
        content: text,
        createdAt: DateTime.now(),
      );

      await commentsRef.doc(newComment.id).set(newComment.toMap());
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentCtrl.clear();
    } catch (_) {} finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Match Comments',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00)));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet. Start the drill talk!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = PostCommentModel.fromDoc(docs[index]);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue.withValues(alpha: 0.2),
                              child: Text(
                                comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.authorName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(comment.content, style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    8 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Join the conversation...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isSending ? null : _sendComment,
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, color: Color(0xFFCCFF00)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _HighFiverTile extends ConsumerWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final VoidCallback onTap;

  const _HighFiverTile({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fiverUid = item['uid'] as String? ?? '';
    final userProfileAsync = fiverUid.isNotEmpty ? ref.watch(publicUserProfileProvider(fiverUid)) : null;
    final profile = userProfileAsync?.value;

    // Resolve real full display name
    final rawName = profile?.name.trim().isNotEmpty == true
        ? profile!.name
        : (item['name'] as String? ?? '');
    final fiverName = (rawName.isNotEmpty && rawName.toLowerCase() != 'athlete')
        ? rawName
        : (profile?.username.isNotEmpty == true
            ? profile!.username
            : (item['username'] as String? ?? (rawName.isNotEmpty ? rawName : 'Athlete')));

    // Resolve real username (e.g. @rahulsharma, @viratkohli)
    final rawUsername = profile?.username.trim().isNotEmpty == true
        ? profile!.username
        : (item['username'] as String? ?? '');
    final fiverUsername = rawUsername.isNotEmpty
        ? rawUsername
        : (fiverName.isNotEmpty && fiverName.toLowerCase() != 'athlete'
            ? fiverName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')
            : (fiverUid.isNotEmpty ? fiverUid.substring(0, fiverUid.length.clamp(0, 8)) : 'athlete'));

    final fiverRole = profile?.role.name ?? (item['role'] as String? ?? 'Player');
    final fiverAvatar = profile?.photoUrl ?? (item['avatar'] as String?);

    ImageProvider? imageProvider;
    if (fiverAvatar != null && fiverAvatar.isNotEmpty) {
      if (fiverAvatar.startsWith('http')) {
        imageProvider = NetworkImage(fiverAvatar);
      } else if (fiverAvatar.startsWith('data:')) {
        try {
          imageProvider = MemoryImage(base64Decode(fiverAvatar.split(',').last));
        } catch (_) {}
      } else {
        imageProvider = AssetImage(fiverAvatar);
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFCCFF00).withValues(alpha: 0.15),
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                fiverName.isNotEmpty ? fiverName[0].toUpperCase() : 'A',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFCCFF00)),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              fiverName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              fiverRole.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFCCFF00),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              '@$fiverUsername',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.cyan,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '•',
            style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 11),
          ),
          const SizedBox(width: 6),
          const Text('Sent a High-Five ✋', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey.withValues(alpha: 0.6),
      ),
      onTap: onTap,
    );
  }
}
