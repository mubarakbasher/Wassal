import 'package:equatable/equatable.dart';
import '../../domain/entities/router.dart';

abstract class RouterEvent extends Equatable {
  const RouterEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoutersEvent extends RouterEvent {
  const LoadRoutersEvent();
}

class CreateRouterEvent extends RouterEvent {
  final String name;
  final String ipAddress;
  final int apiPort;
  final String username;
  final String password;

  const CreateRouterEvent({
    required this.name,
    required this.ipAddress,
    required this.apiPort,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [name, ipAddress, apiPort, username, password];
}

class UpdateRouterEvent extends RouterEvent {
  final String id;
  final String name;
  final String ipAddress;
  final int apiPort;
  final String username;
  final String? password;

  const UpdateRouterEvent({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.apiPort,
    required this.username,
    this.password,
  });

  @override
  List<Object?> get props => [id, name, ipAddress, apiPort, username, password];
}

class DeleteRouterEvent extends RouterEvent {
  final String id;

  const DeleteRouterEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CheckRouterHealthEvent extends RouterEvent {
  final String id;

  const CheckRouterHealthEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectRouterEvent extends RouterEvent {
  final Router? router;

  const SelectRouterEvent(this.router);

  @override
  List<Object?> get props => [router];
}
