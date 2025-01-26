import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:location_tracker_app/core/constants/map_constants.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc/maps_bloc.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapsBloc, MapsState>(
      listenWhen: (previous, current) {
        return previous.currentLocation != current.currentLocation ||
            previous.isCameraLocked != current.isCameraLocked ||
            previous.isTracking != current.isTracking;
      },
      listener: (_, state) => _handleCameraPositionUpdates(state),
      buildWhen: (previous, current) {
        return previous.initialCameraPosition !=
                current.initialCameraPosition ||
            previous.isTracking != current.isTracking ||
            previous.markers != current.markers ||
            previous.routePositions != current.routePositions;
      },
      builder: (context, state) {
        return GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(
            target: state.initialCameraPosition!,
            zoom: MapConstants.defaultZoom,
          ),
          myLocationEnabled: state.isTracking,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: true,
          buildingsEnabled: true,
          markers: state.markers,
          polylines: <Polyline>{
            if (state.routePositions.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('route'),
                color: Theme.of(context).primaryColor,
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
    );
  }

  void _handleCameraPositionUpdates(MapsState state) {
    if (state.isCameraLocked && state.isTracking) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(state.currentLocation!.position),
      );
    }
  }
}
