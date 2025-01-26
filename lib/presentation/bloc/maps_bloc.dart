import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/constants/map_constants.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/domain/entities/location_point_data.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';

part 'maps_state.dart';
part 'maps_event.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final LocationRepository repository;
  StreamSubscription<LocationPointData>? _locationSubscription;

  MapsBloc({required this.repository}) : super(MapsState.initial()) {
    on<MapsInitialized>(_onInitialized);
    on<MapsLocationTrackingStarted>(_onLocationTrackingStarted);
    on<MapsLocationTrackingStopped>(_onLocationTrackingStopped);
    on<MapsRouteReset>(_onRouteReset);
    on<MapsRouteAdded>(_onRouteAdded);
  }

  Future<void> _onInitialized(
    MapsInitialized event,
    Emitter<MapsState> emit,
  ) async {
    try {
      final hasPermission = await repository.checkLocationPermission();
      if (!hasPermission) {
        emit(state.copyWith(
          cameraPosition: MapConstants.defaultLocation,
          error: LocationPermissionDeniedFailure(),
        ));
        return;
      }

      final currentLocation = await repository.getLocation();
      add(MapsLocationTrackingStarted());

      final routePositions = await repository.getSavedRoutePositions();

      if (routePositions.length < 2) {
        emit(state.copyWith(
          cameraPosition: currentLocation.position,
          currentLocation: currentLocation,
          isTracking: true,
        ));
        return;
      }

      final startPosition = routePositions.first;
      final destinationPosition = routePositions.last;

      emit(
        state.copyWith(
          isTracking: true,
          cameraPosition: currentLocation.position,
          currentLocation: currentLocation,
          routePositions: routePositions,
          markers: <Marker>{
            Marker(
              markerId: MarkerId(startPosition.toString()),
              position: startPosition,
              infoWindow: InfoWindow(title: 'Starting Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
            Marker(
              markerId: MarkerId(destinationPosition.toString()),
              position: destinationPosition,
              infoWindow: InfoWindow(title: 'Destination Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          },
        ),
      );
    } catch (e) {
      if (e is LocationServiceTimeoutFailure) {
        emit(state.copyWith(error: e));
        return;
      } else {
        emit(state.copyWith(error: UnknownFailure(e.toString())));
      }
    }
  }

  Future<void> _onLocationTrackingStarted(
    MapsLocationTrackingStarted event,
    Emitter<MapsState> emit,
  ) async {
    emit(state.copyWith(isTracking: true));
    await _locationSubscription?.cancel();
    _locationSubscription = repository.getLocationUpdates().listen(
      (locationPoint) {
        add(_MapsLocationReceived(locationPoint));
      },
    );
  }

  Future<void> _onLocationTrackingStopped(
    MapsLocationTrackingStopped event,
    Emitter<MapsState> emit,
  ) async {
    emit(state.copyWith(isTracking: false));
    await _locationSubscription?.cancel();
    return;
  }

  Future<void> _onRouteReset(
    MapsRouteReset event,
    Emitter<MapsState> emit,
  ) async {
    await repository.clearSavedRoute();
    return emit(state.copyWith(routePositions: [], markers: {}));
  }

  Future<void> _onRouteAdded(
    MapsRouteAdded event,
    Emitter<MapsState> emit,
  ) async {
    try {
      assert(state.isTracking);

      final routePositions = await repository.getRouteBetweenPositions(
        source: state.currentLocation!.position,
        destination: event.destination,
      );

      final markers = <Marker>{
        Marker(
          markerId: MarkerId('marker_source'),
          position: state.currentLocation!.position,
          infoWindow: InfoWindow(title: 'Source'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: MarkerId('marker_destination'),
          position: event.destination,
          infoWindow: InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        )
      };

      emit(state.copyWith(routePositions: routePositions, markers: markers));

      await repository.saveRoutePositions(routePositions);
    } catch (e) {
      emit(state.copyWith(error: LocationServiceFailure(e.toString())));
    }
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    return super.close();
  }
}
