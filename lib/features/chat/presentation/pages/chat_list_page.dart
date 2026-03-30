import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_user_rooms_use_case.dart';
import 'package:app/features/chat/domain/usecases/mark_room_as_read_use_case.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_messages_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/chat/presentation/widgets/chat_list_shimmer.dart';
import 'package:app/features/chat/service/presence_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class RoomPage extends StatelessWidget {
  final String currentUserId;

  const RoomPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        createRoomUseCase: DependencyInjection.get<CreateRoomUseCase>(),
        getUserRoomsUseCase: DependencyInjection.get<GetUserRoomsUseCase>(),
        sendMessageUseCase: DependencyInjection.get<SendMessageUseCase>(),
        streamMessagesUseCase: DependencyInjection.get<StreamMessagesUseCase>(),
        markRoomAsReadUseCase: DependencyInjection.get<MarkRoomAsReadUseCase>(),
      )..add(const GetUserRoomsRequested()),
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
  final PresenceService _presenceService = PresenceService();
  bool _hasInitializedPresence = false;

  // Stream subscription for presence updates
  final Map<String, StreamSubscription<Set<String>>> _presenceSubscriptions =
      {};
  Set<String> _allOnlineUsers = {};

  @override
  void dispose() {
    // Cancel all presence subscriptions
    for (final subscription in _presenceSubscriptions.values) {
      subscription.cancel();
    }
    _presenceSubscriptions.clear();
    super.dispose();
  }

  Future<void> _initializePresenceForAllRooms(List<Room> rooms) async {
    if (_hasInitializedPresence) return;

    debugPrint('🌐 Initializing presence for ${rooms.length} rooms');
    _hasInitializedPresence = true;

    final roomIds = rooms.map((room) => room.id).toList();
    await _presenceService.joinAllUserRooms(roomIds, widget.currentUserId);

    // Subscribe to online users for each room
    for (final room in rooms) {
      _presenceSubscriptions[room.id]?.cancel();
      _presenceSubscriptions[room.id] = _presenceService
          .onlineUsersStream(room.id)
          .listen((onlineUsers) {
            if (mounted) {
              setState(() {
                // Aggregate all online users
                _updateAllOnlineUsers(rooms);
              });
            }
          });
    }
  }

  void _updateAllOnlineUsers(List<Room> rooms) {
    final allOnline = <String>{};
    for (final room in rooms) {
      allOnline.addAll(_presenceService.getOnlineUsers(room.id));
    }
    _allOnlineUsers = allOnline;
  }

  String? _getOtherUserId(Room room) {
    if (room.type != RoomType.dm) return null;

    final members = room.members;
    if (members == null || members.isEmpty) return null;

    for (final member in members) {
      if (member.userId != widget.currentUserId) {
        return member.userId;
      }
    }
    return null;
  }

  bool _isUserOnline(Room room) {
    final otherUserId = _getOtherUserId(room);
    if (otherUserId == null) return false;
    return _presenceService.isUserOnline(room.id, otherUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          // Initialize presence when rooms are loaded
          if (state is UserRoomsLoaded && !_hasInitializedPresence) {
            _initializePresenceForAllRooms(state.rooms);
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const ChatListShimmerPage();
            }

            if (state is UserRoomsLoaded) {
              final filteredRooms = _getFilteredRooms(
                state.rooms,
                widget.currentUserId,
              );
              // TODO: Calculate actual unread count
              final unreadCount = 0;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatBloc>().add(const GetUserRoomsRequested());
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120 + UiConstants.spacingMd,
                      collapsedHeight: 120 + UiConstants.spacingMd,
                      foregroundColor: Colors.black,
                      backgroundColor: AppColors.primaryLight,
                      floating: false,
                      pinned: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Messages',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  UiConstants.radiusRound,
                                ),
                              ),
                              child: Text('$unreadCount'),
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
                              bottomLeft: Radius.circular(UiConstants.radiusXl),
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
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final room = filteredRooms[index];
                          final isOnline = _isUserOnline(room);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RoomTile(
                                room: room,
                                currentUserId: widget.currentUserId,
                                isOnline: isOnline,
                                presenceService: _presenceService,
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
            }

            return const Center(child: Text('Something went wrong'));
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
  final bool isOnline;
  final PresenceService presenceService;

  const _RoomTile({
    required this.room,
    required this.currentUserId,
    required this.isOnline,
    required this.presenceService,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = 0; // TODO: Calculate actual unread count
    final hasUnread = unreadCount > 0;
    final shouldShowOnlineIndicator = room.type == RoomType.dm;

    // Get online count for organization rooms
    final onlineCount = room.type == RoomType.organization
        ? presenceService.getOnlineUsers(room.id).length
        : 0;

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

                    // Online indicator for DM rooms
                    if (shouldShowOnlineIndicator && isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                            DateFormatter.format(
                              room.lastMessage?.createdAt ?? room.createdAt,
                            ),
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
                              _getSubtitleText(room, isOnline, onlineCount),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: (shouldShowOnlineIndicator && isOnline)
                                    ? Colors.green
                                    : Colors.black,
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

  String _getSubtitleText(Room room, bool isOnline, int onlineCount) {
    // For DM rooms, show online status or last message
    if (room.type == RoomType.dm) {
      if (isOnline) {
        return 'Online';
      }
      return room.getLastMessagePreview(currentUserId);
    }

    // For organization rooms, show online count
    if (room.type == RoomType.organization) {
      final totalMembers = room.members?.length ?? 0;
      if (onlineCount > 0) {
        return '$onlineCount online • $totalMembers members';
      }
      return room.getLastMessagePreview(currentUserId);
    }

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
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with your organization members',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
