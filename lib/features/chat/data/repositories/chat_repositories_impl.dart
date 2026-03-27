import 'dart:async';
import 'package:app/features/chat/data/models/room_member_model.dart';
import 'package:app/features/notifications/domain/entities/notification_entity.dart';
import 'package:app/features/notifications/presentation/services/notification_creator_service.dart';
import 'package:app/features/notifications/presentation/services/notification_service.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_member.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';
import '../models/room_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  // ===========================================================================
  // ROOMS
  // ===========================================================================

  @override
  Future<Either<Failure, Room>> createRoom(
    Room room,
    String userId,
    String? otherUserId,
  ) async {
    try {
      // 1. Convert Domain Entity -> Model
      final roomModel = RoomModel.fromEntity(room);

      // 2. Call Remote Data Source
      final result = await remoteDataSource.createRoom(
        roomModel,
        userId,
        otherUserId,
      );

      // 3. Convert Model -> Domain Entity
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Room>>> getUserRooms() async {
    try {
      final roomModels = await remoteDataSource.getMyRooms();

      final rooms = roomModels.map((model) => model.toEntity()).toList();
      return Right(rooms);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMembers({
    required String roomId,
    required List<RoomMember> members,
  }) async {
    try {
      // Extract User IDs from the entities to pass to the lightweight RDS method
      final List<String> userIds = members.map((m) => m.userId).toList();

      await remoteDataSource.addMembers(roomId: roomId, userIds: userIds);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomMember>>> getRoomMembers(
    String roomId,
  ) async {
    try {
      final memberModels = await remoteDataSource.getRoomMembers(roomId);

      final members = memberModels.map((m) => m.toEntity()).toList();
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // MESSAGES
  // ===========================================================================
  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);

      // 1. Send the message
      final result = await remoteDataSource.sendMessage(messageModel);

      // 2. Fetch members
      final members = await remoteDataSource.getRoomMembers(
        messageModel.roomId,
      );

      RoomMemberModel? sender;

      try {
        sender = members.firstWhere((m) => m.userId == messageModel.senderId);
      } catch (_) {
        sender = null;
      }

      final senderName = sender?.user?.fullName ?? 'Someone';
      // // 4. Notify others
      for (final member in members) {
        if (member.userId == messageModel.senderId) continue;

        await NotificationCreatorService.instance.chatMessage(
          recipientId: member.userId,
          senderId: messageModel.senderId,
          roomId: messageModel.roomId,
          senderName: senderName,
          messagePreview: messageModel.text ?? '📎 Attachment',
        );
      }

      // await NotificationService.instance.showFromEntity(
      //   NotificationEntity(
      //     id: 'temp',
      //     recipientId: 'recipient-id',
      //     title: 'Manual Test',
      //     body: 'Works?',
      //     status: NotificationStatus.unread,
      //     createdAt: DateTime.now(),
      //     type: NotificationType.chatMessage,
      //   ),
      // );

      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String roomId) async {
    try {
      final messageModels = await remoteDataSource.getMessages(roomId: roomId);

      final messages = messageModels.map((m) => m.toEntity()).toList();
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> streamMessages(String roomId) {
    return remoteDataSource
        .streamMessages(roomId)
        .map((models) {
          // Success case: Map List<Model> -> List<Entity>
          final entities = models.map((m) => m.toEntity()).toList();
          return Right<Failure, List<Message>>(entities);
        })
        .handleError((error) {
          // Error case: Wrap in Failure
          if (error is ServerException) {
            return Left<Failure, List<Message>>(ServerFailure(error.message));
          }
          return Left<Failure, List<Message>>(ServerFailure(error.toString()));
        });
  }

  // ===========================================================================
  // READ STATUS
  // ===========================================================================

  @override
  Future<Either<Failure, void>> updateLastRead({
    required String roomId,
    required DateTime lastReadAt,
  }) async {
    try {
      await remoteDataSource.updateLastRead(
        roomId: roomId,
        lastReadAt: lastReadAt,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Room?>> getSpecificRoom(
    String userId,
    String? targetUserId,
    String? organizationId,
  ) async {
    try {
      final result = await remoteDataSource.getSpecificRoom(
        userId,
        targetUserId,
        organizationId,
      );
      if (result != null) {
        return Right(result.toEntity());
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
