import 'package:hive/hive.dart';

part 'daily_summary_hive.g.dart';

@HiveType(typeId: 1)
class DailySummary extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final Map<String, Duration> durations;

  DailySummary({required this.date, required this.durations});
}