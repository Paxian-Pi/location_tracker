import 'package:hive/hive.dart';

part 'tracked_location_hive.g.dart'; // Required for generated code

@HiveType(typeId: 0)
class TrackedLocation extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  double radius;

  TrackedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 50,
  });
}
