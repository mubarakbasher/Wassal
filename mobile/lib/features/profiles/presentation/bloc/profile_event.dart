import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? email;
  final String? networkName;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.networkName,
  });

  @override
  List<Object?> get props => [name, email, networkName];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
