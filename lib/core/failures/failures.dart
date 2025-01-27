import 'package:equatable/equatable.dart';

abstract class CustomFailure extends Equatable {
  const CustomFailure();

  @override
  List<Object> get props => [];
}

class RouteServiceNoRoutesFailure extends CustomFailure {
  const RouteServiceNoRoutesFailure();
}

class UnknownFailure extends CustomFailure {
  final String errorMessage;

  const UnknownFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
