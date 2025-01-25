import 'package:flutter/material.dart';
import 'package:location_tracker_app/pages/google_maps_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GoogleMapPage(),
    );
  }
}
