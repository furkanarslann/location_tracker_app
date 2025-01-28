import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_tracker_app/di/injection.dart';
import 'package:location_tracker_app/presentation/bloc/location_bloc/location_bloc.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc/maps_bloc.dart';
import 'package:location_tracker_app/presentation/bloc/location_bloc/location_event.dart';
import 'package:location_tracker_app/presentation/bloc/location_bloc/location_state.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker_app/presentation/maps/widgets/error_snackbar.dart';
import 'package:location_tracker_app/presentation/maps/widgets/google_maps_view.dart';
import 'package:location_tracker_app/presentation/maps/widgets/maps_control_menu_view.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<LocationBloc>()..add(InitializeLocation()),
        ),
        BlocProvider(create: (_) => getIt<MapsBloc>()),
      ],
      child: BlocListener<LocationBloc, LocationState>(
        listenWhen: (previous, current) {
          return previous.permissionStatus != current.permissionStatus ||
              previous.isLocationServiceEnabled !=
                  current.isLocationServiceEnabled ||
              previous.failure != current.failure;
        },
        listener: _handleLocationPermissionAndService,
        child: Scaffold(
          body: BlocConsumer<MapsBloc, MapsState>(
            listenWhen: (previous, current) {
              return !previous.hasFailed && current.hasFailed;
            },
            listener: _handleMapsFailure,
            buildWhen: (previous, current) {
              return previous.initialCameraPosition !=
                  current.initialCameraPosition;
            },
            builder: (context, state) {
              if (state.initialCameraPosition == null) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return Stack(
                children: [
                  const GoogleMapsView(),
                  const MapsControlMenuView(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleMapsFailure(BuildContext context, MapsState state) {
    assert(state.hasFailed);
    final failure = state.failure!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(ErrorSnackBar(context, failure: failure));
  }

  void _handleLocationPermissionAndService(
    BuildContext context,
    LocationState state,
  ) {
    if (!state.isLocationServiceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enable location services'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () {
              context.read<LocationBloc>().add(OpenLocationSettings());
            },
          ),
        ),
      );
    } else if (state.permissionStatus == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission is required'),
          action: SnackBarAction(
            label: 'Grant',
            onPressed: () {
              context.read<LocationBloc>().add(RequestLocationPermission());
            },
          ),
        ),
      );
    } else if (state.permissionStatus == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission is required'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () {
              context.read<LocationBloc>().add(OpenAppSettings());
            },
          ),
        ),
      );
    } else if (state.permissionStatus == LocationPermission.whileInUse ||
        state.permissionStatus == LocationPermission.always) {
      context.read<MapsBloc>().add(MapsInitialized());
    } else {
      if (state.failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }
}
