import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
    String? name,
    String? email,
    String? password,
    String? networkName,
  }) async {
    return await repository.updateProfile(
      name: name,
      email: email,
      password: password,
      networkName: networkName,
    );
  }
}
