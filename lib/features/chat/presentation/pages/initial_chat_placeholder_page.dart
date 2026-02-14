import 'package:app/app/dependency_injection.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_user_rooms_use_case.dart';
import 'package:app/features/chat/domain/usecases/mark_room_as_read_use_case.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_messages_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_page.dart';

class InitialChatPlaceholderPage extends StatelessWidget {
  final String? organizationId;
  final String userId;
  final String? targetUserId;

  const InitialChatPlaceholderPage({
    super.key,
    this.organizationId,
    required this.userId,
    this.targetUserId,
  });

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
      child: const InitialChatPlaceholderView(),
    );
  }
}

class InitialChatPlaceholderView extends StatelessWidget {
  const InitialChatPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
