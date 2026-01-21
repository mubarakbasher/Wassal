import 'package:equatable/equatable.dart';

abstract class AddRouterEvent extends Equatable {
  const AddRouterEvent();

  @override
  List<Object> get props => [];
}

class SubmitAddRouterForm extends AddRouterEvent {
  final String name;
  final String ipAddress;
  final int apiPort;
  final String username;
  final String password;
  final String? description;
  final String? location;

  const SubmitAddRouterForm({
    required this.name,
    required this.ipAddress,
    required this.apiPort,
    required this.username,
    required this.password,
    this.description,
    this.location,
  });

  @override
  List<Object> get props => [name, ipAddress, apiPort, username, password, description ?? '', location ?? ''];
}
