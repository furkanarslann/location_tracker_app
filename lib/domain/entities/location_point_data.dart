import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPointData extends Equatable {
  final LatLng position;
  final DateTime timestamp;

  const LocationPointData({
    required this.position,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [position, timestamp];
}
