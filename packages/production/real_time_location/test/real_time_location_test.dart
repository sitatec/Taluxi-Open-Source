import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:real_time_location/src/real_time_location_impl.dart';
import 'package:real_time_location/src/repositories/location_repository.dart';
import 'package:real_time_location/src/repositories/location_streamer.dart';
import 'package:real_time_location/src/utils/reverse_geocoder.dart';

class MockLocationStreamer extends Mock implements LocationStreamer {}

class MockDeviceLocationHandler extends Mock implements DeviceLocationHandler {}

class MockReverseGeocoder extends Mock implements ReverseGeocoder {}

class MockLocationRepository extends Mock implements LocationRepository {
  MockLocationRepository();
}

// TODO integration testing.
void main() {
  RealTimeLocation realTimeLocation;
  LocationStreamer locationStreamer;
  DeviceLocationHandler deviceLocationHandler;
  LocationRepository locationRepository;
  final reverseGeocoder = MockReverseGeocoder();
  const fakeUserId = 'id';
  const fakeCity = 'ccity';
  final fakeUserLocation =
      Coordinates(latitude: 14.356464, longitude: -12.376404);

  setUp(() async {
    locationRepository = MockLocationRepository();
    locationStreamer = MockLocationStreamer();
    deviceLocationHandler = MockDeviceLocationHandler();
    realTimeLocation = RealTimeLocationImpl.forTest(
        locationRepository: locationRepository,
        locationStreamer: locationStreamer,
        deviceLocationHandler: deviceLocationHandler);
    when(reverseGeocoder.getCityFromCoordinates(fakeUserLocation))
        .thenAnswer((_) => Future.value(fakeCity));
    when(deviceLocationHandler.getCurrentCoordinates())
        .thenAnswer((_) => Future.value(fakeUserLocation));
  });

  test('Should initialize RealTimeLocation', () async {
    expect(realTimeLocation.initialized, isFalse);
    await realTimeLocation.initialize(
        reverseGeocoder: reverseGeocoder, currentUserId: fakeUserId);
    expect(realTimeLocation.initialized, isTrue);
    verifyInOrder([
      deviceLocationHandler.initialize(requireBackground: true),
      deviceLocationHandler.getCurrentCoordinates(),
      reverseGeocoder.getCityFromCoordinates(fakeUserLocation)
    ]);
  });

  group(' ', () {
    setUp(
      () async => await realTimeLocation.initialize(
        reverseGeocoder: reverseGeocoder,
        currentUserId: fakeUserId,
      ),
    );

    test('Should tack the location of the user which id given as parameter',
        () async {
      when(locationStreamer.getLocationStream(
              city: fakeCity, userUid: fakeUserId))
          .thenAnswer((_) => Stream.value(fakeUserLocation.toMap()));
      expect(
        await realTimeLocation.startLocationTracking(fakeUserId).first,
        equals(fakeUserLocation),
      );
    });

    test('Should share current user location and update location stream',
        () async {
      when(deviceLocationHandler.getCoordinatesStream(
              distanceFilterInMeter: 100))
          .thenAnswer((_) => Stream.value(fakeUserLocation));
      await realTimeLocation.enableRideMode();
      realTimeLocation.startSharingLocation(distanceFilterInMeter: 100);
      await Future.delayed(Duration.zero);
      verifyInOrder([
        deviceLocationHandler.getCoordinatesStream(distanceFilterInMeter: 100),
        locationStreamer.updateLocation(
          city: fakeCity,
          userUid: fakeUserId,
          gpsCoordinates: fakeUserLocation.toMap(),
        )
      ]);
    });

    test(
        'Should share current user location and put location to location repository',
        () async {
      when(deviceLocationHandler.getCoordinatesStream(
              distanceFilterInMeter: 100))
          .thenAnswer((_) => Stream.value(fakeUserLocation));
      realTimeLocation.startSharingLocation(distanceFilterInMeter: 100);
      await Future.delayed(Duration.zero);
      verifyInOrder([
        deviceLocationHandler.getCoordinatesStream(distanceFilterInMeter: 100),
        locationRepository.putLocation(
            city: fakeCity, userId: fakeUserId, coordinates: fakeUserLocation)
      ]);
    });

    test('Should enable ride mode', () async {
      await realTimeLocation.enableRideMode(newDistanceFilter: 100);
      expect(realTimeLocation.isRideMode, isTrue);
      verifyInOrder([
        locationRepository.deleteLocation(city: fakeCity, userId: fakeUserId),
        deviceLocationHandler.setDistanceFilter(100)
      ]);
    });

    test('Should disable ride mode', () async {
      await realTimeLocation.enableRideMode(newDistanceFilter: 100);
      expect(realTimeLocation.isRideMode, isTrue);
      realTimeLocation.disableRideMode();
      expect(realTimeLocation.isRideMode, isFalse);
      verify(deviceLocationHandler.setDistanceFilter(100));
    });

    test('Should get the closest drivers location', () async {
      await realTimeLocation.getClosestDriversLocations(
          locationCount: 5, maxDistanceInKm: 3);
      verifyInOrder([
        deviceLocationHandler.getCurrentCoordinates(),
        locationRepository.getClosestLocation(
          city: fakeCity,
          coordinates: fakeUserLocation,
          maxDistanceInKm: 3,
          locationCount: 5,
        )
      ]);
    });
  });
}
