import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/message.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, Message>> call(Message message) async {
    return repository.sendMessage(message);
  }
}
