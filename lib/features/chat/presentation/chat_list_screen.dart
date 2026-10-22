import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
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
  int _selectedFilterIndex = 0; // 0: All, 1: Coaches, 2: Squads, 3: Bookings

  final _filterTabs = ['All', 'Coaches', 'Athletes', 'Bookings'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: AppTextStyles.body.copyWith(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search chats, players or coaches...',
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          isDense: true,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid;

    final bgColor = isDark ? const Color(0xFF0B0E14) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showNewChatDialog(context);
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCCFF00), Color(0xFF00F59B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.chat_bubble_rounded, color: Colors.black, size: 24),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              // 1. Sleek Athletic Top Bar with Live Indicator
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
                        'assets/backgrounds/stadium_tunnel.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
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
                                        'DIRECT & SQUAD CHAT',
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
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Messages',
                              style: AppTextStyles.heading2.copyWith(
                                color: textPrimary,
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

              // 2. Active Contacts Horizontal Strip
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final allUsersAsync = ref.watch(allUsersProvider);
                    final allUsersDocs = allUsersAsync.asData?.value.docs ?? [];
                    final currentUid = FirebaseAuth.instance.currentUser?.uid;
                    final realUsers = allUsersDocs
                        .map((d) => UserModel.fromDoc(d))
                        .where((u) => u.uid != currentUid)
                        .take(8)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RECENT ATHLETES & COACHES',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (realUsers.isEmpty) ...[
                                  _buildActiveContact(
                                    name: 'Start Chat',
                                    sport: 'Direct',
                                    image: 'assets/avatars/coach_trainer.jpg',
                                    isDark: isDark,
                                    onTap: () => _showNewChatDialog(context),
                                  ),
                                ] else ...[
                                  for (final u in realUsers)
                                    _buildActiveContact(
                                      name: u.name,
                                      sport: u.role.name.toUpperCase(),
                                      image: 'assets/avatars/coach_trainer.jpg',
                                      isDark: isDark,
                                      onTap: () async {
                                        if (currentUid == null) return;
                                        try {
                                          final chatService = ref.read(chatServiceProvider);
                                          final chatId = await chatService.getOrCreateDirectChat(currentUid, u.uid);
                                          if (context.mounted) {
                                            context.push(AppRoutes.chatDetail.replaceFirst(':id', chatId), extra: u.uid);
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Could not open chat: $e'), backgroundColor: AppColors.danger),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: _buildSearchField(isDark),
                ),
              ),

              // 4. Category Tabs
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterTabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final title = _filterTabs[index];
                      final isSelected = _selectedFilterIndex == index;
                      return ChoiceChip(
                        label: Text(title),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilterIndex = index);
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

              // 5. Chat List Stream
              if (userId != null)
                ref.watch(userChatsProvider(userId)).when(
                  data: (chats) {
                    final allUsersAsync = ref.watch(allUsersProvider);
                    final allUsers = allUsersAsync.asData?.value;
                    final Map<String, String> userNameMap = {};
                    if (allUsers != null) {
                      for (final doc in allUsers.docs) {
                        final d = doc.data();
                        final name = d['name'] as String? ?? '';
                        userNameMap[doc.id] = name;
                        final uidField = d['uid'] as String? ?? '';
                        if (uidField.isNotEmpty) userNameMap[uidField] = name;
                      }
                    }

                    final chatsFiltered = chats.where((c) {
                      if (_searchQuery.isEmpty) return true;
                      final matchMessage = (c.lastMessage?.toLowerCase().contains(_searchQuery) ?? false);
                      final otherUserId = c.participants.where((p) => p != userId).firstOrNull ?? '';
                      final otherName = (userNameMap[otherUserId] ?? '').toLowerCase();
                      final matchName = otherName.contains(_searchQuery);
                      return matchMessage || matchName;
                    }).toList();

                    if (_searchQuery.isNotEmpty) {
                      final seen = <String>{};
                      final matchingUsers = allUsers == null
                          ? <UserModel>[]
                          : allUsers.docs
                              .map((d) => UserModel.fromDoc(d))
                              .where((u) {
                                if (u.uid == userId) return false;
                                if (!seen.add(u.uid)) return false;
                                return u.name.toLowerCase().contains(_searchQuery) ||
                                    u.username.toLowerCase().contains(_searchQuery);
                              })
                              .toList()
                            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                      if (matchingUsers.isEmpty && chatsFiltered.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 56, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text('No players or chats found for "$_searchQuery"',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }

                      final items = <Widget>[];
                      if (matchingUsers.isNotEmpty) {
                        items.add(_sectionHeader('Verified Athletes & Coaches', isDark));
                        items.addAll(matchingUsers.take(15).map((u) => _buildStartChatTile(context, u, isDark)));
                      }
                      if (chatsFiltered.isNotEmpty) {
                        items.add(_sectionHeader('Conversations', isDark));
                        items.addAll(chatsFiltered.map((chat) => _buildAthleticChatTile(context, chat, userId, isDark)));
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => items[index].animate().fade(duration: 250.ms),
                            childCount: items.length,
                          ),
                        ),
                      );
                    }

                    if (chatsFiltered.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/animations/sports_ball.gif',
                                width: 80,
                                height: 80,
                                errorBuilder: (_, _, _) => const Icon(Icons.chat_bubble_outline_rounded, size: 56, color: Color(0xFFCCFF00)),
                              ),
                              const SizedBox(height: 16),
                              Text('No conversations yet',
                                  style: AppTextStyles.title2.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              const Text('Reach out to coaches or match players nearby.',
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showNewChatDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCCFF00),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                                label: const Text('Start First Chat', style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final chat = chatsFiltered[index];
                            return _buildAthleticChatTile(context, chat, userId, isDark)
                                .animate()
                                .fade(duration: 250.ms)
                                .slideY(begin: 0.05, delay: (index * 30).ms);
                          },
                          childCount: chatsFiltered.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00))),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('Failed to load chats: $e', style: const TextStyle(color: Colors.red))),
                  ),
                )
              else
                const SliverFillRemaining(
                  child: Center(child: Text('Sign in to view messages')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveContact({
    required String name,
    required String sport,
    required String image,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCCFF00), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(image),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name.split(' ').first,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleticChatTile(BuildContext context, ChatModel chat, String userId, bool isDark) {
    final otherUserId = chat.participants.where((p) => p != userId).firstOrNull ?? '';
    final otherUserAsync = ref.watch(userProfileProvider(otherUserId));
    final unreadCount = chat.unreadCount?[userId] ?? 0;
    final hasUnread = unreadCount > 0;
    final timeStr = chat.lastMessageTime != null ? _formatTime(chat.lastMessageTime!) : '';

    final cardBg = isDark ? const Color(0xFF131D31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasUnread ? const Color(0xFFCCFF00).withValues(alpha: 0.3) : borderColor,
          width: hasUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (otherUserId.isNotEmpty) context.push('/profile/$otherUserId');
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnread ? const Color(0xFFCCFF00) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: otherUserAsync.whenOrNull(
                          data: (user) => user?.photoUrl != null
                              ? Image.network(user!.photoUrl!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/avatars/coach_default.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Text(
                                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ) ??
                        Image.asset('assets/avatars/coach_default.jpg', fit: BoxFit.cover),
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
                                data: (user) => Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user?.name ?? 'User',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (user?.role.name.toLowerCase() == 'coach') ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF3B82F6)),
                                    ],
                                  ],
                                ),
                              ) ??
                              Text(
                                'User',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: hasUnread ? (isDark ? const Color(0xFFCCFF00) : const Color(0xFF15803D)) : const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage ?? 'Started conversation',
                            style: TextStyle(
                              color: hasUnread
                                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
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

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildStartChatTile(BuildContext context, UserModel user, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () => _startChatFromSearch(context, user),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.15),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        title: Text(user.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
        subtitle: Text('@${user.username}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFCCFF00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Message', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
      ),
    );
  }

  Future<void> _startChatFromSearch(BuildContext context, UserModel user) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid;
    if (userId == null) return;
    final chatService = ref.read(chatServiceProvider);
    final navigator = Navigator.of(context);
    try {
      final chatId = await chatService.createChat([userId, user.uid]);
      if (mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              otherUserId: user.uid,
            ),
          ),
        );
      }
    } catch (_) {}
  }

  void _showNewChatDialog(BuildContext context) {
    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _NewChatSheet(currentUserId: userId),
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

class _NewChatSheet extends ConsumerStatefulWidget {
  const _NewChatSheet({required this.currentUserId});

  final String currentUserId;

  @override
  ConsumerState<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<_NewChatSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _startChat(BuildContext sheetContext, UserModel user) async {
    Navigator.pop(sheetContext);
    final chatService = ref.read(chatServiceProvider);
    final navigator = Navigator.of(context);
    try {
      final chatId = await chatService.createChat([widget.currentUserId, user.uid]);
      if (mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              otherUserId: user.uid,
            ),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(allUsersProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(SpacingScale.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Start New Conversation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search athlete or coach...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: usersAsync.when(
                data: (snapshot) {
                  final seenUids = <String>{};
                  final allUsers = <UserModel>[];
                  for (final d in snapshot.docs) {
                    final u = UserModel.fromDoc(d);
                    if (u.uid == widget.currentUserId) continue;
                    if (!seenUids.add(u.uid)) continue;
                    allUsers.add(u);
                  }
                  final users = allUsers
                      .where((u) =>
                          _query.isEmpty ||
                          u.name.toLowerCase().contains(_query) ||
                          u.username.toLowerCase().contains(_query))
                      .toList()
                    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                  if (users.isEmpty) {
                    return const Center(child: Text('No users match search'));
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withValues(alpha: 0.15),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('@${user.username} • ${user.role.name.toUpperCase()}'),
                        onTap: () => _startChat(ctx, user),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00))),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
