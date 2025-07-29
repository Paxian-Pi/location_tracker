import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:location_tracker/components/text_input.dart';
import 'package:location_tracker/model/tracked_location_hive.dart';
import 'package:location_tracker/util/consts.dart';
import 'package:location_tracker/util/logger.dart';
import 'package:location_tracker/util/strings.dart';
import 'package:sizer/sizer.dart';

class CurrentLocation extends StatefulWidget {
  final List<TrackedLocation> locations;
  final Position position;

  const CurrentLocation({super.key, required this.locations, required this.position});

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Give this location a name!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text("${widget.position}", style: const TextStyle(fontSize: 14)),
              CustomTextInput(
                controller: _nameController,
                hintText: "Enter a name",
              ),
              const SizedBox(height: 30),
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
                onPressed: () async {
                  final name = _nameController.text.trim();

                  if (name.isNotEmpty) {
                    final newLoc = TrackedLocation(
                      name: name,
                      latitude: widget.position.latitude,
                      longitude: widget.position.longitude,
                    );
                    logPrint('TrackedLocation Model: ${newLoc.radius}');

                    final box = Hive.box<TrackedLocation>(StringValues.locationsBox);
                    await box.add(newLoc);

                    setState(() => widget.locations.add(newLoc));
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: 100.w,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Save", textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
