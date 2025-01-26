part of 'maps_bloc.dart';

class MapsState extends Equatable {
  final Set<Marker> markers;
  final List<LatLng> routePositions;
  final bool isTracking;
  final LocationPointData? currentLocation;
  final LatLng? cameraPosition;
  final CustomFailure? error;

  const MapsState({
    required this.markers,
    required this.routePositions,
    required this.isTracking,
    this.cameraPosition,
    this.currentLocation,
    this.error,
  });

  factory MapsState.initial() {
    return MapsState(
      cameraPosition: null,
      markers: {},
      routePositions: [],
      currentLocation: null,
      error: null,
      isTracking: false,
    );
  }

  bool get hasError => error != null;
  bool get hasRoutePositions => routePositions.isNotEmpty;
  bool get hasMarkers => markers.isNotEmpty;

  bool get permissionGrantedButNoLocation {
    return error is LocationServiceTimeoutFailure;
  }

  MapsState copyWith({
    LatLng? cameraPosition,
    Set<Marker>? markers,
    List<LatLng>? routePositions,
    LocationPointData? currentLocation,
    CustomFailure? error,
    bool? isTracking,
  }) {
    return MapsState(
      cameraPosition: cameraPosition ?? this.cameraPosition,
      markers: markers ?? this.markers,
      routePositions: routePositions ?? this.routePositions,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error ?? this.error,
      isTracking: isTracking ?? this.isTracking,
    );
  }

  @override
  List<Object?> get props => [
        cameraPosition,
        markers,
        routePositions,
        currentLocation,
        error,
        isTracking,
      ];
}
