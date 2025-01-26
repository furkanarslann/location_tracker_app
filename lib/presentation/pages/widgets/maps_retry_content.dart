import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc.dart';

class MapsRetryContent extends StatelessWidget {
  const MapsRetryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your location could not be determined in time! Please retry.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MapsBloc>().add(MapsInitialized());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
