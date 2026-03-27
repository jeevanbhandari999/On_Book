import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_bar_popup_menu.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/domain/usecases/archievt_notification_use_case.dart';
import 'package:app/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_all_notifiations_as_read_use_case.dart';
import 'package:app/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:app/features/notifications/domain/usecases/stream_notifications_use_case.dart';

import 'package:app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:app/features/notifications/presentation/widgets/notification_shimmer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE  (BLoC provider only)
// ─────────────────────────────────────────────────────────────────────────────

class NotificationPage extends StatelessWidget {
  final String userId;

  const NotificationPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(
        getNotifications: DependencyInjection.get<GetNotificationsUseCase>(),
        streamNotifications:
            DependencyInjection.get<StreamNotificationsUseCase>(),
        markAsRead: DependencyInjection.get<MarkNotificationAsReadUseCase>(),
        markAllAsRead:
            DependencyInjection.get<MarkAllNotificationsAsReadUseCase>(),
        archive: DependencyInjection.get<ArchiveNotificationUseCase>(),
      )..add(NotificationStarted(userId: userId)),
      child: const _NotificationView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        if (state is NotificationLoaded && state.pendingNavigation != null) {
          _handleNavigation(context, state.pendingNavigation!);
        }
      },
      builder: (context, state) {
        if (state is NotificationInitial || state is NotificationLoading) {
          return const Scaffold(body: NotificationShimmerPage());
        }

        if (state is NotificationError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: _ErrorView(
              message: state.message,
              onRetry: () => context.read<NotificationBloc>().add(
                const NotificationRefreshRequested(),
              ),
            ),
          );
        }

        if (state is NotificationLoaded) {
          return _LoadedView(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleNavigation(
    BuildContext context,
    NotificationEntity notification,
  ) {
    switch (notification.referenceType) {
      case 'booking':
        if (notification.referenceId != null) {
          context.push(
            RouteConstants.bookingDetailsPage,
            extra: {'bookingId': notification.referenceId},
          );
        }
      case 'payment':
      // if (notification.referenceId != null) {
      //   context.push(
      //     RouteConstants.paymentDetailsPage,
      //     extra: {'paymentId': notification.referenceId},
      //   );
      // }
      case 'chat':
      // if (notification.referenceId != null) {
      //   context.push(
      //     RouteConstants.chatRoomPage,
      //     extra: {'roomId': notification.referenceId},
      //   );
      // }
      case 'post':
        if (notification.referenceId != null) {
          context.push(
            RouteConstants.postDetailsPage,
            extra: {'postId': notification.referenceId},
          );
        }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADED VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  final NotificationLoaded state;

  const _LoadedView({required this.state});

  static const _typeFilters = [
    (label: 'All', icon: Icons.notifications_rounded),
    (label: 'Messages', icon: Icons.message_rounded),
    (label: 'Booking', icon: Icons.event_available_rounded),
    (label: 'Payment', icon: Icons.payments_rounded),
    (label: 'System', icon: Icons.info_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = state.grouped;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => context.read<NotificationBloc>().add(
          const NotificationRefreshRequested(),
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Sliver AppBar ───────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: true,
              collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
              elevation: 0,
              centerTitle: false,
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.black,
              titleSpacing: 0,
              leading: const BackButton(color: Colors.black),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(UiConstants.radiusXl),
                      bottomRight: Radius.circular(UiConstants.radiusXl),
                    ),
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().slide(duration: 400.ms).fade(duration: 400.ms),
                  ),
                  if (state.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          UiConstants.radiusRound,
                        ),
                      ),
                      child: Text(
                        '${state.unreadCount} new',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ).animate().scale(duration: 350.ms).fade(duration: 350.ms),
                ],
              ),
              actions: [
                if (state.unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    tooltip: 'Mark all as read',
                    onPressed: () => context.read<NotificationBloc>().add(
                      const NotificationMarkAllAsReadRequested(),
                    ),
                  ).animate().fade(duration: 300.ms),

                AppPopupMenu(
                  iconColor: Colors.black,
                  items: [
                    AppPopupMenuItem(
                      value: 'all',
                      label: 'All',
                      icon: Icons.grid_view_outlined,
                      onTap: () => context.read<NotificationBloc>().add(
                        const NotificationReadFilterChanged(
                          filter: NotificationReadFilter.all,
                        ),
                      ),
                    ),
                    AppPopupMenuItem(
                      value: 'unread',
                      label: 'Unread',
                      icon: Icons.notifications_active_outlined,
                      onTap: () => context.read<NotificationBloc>().add(
                        const NotificationReadFilterChanged(
                          filter: NotificationReadFilter.unread,
                        ),
                      ),
                    ),
                    AppPopupMenuItem(
                      value: 'read',
                      label: 'Read',
                      icon: Icons.done_all,
                      onTap: () => context.read<NotificationBloc>().add(
                        const NotificationReadFilterChanged(
                          filter: NotificationReadFilter.read,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Type filter chips ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _TypeFilterChips(
                filters: _typeFilters,
                selected: state.typeFilter,
                onSelected: (label) => context.read<NotificationBloc>().add(
                  NotificationTypeFilterChanged(filter: label),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────────
            if (grouped.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  isFiltered:
                      state.typeFilter != 'All' ||
                      state.readFilter != NotificationReadFilter.all,
                ),
              )
            else
              ...grouped.entries.map(
                (entry) => _GroupSection(
                  dateLabel: entry.key,
                  notifications: entry.value,
                ),
              ),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: UiConstants.spacingXxl),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPE FILTER CHIPS
// ─────────────────────────────────────────────────────────────────────────────

class _TypeFilterChips extends StatelessWidget {
  final List<({String label, IconData icon})> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const _TypeFilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: UiConstants.spacingMd,
          vertical: UiConstants.spacingXs,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = selected == f.label;

          return Padding(
                padding: const EdgeInsets.only(right: UiConstants.spacingSm),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f.icon,
                        size: 15,
                        color: isSelected ? Colors.black87 : Colors.black87,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.black87 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => onSelected(f.label),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      UiConstants.radiusRound,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryLight
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: index * 60))
              .slideX(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic)
              .fade(duration: 300.ms);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _GroupSection extends StatelessWidget {
  final String dateLabel;
  final List<NotificationEntity> notifications;

  const _GroupSection({required this.dateLabel, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: UiConstants.spacingMd),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConstants.spacingMd,
                vertical: UiConstants.spacingXs,
              ),
              child: Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            );
          }

          final notification = notifications[index - 1];
          final delay = ((index - 1) * 40).clamp(0, 400);

          return _NotificationCard(notification: notification)
              .animate(delay: Duration(milliseconds: delay))
              .slideX(
                begin: index.isEven ? -0.2 : 0.2,
                duration: 320.ms,
                curve: Curves.easeOutCubic,
              )
              .fade(duration: 320.ms);
        }, childCount: notifications.length + 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(notification.type);

    return Dismissible(
      key: Key('notif-${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<NotificationBloc>().add(
          NotificationArchiveRequested(notificationId: notification.id),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: UiConstants.spacingMd,
          vertical: UiConstants.spacingXs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          gradient: LinearGradient(
            colors: [
              Colors.red.withAlpha(30),
              Colors.red.withAlpha(140),
              Colors.red.withAlpha(220),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: UiConstants.spacingMd),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: UiConstants.spacingMd,
          vertical: UiConstants.spacingXs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          gradient: notification.isUnread
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withAlpha(12),
                    accent.withAlpha(50),
                    accent.withAlpha(90),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(40),
                    Colors.white.withAlpha(120),
                    Colors.white.withAlpha(200),
                  ],
                ),
          border: Border.all(
            color: notification.isUnread
                ? accent.withAlpha(80)
                : Colors.grey.withAlpha(60),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(16),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () => context.read<NotificationBloc>().add(
                NotificationTapped(notification: notification),
              ),
              borderRadius: BorderRadius.circular(UiConstants.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(UiConstants.spacingMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NotificationAvatar(
                      type: notification.type,
                      accent: accent,
                    ),
                    const SizedBox(width: UiConstants.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            notification.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: UiConstants.spacingXs),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _timeAgo(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (notification.isUnread)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withAlpha(120),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION AVATAR
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationAvatar extends StatelessWidget {
  final NotificationType type;
  final Color accent;

  const _NotificationAvatar({required this.type, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accent.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(_iconFromType(type), color: accent, size: UiConstants.iconMd),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isFiltered;

  const _EmptyState({this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltered
                  ? Icons.filter_list_off_rounded
                  : Icons.notifications_none_rounded,
              size: 38,
              color: AppColors.primaryLight.withAlpha(130),
            ),
          ),
          const SizedBox(height: UiConstants.spacingMd),
          Text(
            isFiltered ? 'No results' : 'No notifications',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: UiConstants.spacingXs),
          Text(
            isFiltered ? 'Try a different filter.' : "You're all caught up!",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: UiConstants.spacingMd),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UiConstants.spacingXs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: UiConstants.spacingLg),
            CustomButton(
              text: 'Try Again',
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PURE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Color _accentColor(NotificationType type) {
  return switch (type) {
    NotificationType.chatMessage => const Color(0xFF4A90E2),
    NotificationType.bookingRequested ||
    NotificationType.bookingConfirmed ||
    NotificationType.bookingCancelled ||
    NotificationType.bookingRejected => const Color(0xFF7B61FF),
    NotificationType.paymentReceived ||
    NotificationType.paymentFailed ||
    NotificationType.paymentRefunded => const Color(0xFF27AE60),
    NotificationType.reviewReceived => const Color(0xFFF39C12),
    NotificationType.postApproved ||
    NotificationType.postRejected => const Color(0xFFE67E22),
    NotificationType.system => const Color(0xFF546E7A),
  };
}

IconData _iconFromType(NotificationType type) {
  return switch (type) {
    NotificationType.chatMessage => Icons.message_rounded,
    NotificationType.bookingRequested => Icons.event_note_rounded,
    NotificationType.bookingConfirmed => Icons.event_available_rounded,
    NotificationType.bookingCancelled => Icons.event_busy_rounded,
    NotificationType.bookingRejected => Icons.cancel_outlined,
    NotificationType.paymentReceived => Icons.payments_rounded,
    NotificationType.paymentFailed => Icons.money_off_rounded,
    NotificationType.paymentRefunded => Icons.currency_exchange_rounded,
    NotificationType.reviewReceived => Icons.star_rounded,
    NotificationType.postApproved => Icons.check_circle_rounded,
    NotificationType.postRejected => Icons.unpublished_rounded,
    NotificationType.system => Icons.info_rounded,
  };
}

String _timeAgo(DateTime createdAt) {
  final diff = DateTime.now().difference(createdAt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
