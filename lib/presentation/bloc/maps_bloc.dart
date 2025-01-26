import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker_app/core/constants/map_constants.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/domain/entities/location_point_data.dart';
import 'package:location_tracker_app/domain/entities/route_data.dart';
import 'package:location_tracker_app/domain/entities/map_marker_data.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';

part 'maps_state.dart';
part 'maps_event.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  MapsBloc({required this.repository}) : super(MapsState.initial()) {
    on<MapsInitialized>(_onInitialized);
    on<MapsLocationTrackingStarted>(_onLocationTrackingStarted);
    on<MapsLocationTrackingStopped>(_onLocationTrackingStopped);
    on<MapsRouteReset>(_onRouteReset);
    on<MapsRouteAdded>(_onRouteAdded);
    on<_MapsLocationReceived>(_onLocationReceived);
  }

  final LocationRepository repository;

  StreamSubscription<LocationPointData>? _locationSubscription;
  late LatLng _lastFootprintPosition;

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
      _lastFootprintPosition = currentLocation.position;
      add(MapsLocationTrackingStarted());

      final savedRoute = await repository.getSavedRouteData();
      if (savedRoute == null) {
        emit(state.copyWith(
          cameraPosition: currentLocation.position,
          currentLocation: currentLocation,
          isTracking: true,
        ));
        return;
      }

      emit(
        state.copyWith(
          isTracking: true,
          cameraPosition: currentLocation.position,
          currentLocation: currentLocation,
          routePositions: savedRoute.positions,
          markers: {
            MapMarkerData.source(
              position: savedRoute.source,
              address: savedRoute.sourceAddress,
            ).toMarker(),
            MapMarkerData.destination(
              position: savedRoute.destination,
              address: savedRoute.destinationAddress,
            ).toMarker(),
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

      final sourceAddress = await repository.getAddressFromPosition(
        state.currentLocation!.position,
      );
      final destinationAddress = await repository.getAddressFromPosition(
        event.destination,
      );

      final markers = {
        MapMarkerData.source(
          position: state.currentLocation!.position,
          address: sourceAddress,
        ).toMarker(),
        MapMarkerData.destination(
          position: event.destination,
          address: destinationAddress,
        ).toMarker(),
      };

      final routeData = RouteData(
        positions: routePositions,
        sourceAddress: sourceAddress,
        destinationAddress: destinationAddress,
      );

      emit(state.copyWith(routePositions: routePositions, markers: markers));
      await repository.saveRouteData(routeData);
    } catch (e) {
      emit(state.copyWith(error: LocationServiceFailure(e.toString())));
    }
  }

  Future<void> _onLocationReceived(
    _MapsLocationReceived event,
    Emitter<MapsState> emit,
  ) async {
    try {
      final currentPosition = event.location.position;
      final newMarkers = Set<Marker>.from(state.markers);

      final distance = await repository.calculateDistance(
        _lastFootprintPosition,
        currentPosition,
      );

      if (distance >= MapConstants.minimumDistanceThreshold) {
        final address = await repository.getAddressFromPosition(
          currentPosition,
        );
        final footprintMarker = MapMarkerData.footprint(
          position: currentPosition,
          address: address,
        ).toMarker();

        newMarkers.add(footprintMarker);
        _lastFootprintPosition = currentPosition;
      }

      emit(state.copyWith(
        currentLocation: event.location,
        markers: newMarkers,
      ));
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
