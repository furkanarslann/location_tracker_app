import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_tracker_app/core/failures/failures.dart';

class LocationState extends Equatable {
  final bool isLocationServiceEnabled;
  final LocationPermission? permissionStatus;
  final CustomFailure? failure;

  const LocationState({
    required this.isLocationServiceEnabled,
    required this.permissionStatus,
    required this.failure,
  });

  factory LocationState.initial() {
    return const LocationState(
      isLocationServiceEnabled: false,
      permissionStatus: null,
      failure: null,
    );
  }

  LocationState copyWith({
    bool? isLocationServiceEnabled,
    LocationPermission? permissionStatus,
    CustomFailure? failure,
  }) {
    return LocationState(
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        isLocationServiceEnabled,
        permissionStatus,
        failure,
      ];
}
