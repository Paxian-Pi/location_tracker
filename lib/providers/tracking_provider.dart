import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class ToggleNotifier extends StateNotifier<AsyncValue<Position>> {
  ToggleNotifier() : super(const AsyncValue.loading());

  Future<Position?> getTrackingData(Position? value) async {
    state = const AsyncValue.loading();

    try {
      state = AsyncValue.data(value!);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
    return null;
  }
}

final trackingProvider = StateNotifierProvider.autoDispose<ToggleNotifier, AsyncValue<Position>>((ref) {
  final notifier = ToggleNotifier();
  ref.keepAlive();

  return notifier;
});
