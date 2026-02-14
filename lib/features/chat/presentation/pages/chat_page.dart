import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/app_bar_popup_menu.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_user_rooms_use_case.dart';
import 'package:app/features/chat/domain/usecases/mark_room_as_read_use_case.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_messages_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/chat/presentation/widgets/chat_detail_shimmer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final Room room;
  final String currentUserId;

  const ChatPage({super.key, required this.room, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        createRoomUseCase: DependencyInjection.get<CreateRoomUseCase>(),
        getUserRoomsUseCase: DependencyInjection.get<GetUserRoomsUseCase>(),
        sendMessageUseCase: DependencyInjection.get<SendMessageUseCase>(),
        streamMessagesUseCase: DependencyInjection.get<StreamMessagesUseCase>(),
        markRoomAsReadUseCase: DependencyInjection.get<MarkRoomAsReadUseCase>(),
      )..add(StreamMessagesRequested(roomId: room.id)),
      child: ChatView(room: room, currentUserId: currentUserId),
    );
  }
}

class ChatView extends StatefulWidget {
  final Room room;
  final String currentUserId;

  const ChatView({super.key, required this.room, required this.currentUserId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _hasLoadedOnce = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: widget.room.id,
      senderId: widget.currentUserId,
      type: MessageType.text,
      text: text,
      createdAt: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessageRequested(message: message));
    _messageController.clear();
    setState(() {
      _isTyping = false;
    });

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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

          // Mark as loaded once we get first stream update
          if (state is MessagesStreamUpdated && !_hasLoadedOnce) {
            setState(() {
              _hasLoadedOnce = true;
            });
          }
        },
        buildWhen: (previous, current) =>
            current is MessagesStreamUpdated ||
            (current is ChatLoading && !_hasLoadedOnce),
        builder: (context, state) {
          // Show shimmer only on initial load
          if (state is ChatLoading && !_hasLoadedOnce) {
            return const ChatDetailShimmerPage();
          }

          if (state is MessagesStreamUpdated) {
            final messages = state.messages;
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Custom App Bar
                      SliverAppBar(
                        pinned: true,
                        floating: true,
                        collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
                        elevation: 0,
                        centerTitle: false,
                        titleSpacing: 0,
                        leading: const BackButton(color: Colors.white),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAppBarAvatar(),
                            const SizedBox(width: UiConstants.spacingSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.room.id, // TODO: Use display name
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // TODO: Add online status or typing indicator
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Video call
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.white),
                            onPressed: () {
                              // TODO: Audio call
                            },
                          ),
                          AppPopupMenu(
                            iconColor: AppColors.white,
                            items: [
                              AppPopupMenuItem(
                                value: 'view_profile',
                                label: 'View Profile',
                                icon: Icons.person,
                                onTap: () {
                                  // Logic to view profile
                                },
                              ),
                              AppPopupMenuItem(
                                value: 'mute_notifications',
                                label: 'Mute Notifications',
                                icon: Icons.notifications_off,
                                onTap: () {
                                  // Logic to mute notification
                                },
                              ),
                              AppPopupMenuItem(
                                value: 'search',
                                label: 'Mute Notifications',
                                icon: Icons.notifications_off,
                                onTap: () {
                                  // Logic to mute notification
                                },
                              ),
                              AppPopupMenuItem(
                                value: 'clear_chat',
                                label: 'Clear Chat',
                                icon: Icons.clear_all,
                                onTap: () {
                                  // Logic to clear chat
                                },
                              ),
                              AppPopupMenuItem(
                                isDistructive: true,
                                value: 'block',
                                label: 'Block',
                                icon: Icons.block,
                                onTap: () {
                                  // Logic to block
                                },
                              ),
                            ],
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  UiConstants.radiusXl,
                                ),
                                bottomRight: Radius.circular(
                                  UiConstants.radiusXl,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Messages Area
                      SliverFillRemaining(
                        hasScrollBody: true,
                        child: Container(
                          child: messages.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(
                                    UiConstants.spacingMd,
                                  ),
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final isMe =
                                        message.senderId ==
                                        widget.currentUserId;
                                    final showTimestamp = _shouldShowTimestamp(
                                      messages,
                                      index,
                                    );

                                    return Column(
                                      children: [
                                        if (showTimestamp)
                                          _buildDateSeparator(
                                            message.createdAt,
                                          ),
                                        _MessageBubble(
                                          message: message,
                                          isMe: isMe,
                                          showAvatar: _shouldShowAvatar(
                                            messages,
                                            index,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInputArea(context),
              ],
            );
          }
          return const ChatDetailShimmerPage();
        },
      ),
    );
  }

  Widget _buildAppBarAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Text(
            widget.room.id.isNotEmpty ? widget.room.id[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        // TODO: Add online indicator when available
        // Positioned(
        //   right: 0,
        //   bottom: 0,
        //   child: Container(
        //     width: 12,
        //     height: 12,
        //     decoration: BoxDecoration(
        //       color: Colors.green,
        //       shape: BoxShape.circle,
        //       border: Border.all(
        //         color: Theme.of(context).primaryColor,
        //         width: 2,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
          const SizedBox(height: UiConstants.spacingMd),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: UiConstants.spacingXs),
          Text(
            'Start the conversation!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiConstants.spacingSm),
      child: Row(
        children: [
          const Expanded(child: Divider(height: 10)),
          const SizedBox(width: UiConstants.spacingXs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.spacingSm,
              vertical: UiConstants.spacingXs,
            ),
            child: Text(
              DateFormatter.format(date),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(width: UiConstants.spacingXs),
          const Expanded(child: Divider(height: 10)),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;
    final current = messages[index];
    final next = messages[index + 1];
    final difference = next.createdAt.difference(current.createdAt);
    return difference.inMinutes > 30;
  }

  bool _shouldShowAvatar(List<Message> messages, int index) {
    if (index == 0) return true;
    final current = messages[index];
    final previous = messages[index - 1];
    return current.senderId != previous.senderId;
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        left: UiConstants.spacingMd,
        right: UiConstants.spacingMd,
        top: UiConstants.spacingSm,
        bottom: UiConstants.spacingLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                // TODO: Show attachment options
              },
            ),
          ),
          const SizedBox(width: UiConstants.spacingSm),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 140),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UiConstants.radiusXl),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UiConstants.radiusXl),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: UiConstants.spacingMd,
                    vertical: UiConstants.spacingSm,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isTyping = value.trim().isNotEmpty;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: UiConstants.spacingSm),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.send_rounded : Icons.mic,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _isTyping ? _sendMessage : _recordVoiceMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _recordVoiceMessage() {
    // TODO: Implement voice recording
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showAvatar ? UiConstants.spacingSm : UiConstants.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for received messages (group chat)
          // TODO: Add avatar when needed for group chats
          // if (!isMe && showAvatar) ...[
          //   CircleAvatar(
          //     radius: 16,
          //     backgroundColor: Colors.grey[300],
          //     child: const Icon(Icons.person, size: 16),
          //   ),
          //   const SizedBox(width: UiConstants.spacingSm),
          // ] else if (!isMe && !showAvatar) ...[
          //   const SizedBox(width: 40),
          // ],

          // Message Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConstants.spacingMd,
                vertical: UiConstants.spacingSm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? UiConstants.radiusLg : 4),
                  topRight: Radius.circular(isMe ? 4 : UiConstants.radiusLg),
                  bottomLeft: const Radius.circular(UiConstants.radiusLg),
                  bottomRight: const Radius.circular(UiConstants.radiusLg),
                ),
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withAlpha(200)
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(200),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all, // TODO: Use actual message status
                          size: 14,
                          color: Colors.white.withAlpha(200),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
