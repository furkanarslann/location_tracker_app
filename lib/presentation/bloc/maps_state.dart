part of 'maps_bloc.dart';

class MapsState extends Equatable {
  final Set<Marker> markers;
  final List<LatLng> routePositions;
  final bool isTracking;
  final bool isCameraLocked;
  final LocationPointData? currentLocation;
  final LatLng? initialCameraPosition;
  final CustomFailure? error;

  const MapsState({
    required this.markers,
    required this.routePositions,
    required this.isTracking,
    required this.isCameraLocked,
    this.initialCameraPosition,
    this.currentLocation,
    this.error,
  });

  factory MapsState.initial() {
    return MapsState(
      initialCameraPosition: null,
      markers: {},
      routePositions: [],
      currentLocation: null,
      error: null,
      isTracking: false,
      isCameraLocked: false,
    );
  }

  bool get hasError => error != null;
  bool get hasRoutePositions => routePositions.isNotEmpty;
  bool get hasMarkers => markers.isNotEmpty;

  bool get permissionGrantedButNoLocation {
    return error is LocationServiceTimeoutFailure;
  }

  MapsState copyWith({
    LatLng? initialCameraPosition,
    Set<Marker>? markers,
    List<LatLng>? routePositions,
    LocationPointData? currentLocation,
    CustomFailure? error,
    bool? isTracking,
    bool? isCameraLocked,
  }) {
    return MapsState(
      initialCameraPosition:
          initialCameraPosition ?? this.initialCameraPosition,
      markers: markers ?? this.markers,
      routePositions: routePositions ?? this.routePositions,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error ?? this.error,
      isTracking: isTracking ?? this.isTracking,
      isCameraLocked: isCameraLocked ?? this.isCameraLocked,
    );
  }

  @override
  List<Object?> get props => [
        initialCameraPosition,
        markers,
        routePositions,
        currentLocation,
        error,
        isTracking,
        isCameraLocked,
      ];
}
