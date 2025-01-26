part of 'maps_bloc.dart';

class MapsState extends Equatable {
  final LatLng? initialPosition;
  final Set<Marker> markers;
  final List<LatLng> routePositions;
  final LocationPointData? currentLocation;
  final CustomFailure? error;

  const MapsState({
    required this.markers,
    required this.routePositions,
    this.initialPosition,
    this.currentLocation,
    this.error,
  });

  factory MapsState.initial() {
    return MapsState(
      initialPosition: null,
      markers: {},
      routePositions: [],
      currentLocation: null,
      error: null,
    );
  }

  bool get hasError => error != null;
  bool get hasRoutePositions => routePositions.isNotEmpty;
  bool get hasMarkers => markers.isNotEmpty;
  bool get isTracking => currentLocation != null;

  bool get permissionGrantedButNoLocation {
    return error is LocationServiceTimeoutFailure;
  }

  MapsState copyWith({
    LatLng? initialPosition,
    Set<Marker>? markers,
    List<LatLng>? routePositions,
    LocationPointData? currentLocation,
    CustomFailure? error,
  }) {
    return MapsState(
      initialPosition: initialPosition ?? this.initialPosition,
      markers: markers ?? this.markers,
      routePositions: routePositions ?? this.routePositions,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        initialPosition,
        markers,
        routePositions,
        currentLocation,
        error,
      ];
}
