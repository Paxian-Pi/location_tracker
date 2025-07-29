import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker/util/consts.dart';
import 'package:location_tracker/util/logger.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, Duration> durations;
  final String? date;

  const SummaryScreen({super.key, required this.durations, this.date});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat.yMMMd().format(DateTime.now());
    logPrint(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Summary - ${date ?? today}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: durations.entries.map((entry) {

          logPrint("Timestamp: ${entry.value}\n${entry.value.inHours}h ${entry.value.inMinutes}m");

          return ListTile(
            minTileHeight: 5,
            minVerticalPadding: 5,
            subtitle: Text(
              "${kCapitalize(entry.key)}: ${entry.value.inHours}h ${entry.value.inMinutes}m",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
