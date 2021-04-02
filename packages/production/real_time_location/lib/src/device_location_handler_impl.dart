import 'package:location/location.dart';
import '../real_time_location.dart';

import 'exceptions/device_location_handler_exception.dart';

/// The Device location manager.
///
/// This class provides some methods which will help you to use the device location.
class DeviceLocationHandlerImp implements DeviceLocationHandler {
  Location _location;
  bool _locationServiceInitialized = false;

  static final _singleton = DeviceLocationHandlerImp._internal();

  factory DeviceLocationHandlerImp() => _singleton;

  DeviceLocationHandlerImp._internal() : _location = Location();

  DeviceLocationHandlerImp.forTest({Location location}) : _location = location;

  // TODO: check if the device os version is android 11+ to decide weither to
  // todo: explan to the user how to always allow location permission or not.

  Future<void> initialize({bool requireBackground = false}) async {
    await _location.enableBackgroundMode(enable: requireBackground);
    await _requireLocationPermission();
    if (!(await _location.serviceEnabled()) &&
        !(await _location.requestService())) {
      throw DeviceLocationHandlerException.locationServiceDisabled();
    }
    _locationServiceInitialized = true;
  }

  Future<void> _requireLocationPermission() async {
    final locationPermissionStatus = await _location.hasPermission();
    if (locationPermissionStatus != PermissionStatus.granted) {
      if (locationPermissionStatus == PermissionStatus.deniedForever) {
        throw DeviceLocationHandlerException.permissionPermanentlyDenied();
      }
      await _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    switch (await _location.requestPermission()) {
      case PermissionStatus.denied:
        throw DeviceLocationHandlerException.permissionDenied();
      case PermissionStatus.deniedForever:
        throw DeviceLocationHandlerException.permissionPermanentlyDenied();
      default:
    }
  }

  @override
  Future<Coordinates> getCurrentCoordinates() async {
    if (!_locationServiceInitialized)
      throw DeviceLocationHandlerException.locationServiceUninitialized();
    final locationData = await _location.getLocation();
    return Coordinates(
        latitude: locationData.latitude, longitude: locationData.longitude);
  }

  @override
  Stream<Coordinates> getCoordinatesStream(
      {double distanceFilterInMeter = 100}) {
    if (!_locationServiceInitialized)
      throw DeviceLocationHandlerException.locationServiceUninitialized();
    _location.changeSettings(distanceFilter: distanceFilterInMeter);
    return _location.onLocationChanged.map<Coordinates>(
      (locationData) => Coordinates(
          latitude: locationData.latitude, longitude: locationData.longitude),
    );
  }

  @override
  Future<bool> setDistanceFilter(double distanceFilterInMeter) =>
      _location.changeSettings(distanceFilter: distanceFilterInMeter);
}
