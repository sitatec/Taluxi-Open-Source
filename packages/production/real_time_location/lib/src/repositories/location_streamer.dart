import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../exceptions/repositories/location_streamer_exception.dart';

class LocationStreamer {
  @visibleForTesting
  static const onlineNode = 'online';
  final DatabaseReference _realTimeDatabase;

  LocationStreamer({DatabaseReference databaseReference})
      : _realTimeDatabase =
            databaseReference ?? FirebaseDatabase.instance.reference();

  Future<void> removeOnDisconnect({@required city, @required userId}) async {
    await _realTimeDatabase
        .child('$onlineNode/$city/$userId')
        .onDisconnect()
        .remove();
  }

  Future<Map<String, double>> getLocation(
      {@required String city, @required String userUid}) async {
    try {
      final coordinates =
          await _realTimeDatabase.child('$onlineNode/$city/$userUid').once();
      if (coordinates.value == null) return null;
      return _coordinatesStringToMap(coordinates.value);
    } on DatabaseError {
      throw LocationStreamerException.dataAccessFailed();
    }
  }

  Map<String, double> _coordinatesStringToMap(String coordinates) {
    final coordinatesList = coordinates.split('-');
    return {
      'latitude': double.tryParse(coordinatesList.first),
      'longitude': double.tryParse(coordinatesList.last)
    };
  }

  Stream<Map<String, double>> getLocationStream(
      {@required String city, @required String userUid}) async* {
    try {
      final locationStream =
          _realTimeDatabase.child('$onlineNode/$city/$userUid').onValue;
      await for (var event in locationStream) {
        yield _coordinatesStringToMap(event.snapshot.value);
      }
    } on DatabaseError {
      throw LocationStreamerException.dataAccessFailed();
    }
  }

  Future<void> updateLocation(
      {String city, String userUid, Map<String, double> gpsCoordinates}) async {
    try {
      await _realTimeDatabase
          .child('$onlineNode/$city/$userUid')
          .set(_coordinatesMapToString(gpsCoordinates));
    } on DatabaseError {
      throw LocationStreamerException.dataAccessFailed();
    }
  }

  String _coordinatesMapToString(Map<String, double> coordinates) {
    return '${coordinates["latitude"]}-${coordinates["longitude"]}';
  }
}
