import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc/maps_bloc.dart';
import 'package:location_tracker_app/presentation/pages/maps/widgets/maps_retry_view.dart';
import 'package:location_tracker_app/presentation/pages/maps/widgets/maps_control_menu_view.dart';
import 'package:location_tracker_app/presentation/pages/maps/widgets/google_maps_view.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapsBloc, MapsState>(
        listener: (context, state) => _handleErrors(context, state),
        buildWhen: (previous, current) {
          return previous.initialCameraPosition !=
                  current.initialCameraPosition ||
              previous.error != current.error;
        },
        builder: (context, state) {
          if (state.permissionGrantedButNoLocation) {
            return const MapsRetryView();
          }

          if (state.initialCameraPosition == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return Stack(
            children: [
              const GoogleMapsView(),
              const MapsControlMenuView(),
            ],
          );
        },
      ),
    );
  }

  void _handleErrors(BuildContext context, MapsState state) {
    if (state.hasError) {
      final error = state.error;
      if (error is LocationPermissionDeniedFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred!')),
        );
      }
    }
  }
}
