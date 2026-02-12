import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/update_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final userModel = await remoteDataSource.getProfile();
      return Right(User(
        id: userModel.id,
        email: userModel.email,
        name: userModel.name,
        networkName: userModel.networkName,
        role: userModel.role,
        isActive: userModel.isActive,
        createdAt: userModel.createdAt,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? networkName,
  }) async {
    try {
      // Get current user ID from profile first
      final currentProfile = await remoteDataSource.getProfile();
      
      final dto = UpdateProfileDto(
        name: name,
        email: email,
        networkName: networkName,
      );

      final userModel = await remoteDataSource.updateProfile(currentProfile.id, dto);
      
      return Right(User(
        id: userModel.id,
        email: userModel.email,
        name: userModel.name,
        networkName: userModel.networkName,
        role: userModel.role,
        isActive: userModel.isActive,
        createdAt: userModel.createdAt,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Get current user ID
      final currentProfile = await remoteDataSource.getProfile();
      
      // Update with new password
      final dto = UpdateProfileDto(password: newPassword);
      await remoteDataSource.updateProfile(currentProfile.id, dto);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
