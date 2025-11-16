import 'package:equatable/equatable.dart';
import 'package:voice_transscript/models/failure_response_model.dart';

abstract class Failure extends Equatable {
  final FailureResponseModel? failure;

  Failure([this.failure]);

  @override
  List<Object?> get props => [failure];
}

class ServerFailure extends Failure {
  ServerFailure([FailureResponseModel? failure]) : super(failure);
}

class NetworkFailure extends Failure {
  FailureResponseModel? failure = FailureResponseModel(
    msg: "internet_failed_msg",
  );
  NetworkFailure([FailureResponseModel? failure]) : super(failure);
}

class CacheFailure extends Failure {
  CacheFailure([FailureResponseModel? failure]) : super(failure);
}

class ParsingFailure extends Failure {
  FailureResponseModel? failure = FailureResponseModel(
    msg: "parsing_error_msg",
  );
  ParsingFailure([FailureResponseModel? failure]) : super(failure);
}

class RequestFailure extends Failure {
  FailureResponseModel? failure = FailureResponseModel(
    msg: "request_failure_msg",
  );
  RequestFailure([FailureResponseModel? failure]) : super(failure);
}
