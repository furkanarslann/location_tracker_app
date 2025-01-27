part of 'maps_bloc.dart';

abstract class MapsEvent extends Equatable {
  const MapsEvent();

  @override
  List<Object?> get props => [];
}

class MapsInitialized extends MapsEvent {}

class MapsLocationTrackingStarted extends MapsEvent {}

class MapsLocationTrackingStopped extends MapsEvent {}

class MapsRouteReset extends MapsEvent {}

class MapsRouteAdded extends MapsEvent {
  final LatLng destination;

  const MapsRouteAdded(this.destination);

  @override
  List<Object?> get props => [destination];
}

class _MapsLocationReceived extends MapsEvent {
  final LatLng location;
  const _MapsLocationReceived(this.location);

  @override
  List<Object> get props => [location];
}

class MapsCameraLockToggled extends MapsEvent {
  @override
  List<Object?> get props => [];
}
