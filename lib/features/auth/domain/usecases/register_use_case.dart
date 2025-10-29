import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      fullname: params.fullname,
      role: params.role,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullname;
  final String role;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullname,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, fullname, role];
}