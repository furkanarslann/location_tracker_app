import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:location_tracker_app/core/services/geo_locator_service.dart';
import 'package:location_tracker_app/core/services/route_service.dart';
import 'package:location_tracker_app/data/repositories/location_repository_impl.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc.dart';
import 'package:location_tracker_app/presentation/pages/google_maps_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<GeolocatorService>(() => GeolocatorService());
  getIt.registerLazySingletonAsync<RouteService>(
    () async => RouteService(
      polylinePoints: PolylinePoints(),
      sharedPreferences: await SharedPreferences.getInstance(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      geoLocatorService: getIt<GeolocatorService>(),
      routeService: getIt<RouteService>(),
    ),
  );

  // Blocs
  getIt.registerFactory(
    () => MapsBloc(repository: getIt<LocationRepository>()),
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
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => getIt<MapsBloc>()..add(MapsInitialized()),
        child: const GoogleMapPage(),
      ),
    );
  }
}
