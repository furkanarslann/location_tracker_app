import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteData extends Equatable {
  final List<LatLng> positions;
  final String? sourceAddress;
  final String? destinationAddress;

  const RouteData({
    required this.positions,
    this.sourceAddress,
    this.destinationAddress,
  }) : assert(positions.length >= 2);

  LatLng get source => positions.first;
  LatLng get destination => positions.last;

  Map<String, dynamic> toJson() {
    return {
      'positions': positions
          .map((pos) => {'latitude': pos.latitude, 'longitude': pos.longitude})
          .toList(),
      'sourceAddress': sourceAddress,
      'destinationAddress': destinationAddress,
    };
  }

  factory RouteData.fromJson(Map<String, dynamic> json) {
    final positions = (json['positions'] as List).map(
      (pos) {
        return LatLng(pos['latitude'] as double, pos['longitude'] as double);
      },
    ).toList();

    return RouteData(
      positions: positions,
      sourceAddress: json['sourceAddress'] as String?,
      destinationAddress: json['destinationAddress'] as String?,
    );
  }

  @override
  List<Object?> get props => [positions, sourceAddress, destinationAddress];
}
