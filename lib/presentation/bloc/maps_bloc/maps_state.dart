part of 'maps_bloc.dart';

class MapsState extends Equatable {
  final Set<Marker> markers;
  final List<LatLng> routePositions;
  final bool isTracking;
  final bool isCameraLocked;
  final LatLng? currentLocation;
  final LatLng? initialCameraPosition;
  final CustomFailure? failure;

  const MapsState({
    required this.markers,
    required this.routePositions,
    required this.isTracking,
    required this.isCameraLocked,
    this.initialCameraPosition,
    this.currentLocation,
    this.failure,
  });

  factory MapsState.initial() {
    return MapsState(
      initialCameraPosition: null,
      markers: {},
      routePositions: [],
      currentLocation: null,
      failure: null,
      isTracking: false,
      isCameraLocked: false,
    );
  }

  bool get hasFailed => failure != null;
  bool get hasRoutePositions => routePositions.isNotEmpty;
  bool get hasMarkers => markers.isNotEmpty;

  Set<Marker> get footprintMarkers {
    return markers.where(
      (marker) {
        return marker.markerId.value.startsWith(
          MapsMarkerData.footprintMarkerId,
        );
      },
    ).toSet();
  }

  MapsState copyWith({
    LatLng? initialCameraPosition,
    Set<Marker>? markers,
    List<LatLng>? routePositions,
    LatLng? currentLocation,
    CustomFailure? failure,
    bool? isTracking,
    bool? isCameraLocked,
  }) {
    return MapsState(
      initialCameraPosition:
          initialCameraPosition ?? this.initialCameraPosition,
      markers: markers ?? this.markers,
      routePositions: routePositions ?? this.routePositions,
      currentLocation: currentLocation ?? this.currentLocation,
      failure: failure,
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
        failure,
        isTracking,
        isCameraLocked,
      ];
}
