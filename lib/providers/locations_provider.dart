import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracker/model/tracked_location_hive.dart';

class LocationsNotifier extends StateNotifier<AsyncValue<List<TrackedLocation>>> {
  LocationsNotifier() : super(const AsyncValue.loading());

  Future<List<TrackedLocation>?> addLocations(List<TrackedLocation>? value) async {
    state = const AsyncValue.loading();

    try {
      state = AsyncValue.data(value!);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
    return null;
  }
}

final locationsProvider = StateNotifierProvider.autoDispose<LocationsNotifier, AsyncValue<List<TrackedLocation>>>((ref) {
  final notifier = LocationsNotifier();
  ref.keepAlive();

  return notifier;
});
