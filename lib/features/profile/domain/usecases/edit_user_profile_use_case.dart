import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class EditUserProfileUseCase {
  final ProfileRepository repository;

  EditUserProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(EditUserProfileParams params) async {
    // First of all validate the required fields;
    if (params.userId.trim().isEmpty) {
      return const Left(ValidationFailure('User Id is required'));
    }

    if (params.fullName.trim().isEmpty) {
      return const Left(ValidationFailure('Full name is required'));
    }

    // Fetch the existing profile first
    final existingProfile = await repository.getUserProfileDetailById(
      params.userId,
    );
    if (existingProfile.isLeft()) {
      return existingProfile.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected profile result'),
      );
    }

    final existing = existingProfile.fold(
      (_) => throw Exception('Profile detail not found'),
      (p) => p,
    );

    final now = DateTime.now();
    final updated = existing.copyWith(
      fullName: params.fullName.trim(),
      address: params.address?.trim(),
      phone: params.phone?.trim(),
      updatedAt: now,
    );

    return await repository.updateUserProfile(updated, null, '');
  }
}

class EditUserProfileParams extends Equatable {
  final String userId;
  final String fullName;
  final String? phone;
  final String? address;
  final DateTime updatedAt;

  const EditUserProfileParams({
    required this.userId,
    required this.fullName,
    this.phone,
    this.address,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [userId, fullName, phone, address, updatedAt];

  EditUserProfileParams copyWith({
    String? userId,
    String? fullName,
    String? phone,
    String? address,
    DateTime? updatedAt,
  }) {
    return EditUserProfileParams(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
