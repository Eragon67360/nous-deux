import 'package:equatable/equatable.dart';

/// Base class for application failures.
abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}

/// Why joining a couple by code failed, so the UI can say it in the
/// person's language.
enum PairingProblem { invalidCode, codeUsed, ownCode }

class PairingFailure extends Failure {
  const PairingFailure(this.problem) : super(null);

  final PairingProblem problem;

  @override
  List<Object?> get props => [problem];
}

/// Why a little note could not be sent.
enum PingProblem { cooldown, notPaired }

class PingFailure extends Failure {
  const PingFailure(this.problem) : super(null);

  final PingProblem problem;

  @override
  List<Object?> get props => [problem];
}
