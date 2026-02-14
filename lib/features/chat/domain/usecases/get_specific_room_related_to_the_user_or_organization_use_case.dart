import 'package:app/core/errors/failures.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetSpecificRoomRelatedToTheUserOrOrganizationUseCase {
  final ChatRepository repository;

  GetSpecificRoomRelatedToTheUserOrOrganizationUseCase(this.repository);

  Future<Either<Failure, Room?>> call(
    GetSpecificRoomRelatedToTheUserOrOrganizationParams params,
  ) async {
    // First validate the required fields
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User id is required'));
    }
    return await repository.getSpecificRoom(
      params.userId,
      params.targetUserId,
      params.organizationId,
    );
  }
}

class GetSpecificRoomRelatedToTheUserOrOrganizationParams extends Equatable {
  final String userId;
  final String? targetUserId;
  final String? organizationId;

  const GetSpecificRoomRelatedToTheUserOrOrganizationParams({
    required this.userId,
    this.targetUserId,
    this.organizationId,
  });

  @override
  List<Object?> get props => [userId, targetUserId, organizationId];
}
