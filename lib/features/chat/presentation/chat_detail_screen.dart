import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/chat_model.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.otherUserId,
  });

  final String chatId;
  final String? otherUserId;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: 200.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();
    try {
      final auth = ref.read(authServiceProvider);
      final senderId = auth.currentUser?.uid;
      if (senderId == null) return;
      final chatService = ref.read(chatServiceProvider);
      await chatService.sendMessage(
        chatId: widget.chatId,
        senderId: senderId,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid ?? '';

    final otherId = widget.otherUserId ?? '';
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));

    String resolvedOtherId = otherId;
    if (resolvedOtherId.isEmpty) {
      final chatData = ref.watch(userChatsProvider(userId)).asData?.value;
      final chatModel = chatData?.where((c) => c.chatId == widget.chatId).firstOrNull;
      resolvedOtherId = chatModel?.participants.where((p) => p != userId).firstOrNull ?? '';
    }

    final resolvedUserAsync = ref.watch(userProfileProvider(resolvedOtherId));
    final displayName = resolvedUserAsync.value?.name ?? 'User';
    final initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.accent.withValues(alpha: 0.3)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                Text('Online', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_rounded, size: 48, color: AppColors.textDim),
                        const SizedBox(height: 12),
                        Text('No messages yet', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                        Text('Send a message to start chatting', style: AppTextStyles.caption.copyWith(color: AppColors.textDim)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == userId;
                    return _buildMessageBubble(msg, isMe).animate().fade(duration: 200.ms).slideY(begin: 0.05);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textDim),
                    const SizedBox(height: 12),
                    Text('Failed to load messages', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(top: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file_rounded, color: AppColors.textSecondary, size: 24),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      onSubmitted: (_) => _sendMessage(),
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDim),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.accent.withValues(alpha: 0.3)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.person, size: 14, color: Colors.white54)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: AppColors.borderLight.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (msg.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(msg.createdAt!),
                      style: AppTextStyles.caption.copyWith(
                        color: isMe ? Colors.white60 : AppColors.textDim,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
