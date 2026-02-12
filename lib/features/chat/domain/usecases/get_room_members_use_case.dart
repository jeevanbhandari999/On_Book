import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/room_member.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetRoomMembersUseCase {
  final ChatRepository repository;

  GetRoomMembersUseCase(this.repository);

  Future<Either<Failure, List<RoomMember>>> call(String roomId) async {
    return repository.getRoomMembers(roomId);
  }
}
