import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    // Validate password length
    if (params.newPassword.length < 8) {
      return Left(ValidationFailure('Password must be at least 8 characters'));
    }

    return await repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
