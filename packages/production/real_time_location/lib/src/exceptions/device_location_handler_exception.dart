import 'package:flutter/foundation.dart';
import 'base_exception.dart';

class DeviceLocationHandlerException
    extends BaseException<DeviceLocationHandlerExceptionType> {
  const DeviceLocationHandlerException(
      {@required String message,
      @required DeviceLocationHandlerExceptionType exceptionType})
      : super(
          exceptionType: exceptionType,
          message: message,
        );

  DeviceLocationHandlerException.permissionDenied()
      : super(
          message: 'Location access permission denied',
          exceptionType: DeviceLocationHandlerExceptionType.permissionDenied,
        );

  DeviceLocationHandlerException.permissionPermanentlyDenied()
      : super(
            message: 'Location access permission is permanently denied',
            exceptionType:
                DeviceLocationHandlerExceptionType.permissionPermanentlyDenied);

  DeviceLocationHandlerException.insufficientPermission()
      : super(
          message:
              'The granted permission is insufficient for the requested service.',
          exceptionType:
              DeviceLocationHandlerExceptionType.insufficientPermission,
        );

  DeviceLocationHandlerException.locationServiceDisabled()
      : super(
          message: 'The location service is desabled',
          exceptionType:
              DeviceLocationHandlerExceptionType.locationServiceDisabled,
        );

  DeviceLocationHandlerException.locationServiceUninitialized()
      : super(
          message:
              'The location service is not initialized you must initialize it before using it.',
          exceptionType:
              DeviceLocationHandlerExceptionType.locationServiceUninitialized,
        );
}

enum DeviceLocationHandlerExceptionType {
  permissionDenied,
  permissionPermanentlyDenied,
  insufficientPermission,
  locationServiceDisabled,
  locationServiceUninitialized
}
