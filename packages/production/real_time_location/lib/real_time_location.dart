library real_time_location;

import 'package:flutter/foundation.dart';

import 'src/device_location_handler_impl.dart';
import 'src/real_time_location_impl.dart';
import 'src/utils/reverse_geocoder.dart';

export 'src/exceptions/device_location_handler_exception.dart';
export 'src/exceptions/real_time_location_exception.dart';
export 'src/exceptions/utils/reverse_geocoder_exception.dart';
export 'src/utils/app_connection_state.dart';
export 'src/exceptions/repositories/location_repository_exception.dart';

//TODO handle error (convert all exception message to user friendly)
// TODO: Document all public apis.

abstract class RealTimeLocation {
  bool get initialized;

  Future<void> initialize({
    @required String currentUserId,
    bool isDriverApp = true,
    ReverseGeocoder reverseGeocoder,
  });

  static RealTimeLocation get instance => RealTimeLocationImpl();

  Future<void> enableRideMode({double newDistanceFilter = 50});
  void disableRideMode();
  bool get isRideMode;

  Stream<Coordinates> startLocationTracking(String idOfUserToTrack);

  void startSharingLocation({double distanceFilterInMeter = 1000});

  Future<void> stopLocationSharing();

  Future<Map<String, dynamic>> getClosestDriversLocations({
    double maxDistanceInKm = 2,
    int locationCount = 4,
  });
}

/// The Device location manager.
///
/// This class provides some methods which will help you to use the device location.
abstract class DeviceLocationHandler {
  // TODO: check if the device os version is android 11+ to decide weither to explan to the user how to always allow location permission or not.

  static DeviceLocationHandler get instance => DeviceLocationHandlerImp();

  /// Does all required processes required by the location service.
  ///
  /// Must be called first before using any other method otherwise a exception
  /// will be thrown.
  /// [requireBackground] if this parameter is `true` the background location
  /// service will be enabled else it will be disabled.
  Future<void> initialize({bool requireBackground = false});

  /// Returns the current user Location coordinates (latitude & longitude).
  Future<Coordinates> getCurrentCoordinates();

  /// Returns a stream of the current user Location coordinates (latitude &
  /// longitude), the returned stream add new coordinates each time the location
  /// of the user is updated.
  /// [distanceFilterInMeter] sets the minimum displacement between location
  /// updates in meters.
  Stream<Coordinates> getCoordinatesStream(
      {double distanceFilterInMeter = 100});

  /// sets [distanceFilterInMeter] as the minimum displacement between location
  /// updates in meters.
  Future<bool> setDistanceFilter(double distanceFilterInMeter);
}

class Coordinates {
  double latitude;
  double longitude;
  Coordinates({@required this.latitude, @required this.longitude});
  Coordinates.fromMap(Map<String, double> map) {
    latitude = map['latitude'];
    longitude = map['longitude'];
  }
  @override
  bool operator ==(Object other) {
    if (other is Coordinates)
      return other.latitude == latitude && other.longitude == longitude;
    else
      return false;
  }

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  Map<String, double> toMap() => {'latitude': latitude, 'longitude': longitude};
}
