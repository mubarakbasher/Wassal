import 'package:equatable/equatable.dart';

class HotspotProfile extends Equatable {
  final String id;
  final String name;
  final String? rateLimit;

  const HotspotProfile({
    required this.id,
    required this.name,
    this.rateLimit,
  });

  @override
  List<Object?> get props => [id, name, rateLimit];
}
