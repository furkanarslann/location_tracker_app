import 'package:flutter/material.dart';
import 'package:location_tracker_app/core/constants/app_constants.dart';
import 'package:location_tracker_app/di/injection.dart';
import 'package:location_tracker_app/presentation/maps/maps_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const LocationTrackerApp());
}

class LocationTrackerApp extends StatelessWidget {
  const LocationTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primaryColor: Colors.green,
        disabledColor: Colors.grey.withValues(alpha: 0.8),
        cardTheme: const CardTheme(color: Colors.white, elevation: 4),
      ),
      home: const MapsPage(),
    );
  }
}
