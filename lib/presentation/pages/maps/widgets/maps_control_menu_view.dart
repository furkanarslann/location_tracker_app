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
      bottom: MediaQuery.viewPaddingOf(context).bottom + 16,
      child: Card(
        elevation: 4,
        child: BlocBuilder<MapsBloc, MapsState>(
          builder: (context, state) {
            return Row(
              children: [
                _MenuButton(
                  icon: Icon(
                    state.isTracking ? Icons.stop : Icons.play_arrow,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: state.isTracking ? 'Stop Tracking' : 'Start Tracking',
                  onPressed: () {
                    final event = state.isTracking
                        ? MapsLocationTrackingStopped()
                        : MapsLocationTrackingStarted();
                    context.read<MapsBloc>().add(event);
                  },
                ),
                const _VerticalDivider(),
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
                VerticalDivider(
                  width: 5,
                  thickness: 5,
                  color: Colors.red.withValues(alpha: 0.5),
                ),
                _MenuButton(
                  icon: Icon(
                    state.isCameraLocked
                        ? Icons.location_disabled
                        : Icons.my_location,
                    color: state.isTracking
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  label: 'Camera Lock',
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

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: Colors.grey.withValues(alpha: 0.5),
    );
  }
}
