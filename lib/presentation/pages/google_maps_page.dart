import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _isTracking = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _toggleTracking(BuildContext context) {
    setState(() => _isTracking = !_isTracking);
    context.read<MapsBloc>().add(_isTracking
        ? MapsLocationTrackingStarted()
        : MapsLocationTrackingStopped());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        actions: [
          BlocBuilder<MapsBloc, MapsState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                onPressed: () => _toggleTracking(context),
                tooltip: _isTracking ? 'Stop Tracking' : 'Start Tracking',
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
          if (state.permissionGrantedButNoLocation) {
            return _RetryContent();
          }

          if (state.initialPosition == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: state.initialPosition!,
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
