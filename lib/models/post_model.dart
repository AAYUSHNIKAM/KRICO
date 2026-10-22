import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatarUrl;
  final String? authorCertificateBadge;
  final String? authorCertificateTitle;
  final String content;
  final String sport;
  final String? mediaUrl;
  final int likesCount;
  final int commentsCount;
  final List<String> likedUserIds;
  final DateTime createdAt;

  const CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatarUrl,
    this.authorCertificateBadge,
    this.authorCertificateTitle,
    required this.content,
    this.sport = 'General',
    this.mediaUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedUserIds = const [],
    required this.createdAt,
  });

  factory CommunityPostModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CommunityPostModel(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Athlete',
      authorRole: data['authorRole'] as String? ?? 'player',
      authorAvatarUrl: data['authorAvatarUrl'] as String?,
      authorCertificateBadge: data['authorCertificateBadge'] as String?,
      authorCertificateTitle: data['authorCertificateTitle'] as String?,
      content: data['content'] as String? ?? '',
      sport: data['sport'] as String? ?? 'General',
      mediaUrl: data['mediaUrl'] as String?,
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      likedUserIds: List<String>.from(data['likedUserIds'] as List? ?? []),
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'authorName': authorName,
    'authorRole': authorRole,
    'authorAvatarUrl': authorAvatarUrl,
    'authorCertificateBadge': authorCertificateBadge,
    'authorCertificateTitle': authorCertificateTitle,
    'content': content,
    'sport': sport,
    'mediaUrl': mediaUrl,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'likedUserIds': likedUserIds,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class PostCommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory PostCommentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PostCommentModel(
      id: doc.id,
      postId: data['postId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'User',
      authorAvatarUrl: data['authorAvatarUrl'] as String?,
      content: data['content'] as String? ?? '',
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'postId': postId,
    'authorId': authorId,
    'authorName': authorName,
    'authorAvatarUrl': authorAvatarUrl,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
