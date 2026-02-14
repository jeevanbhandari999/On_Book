import 'dart:async';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_user_rooms_use_case.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_messages_use_case.dart';
import 'package:app/features/chat/domain/usecases/mark_room_as_read_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

/// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class CreateRoomRequested extends ChatEvent {
  final Room room;
  final String userId;
  final String? otherUserId;
  const CreateRoomRequested({
    required this.room,
    required this.userId,
    this.otherUserId,
  });

  @override
  List<Object?> get props => [room, userId, otherUserId];
}

class GetUserRoomsRequested extends ChatEvent {
  const GetUserRoomsRequested();
}

class SendMessageRequested extends ChatEvent {
  final Message message;
  const SendMessageRequested({required this.message});

  @override
  List<Object?> get props => [message];
}

class StreamMessagesRequested extends ChatEvent {
  final String roomId;
  const StreamMessagesRequested({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class MarkRoomAsReadRequested extends ChatEvent {
  final String roomId;
  final DateTime lastReadAt;
  const MarkRoomAsReadRequested({
    required this.roomId,
    required this.lastReadAt,
  });

  @override
  List<Object?> get props => [roomId, lastReadAt];
}

/// States

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RoomCreated extends ChatState {
  final Room room;
  const RoomCreated({required this.room});

  @override
  List<Object?> get props => [room];
}

class UserRoomsLoaded extends ChatState {
  final List<Room> rooms;
  const UserRoomsLoaded({required this.rooms});

  @override
  List<Object?> get props => [rooms];
}

class MessageSent extends ChatState {
  final Message message;
  const MessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessagesStreamUpdated extends ChatState {
  final List<Message> messages;
  const MessagesStreamUpdated({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class RoomMarkedAsRead extends ChatState {
  const RoomMarkedAsRead();
}

/// BLoC

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateRoomUseCase createRoomUseCase;
  final GetUserRoomsUseCase getUserRoomsUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final StreamMessagesUseCase streamMessagesUseCase;
  final MarkRoomAsReadUseCase markRoomAsReadUseCase;

  StreamSubscription<Either<Failure, List<Message>>>? _messageStreamSub;

  ChatBloc({
    required this.createRoomUseCase,
    required this.getUserRoomsUseCase,
    required this.sendMessageUseCase,
    required this.streamMessagesUseCase,
    required this.markRoomAsReadUseCase,
  }) : super(const ChatInitial()) {
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<GetUserRoomsRequested>(_onGetUserRoomsRequested);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<StreamMessagesRequested>(_onStreamMessagesRequested);
    on<MarkRoomAsReadRequested>(_onMarkRoomAsReadRequested);
  }

  Future<void> _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final result = await createRoomUseCase(
        event.room,
        event.userId,
        event.otherUserId,
      );
      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (room) => emit(RoomCreated(room: room)),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onGetUserRoomsRequested(
    GetUserRoomsRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final result = await getUserRoomsUseCase();
      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (rooms) => emit(UserRoomsLoaded(rooms: rooms)),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessageRequested(
    SendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final result = await sendMessageUseCase(event.message);
      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (message) => emit(MessageSent(message: message)),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onStreamMessagesRequested(
    StreamMessagesRequested event,
    Emitter<ChatState> emit,
  ) async {
    await emit.forEach(
      streamMessagesUseCase(event.roomId),
      onData: (either) {
        return either.fold(
          (failure) => ChatError(message: failure.message),
          (messages) => MessagesStreamUpdated(messages: messages),
        );
      },
      onError: (error, stackTrace) => ChatError(message: error.toString()),
    );
  }

  Future<void> _onMarkRoomAsReadRequested(
    MarkRoomAsReadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final result = await markRoomAsReadUseCase(
        roomId: event.roomId,
        lastReadAt: event.lastReadAt,
      );
      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (_) => emit(const RoomMarkedAsRead()),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageStreamSub?.cancel();
    return super.close();
  }
}
