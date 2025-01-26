import 'package:equatable/equatable.dart';

abstract class CustomFailure extends Equatable {
  const CustomFailure();

  @override
  List<Object> get props => [];
}

class LocationPermissionDeniedFailure extends CustomFailure {
  const LocationPermissionDeniedFailure();
}

class LocationServiceFailure extends CustomFailure {
  const LocationServiceFailure(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}

class LocationServiceTimeoutFailure extends LocationServiceFailure {
  const LocationServiceTimeoutFailure() : super('Location service timed out');
}

class UnknownFailure extends CustomFailure {
  final String message;
  const UnknownFailure(this.message);

  @override
  List<Object> get props => [message];
}
