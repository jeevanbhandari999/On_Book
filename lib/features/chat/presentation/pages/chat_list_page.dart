import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/stream_user_rooms_use_case.dart';
import 'package:app/features/chat/presentation/bloc/room_cubit.dart';
import 'package:app/features/chat/presentation/widgets/chat_list_shimmer.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class RoomPage extends StatelessWidget {
  final String currentUserId;

  const RoomPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomCubit(
        streamUserRoomsUseCase:
            DependencyInjection.get<StreamUserRoomsUseCase>(),
      ),
      child: RoomPageView(currentUserId: currentUserId),
    );
  }
}

class RoomPageView extends StatefulWidget {
  final String currentUserId;
  const RoomPageView({super.key, required this.currentUserId});

  @override
  State<RoomPageView> createState() => _RoomPageViewState();
}

class _RoomPageViewState extends State<RoomPageView> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<RoomCubit, RoomState>(
          builder: (context, state) {
            if (state is RoomLoading || state is RoomInitial) {
              return const ChatListShimmerPage();
            }

            if (state is RoomStreamUpdated) {
              final filteredRooms = _getFilteredRooms(
                state.rooms,
                widget.currentUserId,
              );

              return BlocBuilder<NotificationCubit, NotificationCubitState>(
                builder: (context, notificationState) {
                  Map<String, List<NotificationEntity>> roomNotifications = {};

                  if (notificationState is NotificationCubitLoaded) {
                    for (final n in notificationState.notifications) {
                      if (n.type == NotificationType.chatMessage) {
                        if (n.referenceId != null) {
                          roomNotifications
                              .putIfAbsent(n.referenceId!, () => [])
                              .add(n);
                        }
                      }
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<RoomCubit>().refresh();
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 120 + UiConstants.spacingSm,
                          collapsedHeight: 120 + UiConstants.spacingSm,
                          foregroundColor: Colors.black,
                          backgroundColor: AppColors.primaryLight,
                          floating: false,
                          pinned: true,
                          title: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Messages',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              padding: const EdgeInsets.only(
                                right: UiConstants.spacingMd,
                                left: UiConstants.spacingMd,
                                bottom: UiConstants.spacingMd,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    UiConstants.radiusXl,
                                  ),
                                  bottomRight: Radius.circular(
                                    UiConstants.radiusXl,
                                  ),
                                ),
                              ),
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    const SizedBox(height: kToolbarHeight),
                                    CustomTextField(
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                      },
                                      hint: 'Search conversations...',
                                      prefixIcon: const Icon(Icons.search),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (filteredRooms.isEmpty)
                          const SliverFillRemaining(child: _EmptyRoomsView())
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final room = filteredRooms[index];

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoomTile(
                                    roomNotifications: roomNotifications,
                                    room: room,
                                    currentUserId: widget.currentUserId,
                                  ),
                                  if (filteredRooms.length > 1 &&
                                      index != filteredRooms.length - 1)
                                    const Divider(),
                                ],
                              );
                            }, childCount: filteredRooms.length),
                          ),
                      ],
                    ),
                  );
                },
              );
            }

            return const _ErrorState();
          },
        ),
      ),
    );
  }

  List<Room> _getFilteredRooms(List<Room> rooms, String currentUserId) {
    if (searchQuery.isEmpty) return rooms;

    return rooms.where((room) {
      return room
          .getDisplayName(currentUserId)
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }
}

class _RoomTile extends StatelessWidget {
  final Room room;
  final String currentUserId;
  final Map<String, List<NotificationEntity>> roomNotifications;

  const _RoomTile({
    required this.room,
    required this.currentUserId,
    this.roomNotifications = const {},
  });

  @override
  Widget build(BuildContext context) {
    final roomNotifs = roomNotifications[room.id] ?? [];

    final unreadCount = roomNotifs
        .where((n) => n.isViewed || n.isUnread)
        .length;
    final hasUnread = unreadCount > 0;

    NotificationEntity? lastNotif;

    if (roomNotifs.isNotEmpty) {
      lastNotif = roomNotifs.reduce(
        (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
      );
    }

    final lastMessageText =
        lastNotif?.body ?? room.getLastMessagePreview(currentUserId);

    final lastMessageTime =
        lastNotif?.createdAt ?? room.lastMessage?.createdAt ?? room.createdAt;

    return Column(
      children: [
        InkWell(
          onTap: () {
            context.push(
              RouteConstants.chatPage,
              extra: {'room': room, 'userId': currentUserId},
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: ClipOval(
                        child:
                            room.getDisplayImage(currentUserId) != null &&
                                room.getDisplayImage(currentUserId)!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: room.getDisplayImage(currentUserId)!,
                                fit: BoxFit.cover,
                                width: 56,
                                height: 56,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(color: Colors.white),
                                    ),
                                errorWidget: (context, error, stackTrace) =>
                                    const Icon(Icons.person),
                              )
                            : Text(
                                room
                                    .getDisplayName(currentUserId)[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    // Member count for organization rooms
                    if (room.organizationId != null &&
                        room.type == RoomType.organization)
                      Positioned(
                        right: -2,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${room.members!.length}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: UiConstants.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.getDisplayName(currentUserId),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormatter.toChatListPreview(lastMessageTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getSubtitleText(lastMessageText),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
      ],
    );
  }

  String _getSubtitleText(String lastMessageText) {
    return room.getLastMessagePreview(currentUserId);
  }
}

class _EmptyRoomsView extends StatelessWidget {
  const _EmptyRoomsView();

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
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 40,
                  color: Theme.of(context).primaryColor.withAlpha(130),
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          const Text(
                'No conversations yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .moveY(begin: 20, end: 0),
          const SizedBox(height: 8),
          Text(
                'Start chatting with your organization members',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

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
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.error.withAlpha(130),
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          const Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .moveY(begin: 20, end: 0),
          const SizedBox(height: 8),
          Text(
                'Something went wrong, please try again or restart the app.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}
