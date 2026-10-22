import '../../../../core/routing/app_router.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../models/chat_model.dart';
import '../../../services/providers.dart';
import '../../../services/firebase_service.dart';
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
  Uint8List? _imageBytes;
  bool _sendingImage = false;

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

  bool _hasOffPlatformKeywords(String text) {
    final lower = text.toLowerCase();
    final phoneRegex = RegExp(r'\b[6-9]\d{9}\b|\+91\d{10}');
    final upiRegex = RegExp(r'[\w.-]+@(upi|oksbi|okhdfcbank|okaxis|okicici|paytm|ybl|apl)');
    final keywords = ['gpay', 'paytm', 'phonepe', 'google pay', 'direct cash', 'cash direct', 'whatsapp me'];
    return phoneRegex.hasMatch(text) ||
        upiRegex.hasMatch(text) ||
        keywords.any((k) => lower.contains(k));
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();

    if (_hasOffPlatformKeywords(text) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.black, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Safety Notice: Off-platform payments void dispute coverage, free session insurance, and official athlete ratings.',
                  style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFCCFF00),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

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
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: AppColors.danger,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 70,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) return;
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<String> _uploadImage(String senderId) async {
    final bytes = _imageBytes;
    if (bytes == null) return '';
    final storage = ref.read(storageProvider);
    final storageRef = storage.ref(
        'chat/${widget.chatId}/$senderId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putData(bytes);
    return storageRef.getDownloadURL();
  }

  Future<void> _sendImage() async {
    final bytes = _imageBytes;
    if (bytes == null || _sendingImage) return;
    setState(() => _sendingImage = true);
    try {
      final auth = ref.read(authServiceProvider);
      final senderId = auth.currentUser?.uid;
      if (senderId == null) return;
      final chatService = ref.read(chatServiceProvider);

      String? mediaUrl;
      try {
        mediaUrl = await _uploadImage(senderId).timeout(const Duration(seconds: 15));
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please check your connection.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await chatService.sendMessage(
        chatId: widget.chatId,
        senderId: senderId,
        text: '',
        mediaUrl: mediaUrl,
        type: MessageType.image,
      );
      if (!mounted) return;
      setState(() => _imageBytes = null);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingImage = false);
    }
  }

  void _sendQuickAction(String actionText) {
    _messageCtrl.text = actionText;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final resolvedUser = resolvedUserAsync.value;
    final displayName = resolvedUser?.name ?? 'Athlete';
    final userRole = resolvedUser?.role.name ?? 'player';
    final isCoach = userRole.toLowerCase() == 'coach';

    final bgColor = isDark ? const Color(0xFF0B0E14) : const Color(0xFFF8FAFC);
    final topBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: topBarBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 40,
        title: GestureDetector(
          onTap: () {
            if (resolvedOtherId.isNotEmpty) {
              context.push('/profile/$resolvedOtherId');
            }
          },
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCCFF00), width: 1.5),
                    ),
                    child: ClipOval(
                      child: resolvedUser?.photoUrl != null
                          ? Image.network(resolvedUser!.photoUrl!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/avatars/coach_default.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(displayName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: topBarBg, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCoach) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF3B82F6)),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/animations/live_pulse.gif',
                          width: 10,
                          height: 10,
                          errorBuilder: (_, _, _) => const Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCoach ? 'Coach • Online' : 'Athlete • Active',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isCoach)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  final coachId = widget.otherUserId;
                  if (coachId != null && coachId.isNotEmpty) {
                    context.push('${AppRoutes.bookingFlow}?coachId=$coachId');
                  } else {
                    context.push(AppRoutes.coachDiscovery);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 14),
                label: const Text('Book', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Message List
              Expanded(
                child: Stack(
                  children: [
                    // Atmospheric subtle background
                    Positioned.fill(
                      child: Opacity(
                        opacity: isDark ? 0.05 : 0.02,
                        child: Image.asset(
                          'assets/backgrounds/stadium_floodlights.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    messagesAsync.when(
                      data: (messages) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                        if (messages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(SpacingScale.s24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/animations/sports_ball.gif',
                                    width: 72,
                                    height: 72,
                                    errorBuilder: (_, _, _) => const Icon(Icons.chat_rounded, size: 48, color: Color(0xFFCCFF00)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Start training talk with $displayName',
                                    style: AppTextStyles.title2.copyWith(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Coordinate slots, court locations, or drill tips.',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      ActionChip(
                                        label: const Text('Are you free for training this week?'),
                                        onPressed: () => _sendQuickAction('Hey! Are you free for a training session this week?'),
                                      ),
                                      ActionChip(
                                        label: const Text('Which court/turf do you prefer?'),
                                        onPressed: () => _sendQuickAction('Which court or turf do you usually prefer for training?'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(SpacingScale.s16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe = msg.senderId == userId;
                            return _buildAthleticMessageBubble(msg, isMe, isDark)
                                .animate()
                                .fade(duration: 180.ms)
                                .slideY(begin: 0.04);
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                      ),
                      error: (e, _) => Center(
                        child: Text('Failed to load messages: $e', style: const TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Action Chips Strip
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildQuickActionChip(
                      icon: Icons.calendar_today_rounded,
                      label: 'Propose Session',
                      onTap: () => _sendQuickAction('Can we schedule a 1-hour coaching slot tomorrow? 🏸'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.location_on_rounded,
                      label: 'Send Location Pin',
                      onTap: () => _sendQuickAction('Meeting spot: Sports Complex Arena ground. See you there! 📍'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(
                      icon: Icons.sports_score_rounded,
                      label: 'Ready for Match',
                      onTap: () => _sendQuickAction('Warmup completed, ready on court! 🔥'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Bottom Input Bar
              Container(
                padding: const EdgeInsets.all(SpacingScale.s12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_imageBytes != null) ...[
                        _buildImagePreview(isDark),
                        const SizedBox(height: SpacingScale.s8),
                      ],
                      Row(
                        children: [
                          IconButton(
                            icon: _sendingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFCCFF00),
                                    ),
                                  )
                                : Icon(
                                    Icons.photo_camera_rounded,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    size: 24,
                                  ),
                            onPressed: _sendingImage ? null : _pickImage,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageCtrl,
                              onSubmitted: (_) => _sendMessage(),
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s8),
                          GestureDetector(
                            onTap: _imageBytes != null ? _sendImage : _sendMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFCCFF00), Color(0xFF00F59B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                            ),
                          ),
                        ],
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

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleticMessageBubble(ChatMessage msg, bool isMe, bool isDark) {
    final isImage = msg.messageType == MessageType.image;
    final isBookingPrompt = msg.text.contains('schedule') || msg.text.contains('coaching slot') || msg.text.contains('Decathlon');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              child: const Icon(Icons.sports, size: 14, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: isImage
                ? _buildImageBubble(msg, isMe, isDark)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFFCCFF00), Color(0xFF00F59B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe
                          ? null
                          : (isDark ? const Color(0xFF131D31) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      border: isMe
                          ? null
                          : Border.all(
                              color: isBookingPrompt
                                  ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isBookingPrompt && !isMe) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: Color(0xFF3B82F6), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'SESSION INQUIRY',
                                style: TextStyle(
                                  color: Colors.blue.shade300,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            fontSize: 14,
                            fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        if (msg.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(msg.createdAt!),
                            style: TextStyle(
                              color: isMe ? Colors.black54 : (isDark ? Colors.white38 : Colors.black38),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    final bytes = _imageBytes;
    if (bytes == null) return const SizedBox.shrink();
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCFF00)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() => _imageBytes = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage msg, bool isMe, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isMe ? const Color(0xFFCCFF00) : Colors.grey.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _viewFullImage(msg),
            child: SizedBox(
              width: 240,
              height: 180,
              child: _buildImageWidget(msg),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              _formatTime(msg.createdAt ?? DateTime.now()),
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(ChatMessage msg, {bool cover = true}) {
    final fit = cover ? BoxFit.cover : BoxFit.contain;
    if (msg.imageBase64 != null && msg.imageBase64!.isNotEmpty) {
      return Image.memory(base64Decode(msg.imageBase64!), fit: fit);
    }
    final url = msg.mediaUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: fit, errorBuilder: (_, _, _) => _brokenImage());
    }
    return _brokenImage();
  }

  Widget _brokenImage() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.white54),
      ),
    );
  }

  void _viewFullImage(ChatMessage msg) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(SpacingScale.s12),
        child: InteractiveViewer(
          child: Center(
            child: _buildImageWidget(msg, cover: false),
          ),
        ),
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
