import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_user_rooms_use_case.dart';
import 'package:app/features/chat/domain/usecases/mark_room_as_read_use_case.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_messages_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class RoomPage extends StatelessWidget {
  // You might want to pass the current logged-in user ID here
  // or fetch it from your AuthBloc/Cache.
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

class RoomPageView extends StatelessWidget {
  final String currentUserId;
  const RoomPageView({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            print(state.message);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const _RoomListShimmer();
          }

          if (state is UserRoomsLoaded) {
            if (state.rooms.isEmpty) {
              return const _EmptyRoomsView();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(const GetUserRoomsRequested());
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.rooms.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return _RoomTile(room: room, currentUserId: currentUserId);
                },
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final Room room;
  final String currentUserId;

  const _RoomTile({required this.room, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // Assuming your Room entity has a 'lastMessage' or 'updatedAt' field
    // If not, adjust accordingly.
    // final hasImage = room.imageUrl != null && room.imageUrl!.isNotEmpty;
    final hasImage = false;

    return InkWell(
      onTap: () {
        // Here we pass the data to GoRouter
        context.push(
          RouteConstants.chatPage,
          extra: {'room': room, 'userId': currentUserId},
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: null,
              ),
              child: !hasImage
                  ? Center(
                      child: Text(
                        room.id.isNotEmpty ? room.id[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // If you have a timestamp for the last activity
                      if (room.createdAt != null)
                        Text(
                          DateFormatter.format(
                            room.createdAt,
                          ), // Or lastMessageAt
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          // Placeholder for last message if your entity doesn't have it yet
                          "Tap to view conversation",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.normal,
                            // You can add logic here: FontWeight.bold if unread
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread Badge Example
                      // if (room.unreadCount > 0)
                      //   Container(
                      //     margin: const EdgeInsets.only(left: 8),
                      //     padding: const EdgeInsets.all(6),
                      //     decoration: BoxDecoration(
                      //       color: Theme.of(context).primaryColor,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Text(
                      //       room.unreadCount.toString(),
                      //       style: const TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 10,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          Icon(Icons.forum_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with your organization members.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _RoomListShimmer extends StatelessWidget {
  const _RoomListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 120, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
