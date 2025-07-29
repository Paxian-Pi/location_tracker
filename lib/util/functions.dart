import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker/model/daily_summary_hive.dart';
import 'package:location_tracker/model/duration_adater_hive.dart';
import 'package:location_tracker/model/tracked_location_hive.dart';
import 'package:location_tracker/util/strings.dart';
import 'package:toastification/toastification.dart';

class Func {
  static Future<Position?> getPermission() async {
    LocationPermission permission;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // If all good, get the position
    return await Geolocator.getCurrentPosition();
  }

  static Future<void> setupHive() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TrackedLocationAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DailySummaryAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DurationAdapter());
    }

    await Hive.openBox<TrackedLocation>(StringValues.locationsBox);
    await Hive.openBox<DailySummary>(StringValues.dailySummaryBox);
  }

  static String formatDate(String rawDate) {
    final parts = rawDate.split('-');
    if (parts.length != 3) return 'Invalid date';

    final year = parts[0];
    final month = parts[1].padLeft(2, '0');
    final day = parts[2].padLeft(2, '0');

    final formattedInput = '$year-$month-$day';
    final parsedDate = DateTime.parse(formattedInput);
    return DateFormat('MMM d, yyyy').format(parsedDate);
  }

  static void showToastification({
    required String title,
    required String subTitle,
    Color? progressColor,
    ToastificationType? type,
    Duration? autoCloseDuration,
  }) {
    toastification.show(
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: title.isNotEmpty,
            child: Text(
              title,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subTitle,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
      showIcon: false,
      // backgroundColor: Colors.black.withOpacity(0.8),
      progressBarTheme: ProgressIndicatorThemeData(
        color: progressColor ?? Colors.blue,
        linearTrackColor: Colors.grey.withOpacity(0.5),
        linearMinHeight: 0.5,
      ),
      type: type ?? ToastificationType.info,
      style: ToastificationStyle.minimal,
      alignment: Alignment.topCenter,
      autoCloseDuration: autoCloseDuration ?? const Duration(seconds: 5),
    );
  }
}