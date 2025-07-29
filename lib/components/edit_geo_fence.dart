import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:location_tracker/components/text_input.dart';
import 'package:location_tracker/model/tracked_location_hive.dart';
import 'package:location_tracker/providers/locations_provider.dart';
import 'package:location_tracker/util/consts.dart';
import 'package:location_tracker/util/functions.dart';
import 'package:location_tracker/util/logger.dart';
import 'package:location_tracker/util/strings.dart';
import 'package:sizer/sizer.dart';

class EditRadiusScreen extends ConsumerStatefulWidget {
  const EditRadiusScreen({super.key});

  @override
  ConsumerState<EditRadiusScreen> createState() => _EditRadiusScreenState();
}

class _EditRadiusScreenState extends ConsumerState<EditRadiusScreen> {
  final _radiusController = TextEditingController();

  void _updateAllRadii(double newRadius) async {
    final box = Hive.box<TrackedLocation>(StringValues.locationsBox);

    for (var loc in box.values) {
      loc.radius = newRadius;
      await loc.save(); // Save each updated object
      logPrint('Updated ${loc.name} to radius: ${loc.radius}');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Radius updated to $newRadius meters for all locations')),
      );

      if (ref.watch(locationsProvider).hasValue && ref.watch(locationsProvider).value!.isEmpty) {
        Func.showToastification(
          title: "Info",
          subTitle: "You've not saved any location... Hence, geo-fence radius is 50m by default!",
          autoCloseDuration: const Duration(milliseconds: 10000),
        );
      }

      Timer(const Duration(milliseconds: 3500), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Edit Geo-Fence for All Locations",
        style: TextStyle(fontSize: 18),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextInput(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              hintText: "Enter new radius (meters)",
            ),
            const SizedBox(height: 20),
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
                final radius = double.tryParse(_radiusController.text);
                if (radius != null && radius > 0) {
                  _updateAllRadii(radius);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid radius")),
                  );
                }

                FocusScope.of(context).unfocus();
              },
              child: Container(
                width: 100.w,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("Apply to All Locations", textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
