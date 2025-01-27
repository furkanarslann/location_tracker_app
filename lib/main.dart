import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:location_tracker_app/core/constants/app_constants.dart';
import 'package:location_tracker_app/core/services/geolocator_service.dart';
import 'package:location_tracker_app/core/services/geocoding_service.dart';
import 'package:location_tracker_app/core/services/route_service.dart';
import 'package:location_tracker_app/data/repositories/location_repository_impl.dart';
import 'package:location_tracker_app/data/repositories/maps_repository_impl.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';
import 'package:location_tracker_app/domain/repositories/maps_repository.dart';
import 'package:location_tracker_app/presentation/bloc/location_bloc/location_bloc.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc/maps_bloc.dart';
import 'package:location_tracker_app/presentation/maps/maps_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<GeolocatorService>(() => GeolocatorService());
  getIt.registerLazySingleton<GeocodingService>(() => GeocodingService());
  getIt.registerLazySingleton<RouteService>(
    () => RouteService(
      PolylinePoints(),
      sharedPreferences,
    ),
  );

  // Repositories
  getIt.registerLazySingleton<MapsRepository>(
    () => MapsRepositoryImpl(
      geoLocatorService: getIt<GeolocatorService>(),
      routeService: getIt<RouteService>(),
      geocodingService: getIt<GeocodingService>(),
    ),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      geolocatorService: getIt<GeolocatorService>(),
    ),
  );

  // Blocs
  getIt.registerFactory<MapsBloc>(
    () => MapsBloc(getIt<MapsRepository>()),
  );
  getIt.registerFactory<LocationBloc>(
    () => LocationBloc(getIt<LocationRepository>()),
  );
}

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
