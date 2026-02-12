import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:app/features/chat/data/models/message_model.dart';
import 'package:app/features/chat/data/models/room_member_model.dart';
import 'package:app/features/chat/data/models/room_model.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/entities/room_member.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  const ChatRepositoryImpl({required this.remoteDataSource});

  // ROOM

  @override
  Future<Either<Failure, Room>> createRoom(Room room) async {
    try {
      final model = RoomModel.fromEntity(room);

      final created = await remoteDataSource.createRoom(model);

      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Room>>> getUserRooms() async {
    try {
      final models = await remoteDataSource.getMyRooms();

      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // MEMBERS

  @override
  Future<Either<Failure, void>> addMembers({
    required String roomId,
    required List<RoomMember> members,
  }) async {
    try {
      final models = members.map((e) => RoomMemberModel.fromEntity(e)).toList();

      await remoteDataSource.addMembers(roomId: roomId, members: models);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // MESSAGE

  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    try {
      final model = MessageModel.fromEntity(message);

      final result = await remoteDataSource.sendMessage(model);

      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String roomId) async {
    try {
      final models = await remoteDataSource.getMessages(roomId: roomId);

      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> streamMessages(String roomId) {
    try {
      return remoteDataSource
          .streamMessages(roomId)
          .map((models) => Right(models.map((m) => m.toEntity()).toList()));
    } catch (e) {
      return Stream.value(Left(UnknownFailure(e.toString())));
    }
  }

  // READ / SEEN

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
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomMember>>> getRoomMembers(
    String roomId,
  ) async {
    try {
      final membersModel = await remoteDataSource.getRoomMembers(roomId);
      final members = membersModel.map((e) => e.toEntity()).toList();

      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
