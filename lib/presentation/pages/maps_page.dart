import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:location_tracker_app/core/constants/map_constants.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc.dart';
import 'package:location_tracker_app/presentation/pages/widgets/maps_retry_content.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
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
      body: MultiBlocListener(
        listeners: [
          _handleErrorsBlocListener(),
          _handleCameraUpdatesBlocListener(),
        ],
        child: BlocBuilder<MapsBloc, MapsState>(
          builder: (context, state) {
            log('Rebuilding GoogleMapPage...', name: 'GoogleMapPage');
            if (state.permissionGrantedButNoLocation) {
              return const MapsRetryContent();
            }

            if (state.initialCameraPosition == null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: state.initialCameraPosition!,
                    zoom: MapConstants.defaultZoom,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: state.isTracking,
                  myLocationButtonEnabled: false,
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
                ),
                if (state.isTracking) ...[
                  Positioned(
                    right: 16,
                    bottom: MediaQuery.viewPaddingOf(context).bottom,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Icon(
                        color: state.isCameraLocked ? Colors.red : Colors.green,
                        state.isCameraLocked
                            ? Icons.location_disabled
                            : Icons.my_location,
                      ),
                      onPressed: () {
                        context.read<MapsBloc>().add(MapsCameraLockToggled());
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  BlocListener<MapsBloc, MapsState> _handleCameraUpdatesBlocListener() {
    return BlocListener<MapsBloc, MapsState>(
      listenWhen: (previous, current) {
        return previous.currentLocation != current.currentLocation ||
            previous.isCameraLocked != current.isCameraLocked ||
            previous.isTracking != current.isTracking;
      },
      listener: (_, state) {
        if (state.isCameraLocked && state.isTracking) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(state.currentLocation!.position),
          );
        }
      },
    );
  }

  BlocListener<MapsBloc, MapsState> _handleErrorsBlocListener() {
    return BlocListener<MapsBloc, MapsState>(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (context, state) {
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
      },
    );
  }
}
