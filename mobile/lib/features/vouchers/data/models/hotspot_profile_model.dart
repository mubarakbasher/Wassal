import '../../domain/entities/hotspot_profile.dart';

class HotspotProfileModel extends HotspotProfile {
  const HotspotProfileModel({
    required super.id,
    required super.name,
    super.rateLimit,
  });

  factory HotspotProfileModel.fromJson(Map<String, dynamic> json) {
    return HotspotProfileModel(
      id: json['id'],
      name: json['name'],
      rateLimit: json['rateLimit'],
    );
  }
}
