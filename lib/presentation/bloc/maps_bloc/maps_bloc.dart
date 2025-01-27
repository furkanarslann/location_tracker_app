import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location_tracker_app/core/constants/map_constants.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/domain/entities/location_point_data.dart';
import 'package:location_tracker_app/domain/entities/maps_marker_data.dart';
import 'package:location_tracker_app/domain/entities/route_data.dart';
import 'package:location_tracker_app/domain/repositories/maps_repository.dart';

part 'maps_event.dart';
part 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  MapsBloc(this._mapsRepository) : super(MapsState.initial()) {
    on<MapsInitialized>(_onInitialized);
    on<MapsLocationTrackingStarted>(_onLocationTrackingStarted);
    on<MapsLocationTrackingStopped>(_onLocationTrackingStopped);
    on<MapsRouteReset>(_onRouteReset);
    on<MapsRouteAdded>(_onRouteAdded);
    on<_MapsLocationReceived>(_onLocationReceived);
    on<MapsCameraLockToggled>(_onCameraLockToggled);
  }

  final MapsRepository _mapsRepository;

  StreamSubscription<LocationPointData>? _locationSubscription;
  late LatLng _lastFootprintPosition;

  Future<void> _onInitialized(
    MapsInitialized event,
    Emitter<MapsState> emit,
  ) async {
    try {
      final currentLocation = await _mapsRepository.getLocation();
      _lastFootprintPosition = currentLocation.position;
      add(MapsLocationTrackingStarted());

      final savedRoute = await _mapsRepository.getSavedRouteData();
      if (savedRoute == null) {
        emit(state.copyWith(
          initialCameraPosition: currentLocation.position,
          currentLocation: currentLocation,
          isTracking: true,
        ));
        return;
      }

      final allMarkers = {
        ...state.footprintMarkers,
        MapsMarkerData.source(
          position: savedRoute.source,
          address: savedRoute.sourceAddress,
        ).toMarker(),
        MapsMarkerData.destination(
          position: savedRoute.destination,
          address: savedRoute.destinationAddress,
        ).toMarker(),
      };

      emit(
        state.copyWith(
          isTracking: true,
          initialCameraPosition: currentLocation.position,
          currentLocation: currentLocation,
          routePositions: savedRoute.positions,
          markers: allMarkers,
        ),
      );
    } catch (e) {
      throw UnknownFailure('Failed to initialize maps: $e');
    }
  }

  Future<void> _onLocationTrackingStarted(
    MapsLocationTrackingStarted event,
    Emitter<MapsState> emit,
  ) async {
    try {
      emit(state.copyWith(isTracking: true));
      await _locationSubscription?.cancel();
      _locationSubscription = _mapsRepository.getLocationUpdates().listen(
        (locationPoint) {
          add(_MapsLocationReceived(locationPoint));
        },
      );
    } catch (e) {
      throw UnknownFailure('Failed to start location tracking: $e');
    }
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
    try {
      await _mapsRepository.clearSavedRoute();
      final footprintMarkers = state.footprintMarkers;
      return emit(
        state.copyWith(routePositions: [], markers: footprintMarkers),
      );
    } catch (e) {
      throw UnknownFailure('Failed to reset route: $e');
    }
  }

  Future<void> _onRouteAdded(
    MapsRouteAdded event,
    Emitter<MapsState> emit,
  ) async {
    try {
      assert(state.isTracking);

      final routePositions = await _mapsRepository.getRouteBetweenPositions(
        source: state.currentLocation!.position,
        destination: event.destination,
      );
      final sourceAddress = await _mapsRepository.getAddressFromPosition(
        state.currentLocation!.position,
      );
      final destinationAddress = await _mapsRepository.getAddressFromPosition(
        event.destination,
      );

      final allMarkers = {
        ...state.footprintMarkers,
        MapsMarkerData.source(
          position: state.currentLocation!.position,
          address: sourceAddress,
        ).toMarker(),
        MapsMarkerData.destination(
          position: event.destination,
          address: destinationAddress,
        ).toMarker(),
      };

      await _saveRouteToStorage(
        routePositions,
        sourceAddress,
        destinationAddress,
      );

      emit(state.copyWith(routePositions: routePositions, markers: allMarkers));
    } catch (e) {
      emit(state.copyWith(failure: null));
      CustomFailure failure;
      if (e is RouteServiceNoRoutesFailure) {
        failure = RouteServiceNoRoutesFailure();
      } else {
        failure = UnknownFailure(e.toString());
      }
      emit(state.copyWith(failure: failure));
    }
  }

  Future<void> _saveRouteToStorage(
    List<LatLng> routePositions,
    String? sourceAddress,
    String? destinationAddress,
  ) async {
    try {
      final routeData = RouteData(
        positions: routePositions,
        sourceAddress: sourceAddress,
        destinationAddress: destinationAddress,
      );
      await _mapsRepository.saveRouteData(routeData);
    } catch (e) {
      throw UnknownFailure('Failed to save route data: $e');
    }
  }

  Future<void> _onLocationReceived(
    _MapsLocationReceived event,
    Emitter<MapsState> emit,
  ) async {
    final currentPosition = event.location.position;
    final newMarkers = Set<Marker>.from(state.markers);

    final distance = await _mapsRepository.calculateDistance(
      _lastFootprintPosition,
      currentPosition,
    );

    if (distance >= MapConstants.minimumDistanceThreshold) {
      final address = await _mapsRepository.getAddressFromPosition(
        currentPosition,
      );
      final footprintMarker = MapsMarkerData.footprint(
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
  }

  Future<void> _onCameraLockToggled(
    MapsCameraLockToggled event,
    Emitter<MapsState> emit,
  ) async {
    emit(state.copyWith(isCameraLocked: !state.isCameraLocked));
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    return super.close();
  }
}
