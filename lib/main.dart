import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location_tracker/screens/home.dart';
import 'package:location_tracker/util/functions.dart';
import 'package:location_tracker/util/logger.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Func.setupHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      logPrint("CURRENT SCREEN: ${MediaQuery.of(context).size}");

      return ProviderScope(
        child: ToastificationWrapper(
          child: MaterialApp(
            title: 'Geo-Fence Location Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          ),
        ),
      );
    });
  }
}
