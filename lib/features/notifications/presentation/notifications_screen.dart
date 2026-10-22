import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/routing/app_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../models/notification_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final userId = ref.watch(authStateProvider).value?.uid;
    final notificationsAsync = userId != null ? ref.watch(userNotificationsProvider(userId)) : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          PageHero(
            title: 'Notifications',
            phoneTitle: 'Notifications',
            showPhoneHeader: true,
            expandedHeight: 140,
            phoneActions: [
              if (userId != null)
                IconButton(
                  tooltip: 'Mark all as read',
                  icon: Icon(Icons.done_all_rounded, color: textPrimary, size: 22),
                  onPressed: () => _markAllRead(context, ref, userId),
                ),
            ],
          ),
          if (userId == null)
            const SliverFillRemaining(
              child: Center(
                child: Text('Sign in to see notifications', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            notificationsAsync!.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(SpacingScale.s24),
                      padding: const EdgeInsets.all(SpacingScale.s32),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card : AppColors.lightCard,
                        borderRadius: AppRadius.brXl3,
                        border: Border.all(color: (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.notifications_off_rounded, size: 48, color: textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: SpacingScale.s16),
                          Text('No notifications yet', style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
                          const SizedBox(height: SpacingScale.s4),
                          Text('Booking updates and alerts will show up here', style: AppTextStyles.bodySm.copyWith(color: textSecondary), textAlign: TextAlign.center),
                          const SizedBox(height: SpacingScale.s20),
                          ElevatedButton.icon(
                            onPressed: () => context.push(AppRoutes.venueDiscovery),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                            ),
                            icon: const Icon(Icons.stadium_rounded, size: 18),
                            label: const Text('Explore Venues & Turfs', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final unreadCount = notifications.where((n) => !n.isRead).length;

                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: SpacingScale.s4),
                          child: Row(
                            children: [
                              Text('$unreadCount unread', style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _markAllRead(context, ref, userId),
                                child: Text('Mark all read', style: AppTextStyles.buttonSm.copyWith(color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(SpacingScale.s16),
                        child: Column(
                          children: notifications.map((notification) {
                            return _NotificationTile(
                              notification: notification,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onTap: () => _onNotificationTap(context, ref, userId, notification),
                            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.danger),
                      const SizedBox(height: SpacingScale.s12),
                      Text('Failed to load notifications', style: AppTextStyles.bodyLg.copyWith(color: textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref, String userId) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(notificationServiceProvider).markAllAsRead(userId);
    } catch (_) {}
  }

  Future<void> _onNotificationTap(BuildContext context, WidgetRef ref, String userId, AppNotification notification) async {
    HapticFeedback.lightImpact();
    if (!notification.isRead) {
      try {
        await ref.read(notificationServiceProvider).markAsRead(notification.id);
      } catch (_) {}
    }

    if (!context.mounted) return;

    final refId = notification.refId?.trim();
    final type = notification.type.toLowerCase();

    // If refId is already an explicit route
    if (refId != null && refId.startsWith('/')) {
      try {
        context.push(refId);
        return;
      } catch (_) {}
    }

    try {
      if (refId != null && refId.isNotEmpty) {
        if (type.contains('session') || type.contains('booking')) {
          context.push('/session/$refId');
          return;
        } else if (type.contains('contract') || type.contains('escrow')) {
          context.push('/contracts/$refId');
          return;
        } else if (type.contains('chat') || type.contains('message')) {
          context.push('/chat/$refId');
          return;
        } else if (type.contains('coach')) {
          context.push('/coach/$refId');
          return;
        } else if (type.contains('venue')) {
          context.push('/venues/$refId');
          return;
        } else if (type.contains('child') || type.contains('kid')) {
          context.push('/child/$refId');
          return;
        }
      }

      // Fallback navigation based on type without specific refId
      if (type.contains('session') || type.contains('booking')) {
        context.push('/home');
      } else if (type.contains('contract')) {
        context.push('/contracts');
      } else if (type.contains('chat')) {
        context.push('/chat');
      } else if (type.contains('venue')) {
        context.push('/venues');
      } else if (type.contains('coach')) {
        context.push('/coach-discovery');
      } else {
        _showNotificationDetail(context, notification);
      }
    } catch (_) {
      _showNotificationDetail(context, notification);
    }
  }

  void _showNotificationDetail(BuildContext context, AppNotification notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(SpacingScale.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.title,
                    style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(notification.body, style: AppTextStyles.body),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  final AppNotification notification;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(notification.type);
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingScale.s8),
      padding: const EdgeInsets.all(SpacingScale.s12),
      decoration: BoxDecoration(
        color: isUnread
            ? color.withValues(alpha: 0.06)
            : (isDark ? AppColors.card : AppColors.lightCard),
        borderRadius: AppRadius.brXl2,
        border: Border.all(
          color: isUnread
              ? color.withValues(alpha: 0.25)
              : (isDark ? AppColors.border : AppColors.lightBorder).withValues(alpha: 0.5),
          width: isUnread ? 1 : 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.brXl2,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brMd,
                  ),
                  child: Icon(_typeIcon(notification.type), size: 20, color: color),
                ),
                const SizedBox(width: SpacingScale.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.title3.copyWith(
                                color: textPrimary,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: SpacingScale.s4),
                      Text(notification.body, style: AppTextStyles.bodySm.copyWith(color: textSecondary, height: 1.4)),
                      const SizedBox(height: SpacingScale.s6),
                      Text(
                        _timeLabel(notification.createdAt),
                        style: AppTextStyles.captionXs.copyWith(color: textSecondary),
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_month_rounded;
      case 'chat':
        return Icons.message_rounded;
      case 'community':
        return Icons.forum_rounded;
      case 'academy':
        return Icons.account_balance_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'booking':
        return AppColors.primary;
      case 'chat':
        return AppColors.emerald;
      case 'community':
        return AppColors.purple;
      case 'academy':
        return AppColors.orange;
      default:
        return AppColors.gold;
    }
  }

  String _timeLabel(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
