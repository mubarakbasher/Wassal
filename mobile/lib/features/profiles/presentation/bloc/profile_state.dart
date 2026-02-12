import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdateSuccess extends ProfileState {
  final User user;
  final String message;

  const ProfileUpdateSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
