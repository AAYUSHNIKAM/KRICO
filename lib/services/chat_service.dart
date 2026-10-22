import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  ChatService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final chats = snap.docs.map((doc) => ChatModel.fromDoc(doc)).toList();
          chats.sort((a, b) {
            final aTime = a.lastMessageTime ?? DateTime(0);
            final bTime = b.lastMessageTime ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
          return chats;
        });
  }

  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatMessage.fromDoc(doc)).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? mediaUrl,
    MessageType type = MessageType.text,
  }) async {
    final message = ChatMessage(
      messageId: _firestore.collection('chats').doc(chatId).collection('messages').doc().id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      messageType: type,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());
    final preview = type == MessageType.image ? '[Image]' : text;
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': preview,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': senderId,
    });
  }

  Future<String> createChat(List<String> participants) async {
    final chatId = _firestore.collection('chats').doc().id;
    final chat = ChatModel(
      chatId: chatId,
      participants: participants,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('chats').doc(chatId).set(chat.toMap());
    return chatId;
  }

  Future<void> markAsRead(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });
  }

  Future<String> getOrCreateDirectChat(
    String user1,
    String user2, {
    String? starterMessage,
    String? starterSenderId,
  }) async {
    final snap = await _firestore
        .collection('chats')
        .where('participants', arrayContains: user1)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in snap.docs) {
      final participants = (doc.data()['participants'] as List<dynamic>?)?.cast<String>() ?? [];
      if (participants.contains(user2)) {
        return doc.id;
      }
    }

    final chatId = await createChat([user1, user2]);
    if (starterMessage != null && starterSenderId != null) {
      await sendMessage(
        chatId: chatId,
        senderId: starterSenderId,
        text: starterMessage,
      );
    }
    return chatId;
  }
}
