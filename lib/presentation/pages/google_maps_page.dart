import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:location_tracker_app/core/constants/map_constants.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('Location Tracker'),
        actions: [
          BlocBuilder<MapsBloc, MapsState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isTracking ? Icons.stop : Icons.play_arrow),
                onPressed: () {
                  final event = state.isTracking
                      ? MapsLocationTrackingStopped()
                      : MapsLocationTrackingStarted();
                  context.read<MapsBloc>().add(event);
                },
                tooltip: state.isTracking ? 'Stop Tracking' : 'Start Tracking',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MapsBloc>().add(MapsRouteReset()),
            tooltip: 'Reset Route',
          ),
        ],
      ),
      body: BlocConsumer<MapsBloc, MapsState>(
        listener: (context, state) => _handleErrors(state, context),
        builder: (context, state) {
          log('Rebuilding GoogleMapPage...', name: 'GoogleMapPage');
          if (state.permissionGrantedButNoLocation) {
            return const _RetryContent();
          }

          if (state.cameraPosition == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: state.cameraPosition!,
              zoom: MapConstants.defaultZoom,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: state.isTracking,
            myLocationButtonEnabled: state.isTracking,
            zoomControlsEnabled: true,
            compassEnabled: true,
            markers: state.markers,
            polylines: <Polyline>{
              if (state.routePositions.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.green,
                  width: 5,
                  points: state.routePositions,
                ),
            },
            onLongPress: (LatLng position) async {
              if (!state.isTracking) return;
              context.read<MapsBloc>().add(MapsRouteAdded(position));
              await Haptics.vibrate(HapticsType.selection);
            },
          );
        },
      ),
    );
  }

  void _handleErrors(MapsState state, BuildContext context) {
    if (state.hasError) {
      final error = state.error;
      if (error is LocationPermissionDeniedFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred!')),
        );
      }
    }
  }
}

class _RetryContent extends StatelessWidget {
  const _RetryContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your location could not be determined in time! Please retry.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MapsBloc>().add(MapsInitialized());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
