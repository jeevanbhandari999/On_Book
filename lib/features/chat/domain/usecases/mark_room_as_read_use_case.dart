import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class MarkRoomAsReadUseCase {
  final ChatRepository repository;

  MarkRoomAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String roomId,
    required DateTime lastReadAt,
  }) async {
    return repository.updateLastRead(
      roomId: roomId,
      lastReadAt: lastReadAt,
    );
  }
}
