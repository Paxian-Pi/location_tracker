import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:location_tracker/animations/anumations.dart';
import 'package:location_tracker/components/current_location.dart';
import 'package:location_tracker/model/tracked_location_hive.dart';
import 'package:location_tracker/providers/locations_provider.dart';
import 'package:location_tracker/providers/tracking_provider.dart';
import 'package:location_tracker/components/edit_geo_fence.dart';
import 'package:location_tracker/screens/summary.dart';
import 'package:location_tracker/util/consts.dart';
import 'package:location_tracker/util/functions.dart';
import 'package:location_tracker/util/logger.dart';
import 'package:location_tracker/util/navigator.dart';
import 'package:location_tracker/util/strings.dart';
import 'package:sizer/sizer.dart';

import '../model/daily_summary_hive.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  bool _isTracking = false;
  bool _isWithinGeoFence = false;

  StreamSubscription<Position>? _positionStream;

  // List<TrackedLocation> _locations = [];
  final Map<String, DateTime?> _entryTimes = {};
  Map<String, Duration> _durations = {};

  void _startTracking() async {
    setState(() => _isTracking = true);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((Position pos) {
      _checkGeoFence(pos);
      logPrint(pos);
      ref.read(trackingProvider.notifier).getTrackingData(pos);
    });
  }

  void _stopTracking() {
    final now = DateTime.now().toLocal();

    _entryTimes.forEach((locName, entryTime) {
      logPrint("Location name: $locName, Entry time: $entryTime");

      if (entryTime != null) {
        final spent = now.difference(entryTime);
        _durations[locName] = (_durations[locName] ?? Duration.zero) + spent;
      }
    });
    logPrint(_durations);

    _entryTimes.clear();
    _positionStream?.cancel();
    _positionStream = null;

    _saveSummaryToHive();

    setState(() => _isTracking = false);
    ref.invalidate(trackingProvider);
    FlutterBackgroundService().invoke("stopService");
  }

  void _checkGeoFence(Position pos) {
    final now = DateTime.now().toLocal();
    bool insideAny = false;

    for (var loc in ref.watch(locationsProvider).value ?? []) {
      logPrint("Loaded location: ${loc.name} (${loc.latitude}, ${loc.longitude})");
      logPrint(ref.watch(locationsProvider).value);

      final distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, loc.latitude, loc.longitude);

      logPrint("Distance from Geo-fence: $distance\nGeo-fence: ${loc.radius}");

      final isInside = distance <= loc.radius;
      if (isInside) {
        insideAny = true;

        if (_entryTimes[loc.name] == null) {
          _entryTimes[loc.name] = now;
        }
      } else if (_entryTimes[loc.name] != null) {
        final entry = _entryTimes[loc.name]!;
        final spent = now.difference(entry);

        _durations[loc.name] = (_durations[loc.name] ?? Duration.zero) + spent;
        _entryTimes[loc.name] = null;
      }
    }

    logPrint("Is within Geo-fence: $insideAny");

    if (!insideAny) {
      _isWithinGeoFence = false;
      // Func.showToastification(
      //   title: "Info",
      //   subTitle: "You are out of geo-fence radius!",
      // );

      if (_entryTimes['traveling'] == null) {
        _entryTimes['traveling'] = now;
      }
    } else {
      _isWithinGeoFence = true;

      if (_entryTimes['traveling'] != null) {
        final entry = _entryTimes['traveling']!;
        final spent = now.difference(entry);

        _durations['traveling'] = (_durations['traveling'] ?? Duration.zero) + spent;
        _entryTimes['traveling'] = null;
      }
    }
  }

  Future<void> _loadSavedLocations() async {
    // Open the box, or reuse if already open
    final box = await Hive.openBox<TrackedLocation>(StringValues.locationsBox);

    // Get all saved locations from Hive
    final savedLocations = box.values.toList();
    logPrint(savedLocations.map((e) => e.name).toList());

    setState(() {
      ref.read(locationsProvider.notifier).addLocations(savedLocations);
    });

    logPrint("Number of locations loaded from Hive ${ref.watch(locationsProvider).value?.length}.");
  }

  Future<void> _saveLocationAtCurrent() async {
    final position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    pushToWithTransition(
      context,
      CurrentLocation(locations: ref.watch(locationsProvider).value ?? [], position: position),
      pageTransitionType: PageTransitionType.fromBottom,
    );
  }

  void _openSummary() {
    pushToWithTransition(context, SummaryScreen(durations: _durations));
  }

  void _saveSummaryToHive() async {
    final box = Hive.box<DailySummary>(StringValues.dailySummaryBox);
    final today = DateTime.now().toLocal();
    final key = "${today.year}-${today.month}-${today.day}";

    final summary = DailySummary(date: key, durations: _durations);
    await box.put(key, summary);

    logPrint("Saved summary for $key");
  }

  Future<void> _loadTodaySummary() async {
    final box = Hive.box<DailySummary>(StringValues.dailySummaryBox);
    final today = DateTime.now().toLocal();
    final key = "${today.year}-${today.month}-${today.day}";

    final summary = box.get(key);
    if (summary != null) {
      setState(() {
        _durations = summary.durations;
      });
      logPrint("Loaded summary for $key");
    }
  }

  void _openPastSummary() async {
    final box = Hive.box<DailySummary>(StringValues.dailySummaryBox);
    final keys = box.keys.toList();

    String? date;

    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text("Select Date"),
        children: keys.map((e) {
          return SimpleDialogOption(
            child: Text(e),
            onPressed: () {
              Navigator.pop(context, e);
              date = Func.formatDate(e);
              logPrint(date);
            },
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      final summary = box.get(selected);
      if (summary != null) {
        if (!mounted) return;
        pushToWithTransition(
          context,
          SummaryScreen(durations: summary.durations, date: date),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocations();
    _loadTodaySummary();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      logPrint(ref.watch(locationsProvider).value);
    });

    Func.getPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isTracking) {
      _saveSummaryToHive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Geo-Fence Location Tracker",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_location_alt, color: kPrimaryColor),
            onPressed: _saveLocationAtCurrent,
          ),
        ],
      ),
      body: FadeAnimation(
        duration: const Duration(milliseconds: 1500),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(kPrimaryColor.withOpacity(0.3)),
                          shape: WidgetStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              side: BorderSide(color: kPrimaryColor.withOpacity(0.3), width: 0.8),
                            ),
                          ),
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10)),
                        ),
                        onPressed: () {
                          pushToWithTransition(context, EditRadiusScreen());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.location_searching),
                              const SizedBox(width: 5),
                              Text("Edit Geo-Fence"),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(kPrimaryColor.withOpacity(0.3)),
                          shape: WidgetStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              side: BorderSide(color: kPrimaryColor.withOpacity(0.3), width: 0.8),
                            ),
                          ),
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10)),
                        ),
                        onPressed: _openPastSummary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.history),
                              const SizedBox(width: 5),
                              Text("Past Summary"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100.w,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: kPrimaryColor)),
                          child: _isTracking && !ref.watch(trackingProvider).hasValue
                              ? CupertinoActivityIndicator(
                                  color: kPrimaryColor.withOpacity(0.5),
                                  animating: true,
                                  radius: 13.0,
                                )
                              : !ref.watch(trackingProvider).hasValue
                                  ? FadeAnimation(
                                      duration: const Duration(milliseconds: 1500),
                                      child: Text("You are currently clocked out!"),
                                    )
                                  : FadeAnimation(
                                      duration: const Duration(milliseconds: 1500),
                                      child: Text.rich(
                                        textAlign: TextAlign.start,
                                        TextSpan(
                                          children: [
                                            TextSpan(text: "Geo-Fence Radius: "),
                                            TextSpan(
                                              text: ref.watch(locationsProvider).value != null && ref.watch(locationsProvider).value!.isEmpty
                                                  ? "50.0 meters\n"
                                                  : "${ref.watch(locationsProvider).value?[0].radius.toStringAsFixed(1)} meters\n",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (ref.watch(locationsProvider).value != null && ref.watch(locationsProvider).value!.isNotEmpty)
                                              TextSpan(text: "Coordinates Is "),
                                            if (ref.watch(locationsProvider).value != null && ref.watch(locationsProvider).value!.isNotEmpty)
                                              TextSpan(
                                                text: _isWithinGeoFence ? "Within Geo-Fence: True\n" : "Out of Geo-Fence range\n",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            TextSpan(text: "Tracking...\n"),
                                            TextSpan(
                                              text: "${ref.watch(trackingProvider).value}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: ref.watch(trackingProvider).hasValue ? null : _startTracking,
                              child: const Text("Clock In"),
                            ),
                            ElevatedButton(
                              onPressed: ref.watch(trackingProvider).hasValue ? _stopTracking : null,
                              child: const Text("Clock Out"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 5.h),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(kPrimaryColor.withOpacity(0.3)),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          side: BorderSide(color: kPrimaryColor.withOpacity(0.3), width: 0.8),
                        ),
                      ),
                      padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10)),
                    ),
                    onPressed: _openSummary,
                    child: Container(
                      width: 100.w,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("View Daily Summary", textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
