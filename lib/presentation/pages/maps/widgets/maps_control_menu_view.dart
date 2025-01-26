import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracker_app/presentation/bloc/maps_bloc/maps_bloc.dart';

class MapsControlMenuView extends StatelessWidget {
  const MapsControlMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.viewPaddingOf(context).bottom + 8,
      child: Card(
        child: BlocBuilder<MapsBloc, MapsState>(
          buildWhen: (previous, current) {
            return previous.isTracking != current.isTracking ||
                previous.isCameraLocked != current.isCameraLocked;
          },
          builder: (context, state) {
            return Row(
              children: [
                _MenuButton(
                  icon: Icon(
                    state.isTracking ? Icons.location_off : Icons.location_on,
                    color: state.isTracking
                        ? Colors.red
                        : Theme.of(context).primaryColor,
                  ),
                  label: state.isTracking ? 'Stop Tracking' : 'Start Tracking',
                  onPressed: () {
                    final event = state.isTracking
                        ? MapsLocationTrackingStopped()
                        : MapsLocationTrackingStarted();
                    context.read<MapsBloc>().add(event);
                  },
                ),
                _MenuButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'Reset Route',
                  onPressed: () {
                    context.read<MapsBloc>().add(MapsRouteReset());
                  },
                ),
                _MenuButton(
                  icon: Icon(
                    state.isCameraLocked
                        ? Icons.location_disabled
                        : Icons.my_location,
                    color: state.isTracking
                        ? state.isCameraLocked
                            ? Colors.red
                            : Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                  label: state.isCameraLocked ? 'Unlock Camera' : 'Lock Camera',
                  onPressed: state.isTracking
                      ? () {
                          context.read<MapsBloc>().add(MapsCameraLockToggled());
                        }
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onPressed == null ? Colors.grey : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
