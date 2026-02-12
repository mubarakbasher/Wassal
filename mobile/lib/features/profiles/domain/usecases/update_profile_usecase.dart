import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams {
  final String? name;
  final String? email;
  final String? networkName;

  UpdateProfileParams({
    this.name,
    this.email,
    this.networkName,
  });
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      networkName: params.networkName,
    );
  }
}
