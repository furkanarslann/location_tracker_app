import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPointData extends Equatable {
  final LatLng position;
  final String? address;
  final DateTime timestamp;

  const LocationPointData({
    required this.position,
    this.address,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [position, address, timestamp];
}
