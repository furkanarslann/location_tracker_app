import 'package:flutter/material.dart';
import 'package:location_tracker_app/core/failures/failures.dart';

typedef FailureMessage = (String title, String message);

mixin FailureMessageHandlerMixin {
  FailureMessage getFailureMessage(
    BuildContext context,
    CustomFailure failure,
  ) {
    if (failure is RouteServiceNoRoutesFailure) {
      return (
        'No Route Available',
        'Could not find a route to the selected destination.',
      );
    }

    if (failure is UnknownFailure) {
      return (
        'An Error Occurred',
        failure.errorMessage,
      );
    }

    return (
      'Unknown Error',
      'An unexpected error occurred.',
    );
  }
}
