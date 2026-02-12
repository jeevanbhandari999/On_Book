import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart'; // Assumed based on context
import 'package:app/core/utils/date_formatter.dart'; // Assumed based on context
import 'package:app/features/chat/domain/entities/message.dart';
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
import 'package:shimmer/shimmer.dart';

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
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Create message entity
    // Note: Adjust the fields below to match your Message entity constructor
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
      roomId: widget.room.id,
      senderId: widget.currentUserId,
      type: MessageType.text,
      text: text,
      createdAt: DateTime.now(),
      // isRead: false,
    );

    context.read<ChatBloc>().add(SendMessageRequested(message: message));
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  print(state.message);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
                // Optional: Scroll to bottom when new message sent
                if (state is MessageSent) {
                  // Logic to scroll to bottom if needed
                }
              },
              buildWhen: (previous, current) =>
                  current is MessagesStreamUpdated ||
                  current is ChatLoading ||
                  current is ChatError,
              builder: (context, state) {
                if (state is ChatLoading && state is! MessagesStreamUpdated) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Message> messages = [];
                if (state is MessagesStreamUpdated) {
                  messages = state.messages;
                }

                if (messages.isEmpty && state is! ChatLoading) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Standard chat behavior
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    final showDate = _shouldShowDate(messages, index);

                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(message.createdAt),
                        _MessageBubble(message: message, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            // backgroundImage:
            //     (widget.room.imageUrl != null && widget.room.imageUrl!.isNotEmpty)
            //         ? CachedNetworkImageProvider(widget.room.imageUrl!)
            //         : null,
            // child: (widget.room.imageUrl == null || widget.room.imageUrl!.isEmpty)
            //     ?
            //      Text(
            //         widget.room.name.isNotEmpty
            //             ? widget.room.name[0].toUpperCase()
            //             : '?',
            //         style: TextStyle(
            //           color: Theme.of(context).primaryColor,
            //           fontSize: 16,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       )
            //     : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Optional: status indicator
                // Text(
                //   'Online',
                //   style: TextStyle(fontSize: 12, color: Colors.green),
                // ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Logic for room details or settings
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No messages here yet...',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          Text(
            'Send a message to start the conversation.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            DateFormatter.format(date), // Assuming this exists based on imports
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDate(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;
    final current = messages[index];
    final next = messages[index + 1];
    // Simple check: if different days
    return current.createdAt.day != next.createdAt.day ||
        current.createdAt.month != next.createdAt.month ||
        current.createdAt.year != next.createdAt.year;
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Optional: Attachment button
            // IconButton(
            //   icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
            //   onPressed: () {},
            // ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    // Simple helper or usage of DateFormatter
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
