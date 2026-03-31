import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/entities/room_member.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  // ROOM

  /// Create a new room (dm or organization)
  Future<Either<Failure, Room>> createRoom(
    Room room,
    String userId,
    String? otherUserId,
  );

  /// Get all rooms of current user
  Future<Either<Failure, List<Room>>> getUserRooms();

  /// Add members to a room
  Future<Either<Failure, void>> addMembers({
    required String roomId,
    required List<RoomMember> members,
  });

  // Get the specific room related to the user, organization
  Future<Either<Failure, Room?>> getSpecificRoom(
    String userId,
    String? targetUserId,
    String? organizationId,
  );

  // Get the room through the room Id
  Future<Either<Failure, Room>> getChatRoomById(String roomId);

  // MESSAGE

  /// Send a message
  Future<Either<Failure, Message>> sendMessage(Message message);

  /// Get messages of a room (optional for pagination)
  Future<Either<Failure, List<Message>>> getMessages(String roomId);

  /// Realtime messages stream of a room
  Stream<Either<Failure, List<Message>>> streamMessages(String roomId);

  // SEEN / READ

  /// Update last_read_at for the current user
  Future<Either<Failure, void>> updateLastRead({
    required String roomId,
    required DateTime lastReadAt,
  });

  /// Get members of a room
  Future<Either<Failure, List<RoomMember>>> getRoomMembers(String roomId);


  Stream<Either<Failure, List<Room>>> streamUserRooms();


}
