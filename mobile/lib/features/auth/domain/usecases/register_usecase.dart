import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String email,
    required String password,
    required String name,
    String role = 'OPERATOR',
  }) async {
    return await repository.register(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }
}
