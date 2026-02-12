import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserRoomsUseCase {
  final ChatRepository repository;

  GetUserRoomsUseCase(this.repository);

  Future<Either<Failure, List<Room>>> call() async {
    return repository.getUserRooms();
  }
}
