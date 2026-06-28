import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/chat_model.dart';
import '../../../services/providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Messages', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search messages...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38, fontSize: 14),
                            isDense: true,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.search_rounded, color: Colors.white38, size: 18),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 28),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: IconButton(
                                      icon: Icon(Icons.clear_rounded, color: Colors.white38, size: 16),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                : null,
                            suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (userId != null)
            ref.watch(userChatsProvider(userId)).when(
              data: (chats) {
                final allUsersAsync = ref.watch(allUsersProvider);
                final allUsers = allUsersAsync.asData?.value;
                final Map<String, String> userNameMap = {};
                if (allUsers != null) {
                  for (final doc in allUsers.docs) {
                    final d = doc.data();
                    userNameMap[d['uid'] as String? ?? doc.id] = d['name'] as String? ?? '';
                  }
                }
                final filtered = chats.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  final matchMessage = (c.lastMessage?.toLowerCase().contains(_searchQuery) ?? false);
                  final otherUserId = c.participants.where((p) => p != userId).firstOrNull ?? '';
                  final otherName = (userNameMap[otherUserId] ?? '').toLowerCase();
                  final matchName = otherName.contains(_searchQuery);
                  return matchMessage || matchName;
                }).toList();
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textDim),
                          const SizedBox(height: 16),
                          Text('No conversations yet', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('Start chatting with coaches and players', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chat = filtered[index];
                        return _buildChatTile(context, chat, userId).animate().fade(duration: 300.ms).slideY(begin: 0.1, delay: (index * 40).ms);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textDim),
                      const SizedBox(height: 16),
                      Text('Failed to load chats', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off_rounded, size: 64, color: AppColors.textDim),
                    const SizedBox(height: 16),
                    Text('Sign in to see your messages', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat, String userId) {
    final otherUserId = chat.participants.where((p) => p != userId).firstOrNull ?? '';
    final otherUserAsync = ref.watch(userProfileProvider(otherUserId));
    final unreadCount = chat.unreadCount?[userId] ?? 0;
    final hasUnread = unreadCount > 0;
    final timeStr = chat.lastMessageTime != null ? _formatTime(chat.lastMessageTime!) : '';

    final colors = [AppColors.primary, AppColors.accent, AppColors.secondary, AppColors.info, AppColors.success, AppColors.gold];
    final avatarColors = colors[chat.participants.length % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                chatId: chat.chatId,
                otherUserId: otherUserId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [avatarColors, avatarColors.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: otherUserAsync.whenOrNull(
                    data: (user) => Text(
                      user?.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ) ?? Text(
                    otherUserId.isNotEmpty ? otherUserId[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
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
                        Expanded(
                          child: otherUserAsync.whenOrNull(
                            data: (user) => Text(
                              user?.name ?? 'User',
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ) ?? Text(
                            'User',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(timeStr, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage ?? 'No messages yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final usersAsync = ref.watch(allUsersProvider);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (ctx, scrollCtrl) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('New Conversation', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Theme.of(context).colorScheme.outline),
                Expanded(
                  child: usersAsync.when(
                    data: (snapshot) {
                      final docs = snapshot.docs;
                      final users = docs
                          .map((d) => UserModel.fromDoc(d))
                          .where((u) => u.uid != userId)
                          .toList();
                      if (users.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textDim),
                              const SizedBox(height: 12),
                              Text('No other users found', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollCtrl,
                        itemCount: users.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (_, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.role.name, style: TextStyle(color: AppColors.textSecondary)),
                            onTap: () async {
                              Navigator.pop(ctx);
                              final chatService = ref.read(chatServiceProvider);
                              try {
                                final chatId = await chatService.createChat([userId, user.uid]);
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailScreen(
                                        chatId: chatId,
                                        otherUserId: user.uid,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to create chat: $e'), backgroundColor: AppColors.error),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Failed to load users: $e')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
