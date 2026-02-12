import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class StreamMessagesUseCase {
  final ChatRepository repository;

  StreamMessagesUseCase(this.repository);

  Stream<Either<Failure, List<Message>>> call(String roomId) {
    return repository.streamMessages(roomId);
  }
}
