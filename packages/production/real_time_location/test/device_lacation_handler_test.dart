import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:mockito/mockito.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:real_time_location/src/device_location_handler_impl.dart';
import 'package:real_time_location/src/exceptions/device_location_handler_exception.dart';

class MockLocation extends Mock implements Location {}

void main() {
  Location location;
  DeviceLocationHandler deviceLocationHandler;
  final fakeCoordinates =
      Coordinates(latitude: -13.045356, longitude: 12.546447);
  final fakeLocationData = LocationData.fromMap({
    'latitude': fakeCoordinates.latitude,
    'longitude': fakeCoordinates.longitude,
    'accuracy': 0.0,
    'altitude': 0.0,
    'speed': 0.0,
    'speed_accuracy': 0.0,
    'heading': 0.0,
    'time': 0.0,
  });
  setUp(() {
    location = MockLocation();
    deviceLocationHandler =
        DeviceLocationHandlerImp.forTest(location: location);
    //! To prevent a boolean to be null if this method isn't mocked in the test function.
    when(location.serviceEnabled()).thenAnswer((_) => Future.value(true));
  });

  group('Initialization :', () {
    test('Should initialize location service successfully', () async {
      when(location.hasPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.denied));
      when(location.requestPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.granted));
      when(location.serviceEnabled()).thenAnswer((_) => Future.value(false));
      when(location.requestService()).thenAnswer((_) => Future.value(true));

      await deviceLocationHandler.initialize();
      verifyInOrder([
        location.hasPermission(),
        location.requestPermission(),
        location.serviceEnabled(),
        location.requestService(),
      ]);
    });

    test('Should not ask for permission if already granted', () async {
      when(location.hasPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.granted));
      when(location.serviceEnabled()).thenAnswer((_) => Future.value(false));
      when(location.requestService()).thenAnswer((_) => Future.value(true));

      await deviceLocationHandler.initialize();
      verifyInOrder([
        location.hasPermission(),
        location.serviceEnabled(),
        location.requestService(),
      ]);
      verifyNever(location.requestPermission());
    });

    test('Should not request service enabling if already enabled', () async {
      when(location.hasPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.granted));
      when(location.serviceEnabled()).thenAnswer((_) => Future.value(true));

      await deviceLocationHandler.initialize();
      verifyInOrder([
        location.hasPermission(),
        location.serviceEnabled(),
      ]);
      verifyNever(location.requestPermission());
      verifyNever(location.requestService());
    });

    test('Should throw a [DeviceLocationHandlerException.permissionDenied()]',
        () async {
      when(location.hasPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.denied));
      when(location.requestPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.denied));

      expect(
        () async => await deviceLocationHandler.initialize(),
        throwsA(
          isA<DeviceLocationHandlerException>().having(
            (e) => e.exceptionType,
            'Exception type',
            DeviceLocationHandlerExceptionType.permissionDenied,
          ),
        ),
      );

      verifyNever(location.serviceEnabled());
      verifyNever(location.requestService());
    });

    test(
        'Should throw a [DeviceLocationHandlerException.permissionPermanentlyDenied()]',
        () async {
      when(location.hasPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.denied));
      when(location.requestPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.deniedForever));

      expect(
        () async => await deviceLocationHandler.initialize(),
        throwsA(
          isA<DeviceLocationHandlerException>().having(
            (e) => e.exceptionType,
            'Exception type',
            DeviceLocationHandlerExceptionType.permissionPermanentlyDenied,
          ),
        ),
      );

      verifyNever(location.serviceEnabled());
      verifyNever(location.requestService());
    });

    test('Should not ask for permission if it is already permanently denied ',
        () async {
      when(location.hasPermission())
          .thenAnswer((_) => Future.value(PermissionStatus.deniedForever));

      expect(
        () async => await deviceLocationHandler.initialize(),
        throwsA(
          isA<DeviceLocationHandlerException>().having(
            (e) => e.exceptionType,
            'Exception type',
            DeviceLocationHandlerExceptionType.permissionPermanentlyDenied,
          ),
        ),
      );
      verifyNever(location.requestPermission());
      verifyNever(location.serviceEnabled());
      verifyNever(location.requestService());
    });

    test('Should disable background mode', () async {
      await deviceLocationHandler.initialize();
      verify(location.enableBackgroundMode(enable: false));
    });

    test('Should enable background mode', () async {
      await deviceLocationHandler.initialize(requireBackground: true);
      verify(location.enableBackgroundMode(enable: true));
    });
  });

  test('Should get the current location of the device', () async {
    when(location.getLocation()).thenAnswer(
      (_) => Future.value(fakeLocationData),
    );
    await deviceLocationHandler.initialize();
    expect(
        await deviceLocationHandler.getCurrentCoordinates(), fakeCoordinates);
  });

  test(
      'Should throw a [DeviceLocationHandlerException.locationServiceUninitialized()] when trying to get the current coordinates without initializing the device location handler object.',
      () {
    expect(
      () async => await deviceLocationHandler.getCurrentCoordinates(),
      throwsA(
        isA<DeviceLocationHandlerException>().having(
          (e) => e.exceptionType,
          'Exception type',
          DeviceLocationHandlerExceptionType.locationServiceUninitialized,
        ),
      ),
    );
  });

  test('Should get location stream ', () async {
    await deviceLocationHandler.initialize();
    when(location.onLocationChanged)
        .thenAnswer((_) => Stream.value(fakeLocationData));
    expect(
      await deviceLocationHandler.getCoordinatesStream().first,
      equals(fakeCoordinates),
    );
  });

  test('Should set the given distance filter', () async {
    when(location.onLocationChanged)
        .thenAnswer((_) => Stream.value(fakeLocationData));
    await deviceLocationHandler.initialize();
    deviceLocationHandler.getCoordinatesStream(distanceFilterInMeter: 100);
    verify(location.changeSettings(distanceFilter: 100));
  });

  test(
      'Should throw a [DeviceLocationHandlerException.locationServiceUninitialized()] when trying to get the coordinates stream without initializing the device location handler object.',
      () {
    expect(
      () => deviceLocationHandler.getCoordinatesStream(),
      throwsA(
        isA<DeviceLocationHandlerException>().having(
          (e) => e.exceptionType,
          'Exception type',
          DeviceLocationHandlerExceptionType.locationServiceUninitialized,
        ),
      ),
    );
  });
}
