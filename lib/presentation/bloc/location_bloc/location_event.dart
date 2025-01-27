import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeLocation extends LocationEvent {}

class RequestLocationPermission extends LocationEvent {}

class OpenLocationSettings extends LocationEvent {}

class OpenAppSettings extends LocationEvent {}
