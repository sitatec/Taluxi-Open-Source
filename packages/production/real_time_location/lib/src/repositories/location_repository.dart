import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../real_time_location.dart';
import '../exceptions/repositories/location_repository_exception.dart';

// TODO handle errors
class LocationRepository {
  final _httpClient = Dio();

  LocationRepository() {
    _httpClient.options.baseUrl = "https://taluxi-360b0.uc.r.appspot.com";
    _httpClient.options.responseType = ResponseType.json;
  }

  Future<void> putLocation({
    @required String userId,
    @required String city,
    @required Coordinates coordinates,
  }) async {
    try {
      await _httpClient.post(
        "/add",
        data: {
          "id": userId,
          "city": city,
          "coord": {"lat": coordinates.latitude, "lon": coordinates.longitude}
        },
      );
    } on DioError catch (e) {
      _handleRequestErrors(e);
    }
  }

  // ignore: missing_return
  Future<Map<String, dynamic>> getClosestLocation({
    @required String city,
    @required Coordinates coordinates,
    double maxDistanceInKm = 2,
    int locationCount = 4,
  }) async {
    try {
      final response = await _httpClient.post("/findClosest", data: {
        "city": city,
        "coord": {"lat": coordinates.latitude, "lon": coordinates.longitude},
        "maxDistance": maxDistanceInKm,
        "count": locationCount
      });
      return response.data;
    } on DioError catch (e) {
      _handleRequestErrors(e);
    }
  }

  Future<void> deleteLocation({
    @required String userId,
    @required String city,
  }) async {
    try {
      await _httpClient.delete("/delete", data: {"city": city, "id": userId});
    } on DioError catch (e) {
      _handleRequestErrors(e);
    }
  }

  void _handleRequestErrors(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT ||
        e.type == DioErrorType.SEND_TIMEOUT) {
      throw LocationRepositoryException.requestTimeout();
    }
    if (e.response != null) {
      if (e.response.statusCode == 404) {
        throw LocationRepositoryException.notFound();
      }
      throw LocationRepositoryException.serverError();
    }
    throw LocationRepositoryException.unknown();
  }
}
