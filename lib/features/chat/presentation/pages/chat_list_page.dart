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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
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

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120 + UiConstants.spacingMd,
                  collapsedHeight: 120 + UiConstants.spacingMd,
                  foregroundColor: Colors.white,
                  floating: false,
                  pinned: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
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
                          bottomRight: Radius.circular(UiConstants.radiusXl),
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
                              hint: 'Search What You Want...',
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
                      return _RoomTile(
                        room: room,
                        currentUserId: widget.currentUserId,
                      );
                    }, childCount: filteredRooms.length),
                  ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
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

  const _RoomTile({required this.room, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final unreadCount = 0;
    final hasUnread = unreadCount > 0;

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
                                width: 48,
                                height: 48,
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
                                room.getDisplayName(currentUserId)[0],
                                style: const TextStyle(
                                  fontSize: 20,
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
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormatter.format(room.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Tap to view conversation", // TODO: Show last message
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: Colors.grey[600],
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
        const Divider(),
      ],
    );
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
