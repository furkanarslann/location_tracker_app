import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracker_app/env.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();

  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.3861, -122.0839);

  LatLng? currentPosition;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> initializeMap() async {
    await fetchLocationPermissionUpdates();
    final coordinates = await fetchPolylinePoints();
    await generatePolyLineFromPoints(coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: googlePlex,
                zoom: 13,
              ),
              circles: {
                Circle(
                  circleId: CircleId('currentLocation'),
                  center: currentPosition!,
                  radius: 1000,
                  fillColor: Colors.greenAccent.withOpacity(0.2),
                  strokeWidth: 10,
                ),
              },
              buildingsEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              markers: {
                Marker(
                  markerId: MarkerId('sourceLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: googlePlex,
                  onTap: () {
                    log('Google Plex Tapped');
                  },
                  infoWindow: InfoWindow(
                    title: 'Google Plex',
                    snippet: 'Google Plex',
                    onTap: () {
                      log('Google Plex Info Window Tapped');
                    },
                  ),
                ),
                Marker(
                  markerId: MarkerId('destinationLocation'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Google Plex',
                    snippet: 'Google Plex',
                    onTap: () {
                      log('Google Plex Info Window Tapped');
                    },
                  ),
                  position: mountainView,
                )
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> fetchLocationPermissionUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    permissionStatus = await locationController.hasPermission();

    if (permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited) {
      currentPosition = await Location.instance.getLocation().then(
        (locationData) {
          log('Location Data: $locationData');
          return LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        },
      );
    } else {
      permissionStatus = await locationController.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return;

      currentPosition = await Location.instance.getLocation().then(
        (locationData) {
          log('Location Data: $locationData');
          return LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        },
      );
    }

    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(googlePlex.latitude, googlePlex.longitude),
        destination: PointLatLng(mountainView.latitude, mountainView.longitude),
        // TODO(Furkan): Maybe updated
        mode: TravelMode.driving,
      ),
      googleApiKey: googleMapsApiKey,
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
    List<LatLng> polylineCoordinates,
  ) async {
    const id = PolylineId('polylineId_10');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }
}
