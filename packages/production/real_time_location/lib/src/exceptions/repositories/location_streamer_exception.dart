import 'package:flutter/cupertino.dart';
import '../base_exception.dart';

class LocationStreamerException
    extends BaseException<LocationStreamerExceptionType> {
  const LocationStreamerException(
      {@required String message,
      @required LocationStreamerExceptionType exceptionType})
      : super(exceptionType: exceptionType, message: message);

  const LocationStreamerException.dataAccessFailed()
      : super(
            exceptionType: LocationStreamerExceptionType.dataAccessFailed,
            message: 'Failed to retrieve location data from the database');
}

enum LocationStreamerExceptionType { dataAccessFailed }
