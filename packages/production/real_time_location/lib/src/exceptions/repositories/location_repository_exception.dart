import '../base_exception.dart';

class LocationRepositoryException
    extends BaseException<LocationRepositoryExceptionType> {
  LocationRepositoryException.notFound()
      : super(
          exceptionType: LocationRepositoryExceptionType.notFound,
          message: "Location not found",
        );
  LocationRepositoryException.serverError()
      : super(
          exceptionType: LocationRepositoryExceptionType.serverError,
          message: "Server internal error",
        );

  LocationRepositoryException.unknown()
      : super(
          exceptionType: LocationRepositoryExceptionType.unknown,
          message: "Unknown exception reason",
        );

  LocationRepositoryException.requestTimeout()
      : super(
          exceptionType: LocationRepositoryExceptionType.requestTimeout,
          message: "Request timeout",
        );

  // LocationRepositoryException.failedToPutLocation()
  //     : super(
  //         exceptionType: LocationRepositoryExceptionType.failedToPutLocation,
  //         message:
  //             "Failed to put location (unknown reason, probably server error)",
  //       );
}

enum LocationRepositoryExceptionType {
  notFound,
  serverError,
  unknown,
  requestTimeout,
  // failedToPutLocation,
}
