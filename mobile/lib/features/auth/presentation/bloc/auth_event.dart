import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    this.role = 'OPERATOR',
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class GetProfileEvent extends AuthEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? email;
  final String? password;
  final String? networkName;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.password,
    this.networkName,
  });

  @override
  List<Object?> get props => [name, email, password, networkName];
}
