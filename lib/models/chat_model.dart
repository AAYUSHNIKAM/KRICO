import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class ChatModel {
  const ChatModel({
    required this.chatId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.unreadCount,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String chatId;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final Map<String, int>? unreadCount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ChatModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatModel(
      chatId: doc.id,
      participants: (data['participants'] as List<dynamic>?)?.cast<String>() ?? [],
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: _parseTimestamp(data['lastMessageTime']),
      lastMessageSender: data['lastMessageSender'] as String?,
      unreadCount: (data['unreadCount'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toInt())),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime != null
        ? Timestamp.fromDate(lastMessageTime!)
        : null,
    'lastMessageSender': lastMessageSender,
    'unreadCount': unreadCount,
    'isActive': isActive,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.messageType = MessageType.text,
    this.mediaUrl,
    this.isRead = false,
    this.isDelivered = false,
    this.createdAt,
  });

  final String messageId;
  final String chatId;
  final String senderId;
  final String text;
  final MessageType messageType;
  final String? mediaUrl;
  final bool isRead;
  final bool isDelivered;
  final DateTime? createdAt;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage(
      messageId: doc.id,
      chatId: data['chatId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      messageType: _parseMessageType(data['type'] as String?),
      mediaUrl: data['mediaUrl'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      isDelivered: data['isDelivered'] as bool? ?? false,
      createdAt: _parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'senderId': senderId,
    'text': text,
    'type': messageType.name,
    'mediaUrl': mediaUrl,
    'isRead': isRead,
    'isDelivered': isDelivered,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}

enum MessageType { text, image, file }

MessageType _parseMessageType(String? type) {
  switch (type) {
    case 'image':
      return MessageType.image;
    case 'file':
      return MessageType.file;
    default:
      return MessageType.text;
  }
}
