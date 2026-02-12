import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? networkName,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
