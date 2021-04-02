// taxi found data converter
import 'dart:collection';

import 'package:real_time_location/real_time_location.dart';

List<Map<String, Coordinates>> sortLocationsByDistance(
  Map<String, dynamic> locations,
) {
  final sortedLocationsList = <Map<String, Coordinates>>[];
  final locationsSortedByDistance = SplayTreeMap<String, dynamic>.from(
    locations,
    _compareKeys,
  ).values.toList();
  locationsSortedByDistance.forEach((location) {
    sortedLocationsList
        .add({location.keys.first: _mapToCoordinates(location.values.first)});
  });
  return sortedLocationsList;
}

Coordinates _mapToCoordinates(coordinatesAsMap) => Coordinates(
    latitude: coordinatesAsMap['lat'], longitude: coordinatesAsMap['lon']);

int _compareKeys(first, second) =>
    (double.tryParse(first) - double.tryParse(second)).toInt();
