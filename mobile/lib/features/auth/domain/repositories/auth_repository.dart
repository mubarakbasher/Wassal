import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
    String role = 'OPERATOR',
  });

  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? password,
    String? networkName,
  });

  Future<Either<Failure, User>> getProfile();
  
  Future<Either<Failure, void>> logout();
  
  Future<bool> isLoggedIn();
}
