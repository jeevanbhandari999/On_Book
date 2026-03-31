import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class StreamUserRoomsUseCase {
  final ChatRepository repository;
  StreamUserRoomsUseCase(this.repository);

  Stream<Either<Failure, List<Room>>> call() => repository.streamUserRooms();
}
