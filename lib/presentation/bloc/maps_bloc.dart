import 'dart:async';
import 'dart:developer';
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
    on<MapsInitialized>(_onInitialize);
    on<MapsLocationTrackingStarted>(_onStartTracking);
    on<MapsLocationTrackingStopped>(_onStopTracking);
    on<MapsRouteReset>(_onResetRoute);
    on<_MapsLocationReceived>(_onUpdateLocation);
  }

  Future<void> _onInitialize(
    MapsInitialized event,
    Emitter<MapsState> emit,
  ) async {
    try {
      final hasPermission = await repository.checkLocationPermission();
      if (!hasPermission) {
        emit(state.copyWith(
          initialPosition: MapConstants.defaultLocation,
          error: LocationPermissionDeniedFailure(),
        ));
        return;
      }

      final currentLocation = await repository.getLocation();
      final currPosition = currentLocation.position;

      add(MapsLocationTrackingStarted());

      // final routeData = await repository.getSavedRoutePositions();
      final routePositions = await repository.getRouteBetweenPositions(
        source: currPosition,
        destination: LatLng(37.73268128060671, -122.41299357265234),
      );

      final startPosition = routePositions.first;
      final destinationPosition = routePositions.last;

      emit(
        state.copyWith(
          initialPosition: currentLocation.position,
          currentLocation: currentLocation,
          routePositions: routePositions,
          markers: routePositions.isNotEmpty
              ? {
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
                }
              : {},
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

  Future<void> _onStartTracking(
    MapsLocationTrackingStarted event,
    Emitter<MapsState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = repository.getLocationUpdates().listen(
      (locationPoint) {
        add(_MapsLocationReceived(locationPoint));
      },
    );
  }

  Future<void> _onStopTracking(
    MapsLocationTrackingStopped event,
    Emitter<MapsState> emit,
  ) async {
    await _locationSubscription?.cancel();
    return emit(state.copyWith(currentLocation: null));
  }

  Future<void> _onResetRoute(
    MapsRouteReset event,
    Emitter<MapsState> emit,
  ) async {
    await repository.clearSavedRoute();
    return emit(state.copyWith(routePositions: [], markers: {}));
  }

  Future<void> _onUpdateLocation(
    _MapsLocationReceived event,
    Emitter<MapsState> emit,
  ) async {
    log('Location received: ${event.location}');
    return emit(state.copyWith(currentLocation: event.location));
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    return super.close();
  }
}
