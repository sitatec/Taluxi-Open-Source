import 'package:geocoding/geocoding.dart';
import '../exceptions/utils/reverse_geocoder_exception.dart';

import '../../real_time_location.dart';

class ReverseGeocoder {
  Future<String> getCityFromCoordinates(Coordinates coordinates) async {
    try {
      final placeMarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
        localeIdentifier: 'en_US',
      );
      return placeMarks.first.subAdministrativeArea;
    } on NoResultFoundException {
      throw ReverseGeocoderException.noResultFound();
    }
  }
}
