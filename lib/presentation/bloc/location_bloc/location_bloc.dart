import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/core/services/geolocator_service.dart';
import 'package:location_tracker_app/domain/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;

  LocationBloc(this._locationRepository) : super(LocationState.initial()) {
    on<InitializeLocation>(_onInitializeLocation);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<OpenLocationSettings>(_onOpenLocationSettings);
    on<OpenAppSettings>(_onOpenAppSettings);
  }

  Future<void> _onInitializeLocation(
    InitializeLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final isEnabled = await _locationRepository.isLocationServiceEnabled();

      final initialPermission =
          await _locationRepository.checkLocationPermissionStatus();

      final permission = initialPermission == LocationPermission.denied
          ? await _locationRepository.requestLocationPermission()
          : initialPermission;

      emit(state.copyWith(
        isLocationServiceEnabled: isEnabled,
        permissionStatus: permission,
      ));
    } catch (e) {
      emit(state.copyWith(failure: UnknownFailure(e.toString())));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final permission = await _locationRepository.requestLocationPermission();
      emit(state.copyWith(permissionStatus: permission));
    } catch (e) {
      emit(state.copyWith(failure: UnknownFailure(e.toString())));
    }
  }

  Future<void> _onOpenLocationSettings(
    OpenLocationSettings event,
    Emitter<LocationState> emit,
  ) async {
    try {
      await _locationRepository.openLocationSettings();

      final isEnabled = await _locationRepository.isLocationServiceEnabled();
      emit(state.copyWith(isLocationServiceEnabled: isEnabled));
    } catch (e) {
      emit(state.copyWith(failure: UnknownFailure(e.toString())));
    }
  }

  Future<void> _onOpenAppSettings(
    OpenAppSettings event,
    Emitter<LocationState> emit,
  ) async {
    try {
      await _locationRepository.openAppSettings();
      final permission =
          await _locationRepository.checkLocationPermissionStatus();
      emit(state.copyWith(permissionStatus: permission));
    } catch (e) {
      emit(state.copyWith(failure: UnknownFailure(e.toString())));
    }
  }
}
