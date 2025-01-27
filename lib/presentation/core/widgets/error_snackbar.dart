import 'package:flutter/material.dart';
import 'package:location_tracker_app/core/failures/failures.dart';
import 'package:location_tracker_app/presentation/core/mixin/failure_message_handler_mixin.dart';

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar(
    BuildContext context, {
    super.key,
    required CustomFailure failure,
  }) : super(
          content: _ErrorContent(failure: failure),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
        );
}

class _ErrorContent extends StatelessWidget with FailureMessageHandlerMixin {
  const _ErrorContent({required this.failure});
  final CustomFailure failure;
  @override
  Widget build(BuildContext context) {
    final (title, message) = getFailureMessage(context, failure);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(message),
      ],
    );
  }
}
