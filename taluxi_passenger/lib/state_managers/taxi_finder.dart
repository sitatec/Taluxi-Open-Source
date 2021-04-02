import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi/state_managers/utils.dart';

class TaxiFinder {
  RealTimeLocation _realTimeLocation;
  final _stateStreamController = StreamController<TaxiFinderState>();
  List<Map<String, Coordinates>> _lastLocationsFound;
  // TODO Handle the user retry to find other taxis and only the previous taxis are refound.
  Stream<TaxiFinderState> get taxiFinderState => _stateStreamController.stream;

  TaxiFinder({RealTimeLocation realTimeLocation})
      : _realTimeLocation = realTimeLocation;

  Future<void> initialize({@required String currentUserId}) async {
    await _realTimeLocation.initialize(
        currentUserId: currentUserId, isDriverApp: false);
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  Future<void> findNearest() async {
    _stateStreamController.add(SearchInProgress());
    final closestDriversLocations =
        await _realTimeLocation.getClosestDriversLocations();
    if (closestDriversLocations.isEmpty) {
      _stateStreamController.add(TaxiNotFound());
      return _lastLocationsFound?.clear();
    }
    final locationsSortedByDistance =
        sortLocationsByDistance(closestDriversLocations);
    _stateStreamController.add(TaxiFound(locationsSortedByDistance));
    _lastLocationsFound = locationsSortedByDistance;
  }

  // Future<void> retryWithLargeScope({double searchScopeInKm = 3.5}) async {
  //   final closestDriversLocations =
  //       await _realTimeLocation.getClosestDriversLocations(
  //     locationCount: _lastLocationsFound.length * 2,
  //     maxDistanceInKm: searchScopeInKm,
  //   );
  //   if (closestDriversLocations.isEmpty) {
  //     _stateStreamController.add(TaxiNotFound());
  //     return _lastLocationsFound?.clear();
  //   }
  //   final locationsSortedByDistance =
  //       SplayTreeMap.from(closestDriversLocations, _compareKeys);
  //   _stateStreamController.add(TaxiFound(locationsSortedByDistance));
  //   _lastLocationsFound = locationsSortedByDistance;
  // }

}

abstract class TaxiFinderState {}

class SearchInProgress implements TaxiFinderState {}

class TaxiNotFound implements TaxiFinderState {}

class TaxiFound implements TaxiFinderState {
  final List<Map<String, Coordinates>> taxiDriversFound;
  const TaxiFound(this.taxiDriversFound);
}
