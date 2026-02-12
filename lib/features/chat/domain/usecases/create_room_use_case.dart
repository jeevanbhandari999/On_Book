import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class CreateRoomUseCase {
  final ChatRepository repository;

  CreateRoomUseCase(this.repository);

  Future<Either<Failure, Room>> call(Room room) async {
    return repository.createRoom(room);
  }
}
