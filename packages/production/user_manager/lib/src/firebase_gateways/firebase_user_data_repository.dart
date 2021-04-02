import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/helpers.dart';
import '../exceptions/user_data_access_exception.dart';
import '../repositories/user_data_repository.dart';

// TODO refactor : new classes (CacheDataManager).
class FirebaseUserDataRepository implements UserDataRepository {
  SharedPreferences _sharedPreferences;
  CollectionReference _additionalDataReference;
  final FirebaseFirestore _firebaseFirestore;
  static const trophiesKey = 't';
  static const totalRideCountKey = 'r';
  static const initialAdditionalData = {
    trophiesKey: '',
    totalRideCountKey: 0,
  };
  @visibleForTesting
  static const usersAdditionalDataKey = 'users_additional_data';
  @visibleForTesting
  static const rideCountHistoryKey = 'ride_count_history';

  static final FirebaseUserDataRepository _singleton =
      FirebaseUserDataRepository._internal();

  factory FirebaseUserDataRepository() => _singleton;

  FirebaseUserDataRepository._internal()
      : _firebaseFirestore = FirebaseFirestore.instance {
    SharedPreferences.getInstance().then((value) => _sharedPreferences = value);
    _setupFirestore();
  }

  @visibleForTesting
  FirebaseUserDataRepository.forTest({
    @required FirebaseFirestore firestoreDatabase,
    @required SharedPreferences sharedPreferences,
  }) : _firebaseFirestore = firestoreDatabase ?? FirebaseFirestore.instance {
    if (sharedPreferences == null) {
      SharedPreferences.getInstance()
          .then((value) => _sharedPreferences = value);
    } else {
      _sharedPreferences = sharedPreferences;
    }
    _setupFirestore();
  }

  void _setupFirestore() {
    _additionalDataReference =
        _firebaseFirestore.collection(usersAdditionalDataKey);
    _firebaseFirestore.settings = Settings(persistenceEnabled: false);
  }

  @override
  Future<Map<String, dynamic>> getAdditionalData(String userUid) async {
    try {
      // ! Cache data access error should not affect the program execution
      final cachedData = await _getCahedData().catchError((_) => null);
      if (cachedData != null) return cachedData;
      final document = await _additionalDataReference.doc(userUid).get();
      final documentData = document.data();
      await _updateCacheData(documentData).catchError((_) => null);
      return documentData;
    } on FirebaseException {
      throw UserDataAccessException.unknown();
    }
  }

  Future<Map<String, dynamic>> _getCahedData() async {
    final userAdditionalData =
        _sharedPreferences.getString(usersAdditionalDataKey);
    return json.decode(userAdditionalData);
  }

  Future<void> _updateCacheData(Map<String, dynamic> data) async {
    final dataJson = json.encode(data);
    final dataIsSuccessfullySet =
        await _sharedPreferences.setString(usersAdditionalDataKey, dataJson);
    if (!(dataIsSuccessfullySet ?? false)) {
      // delete local data if it is not up to date, and retry if its fail.
      if (!(await _sharedPreferences.clear())) await _sharedPreferences.clear();
    }
  }

  @override
  Future<void> initAdditionalData(String userUid) async {
    try {
      await _updateCacheData(initialAdditionalData).catchError((_) => null);
      await _additionalDataReference.doc(userUid).set(initialAdditionalData);
    } on FirebaseException {
      throw UserDataAccessException.unknown();
    }
  }

  @override
  Future<void> updateAdditionalData({
    @required Map<String, dynamic> data,
    @required String userUid,
  }) async {
    try {
      await _updateCacheData(data).catchError((_) => null);
      await _additionalDataReference.doc(userUid).update(data);
    } on FirebaseException {
      throw UserDataAccessException.unknown();
    }
  }

  @override
  Future<void> incrmentRideCount(String userId) async {
    try {
      var additionalData = await getAdditionalData(userId);
      additionalData[totalRideCountKey]++;
      await updateAdditionalData(data: additionalData, userUid: userId);
      await incrementTodaysRideCount();
    } on FirebaseException {
      throw UserDataAccessException.unknown();
    }
  }

  @visibleForTesting
  Future<void> incrementTodaysRideCount() async {
    final todaysRideCountKey = generateKeyFromDateTime(DateTime.now());
    final rideCountHistoryJson =
        _sharedPreferences.getString(rideCountHistoryKey);
    final rideCountHistory = json.decode(rideCountHistoryJson);
    var todaysRideCount = rideCountHistory[todaysRideCountKey];
    todaysRideCount = (todaysRideCount ?? 0) + 1;
    rideCountHistory[todaysRideCountKey] = todaysRideCount;
    if (rideCountHistory.length >= 50) {
      clearHistoryOlderThanOneMonth(rideCountHistory);
    }
    await _sharedPreferences.setString(
        rideCountHistoryKey, json.encode(rideCountHistory));
  }

  @override
  Map<String, dynamic> getRideCountHistory() {
    // TODO: make surpport return type [Map<String, int>]
    return json.decode(
      _sharedPreferences.getString(rideCountHistoryKey) ??
          _initializeRideCountHistory(),
    );
  }

  String _initializeRideCountHistory() {
    final rideCountHistoryJson = json.encode({
      generateKeyFromDateTime(DateTime.now()): 0,
    });
    _sharedPreferences.setString(rideCountHistoryKey, rideCountHistoryJson);
    return rideCountHistoryJson;
  }

  @visibleForTesting
  void clearHistoryOlderThanOneMonth(
      Map<String, dynamic> globalRideCountHistory) {
    // TODO: optimize
    final todayDate = DateTime.now();
    globalRideCountHistory.removeWhere((historyDate, _) {
      final currentHistoryDate = DateTime.parse(historyDate);
      return todayDate.difference(currentHistoryDate).inDays > 30;
    });
  }

  @override
  String getTheRecentlyWonTrophies(String userTrophies) {
    var trophiesWon = '';
    var userRideCountSinceXDays;
    try {
      UserDataRepository.trophiesList.forEach((trophyLevel, trophy) async {
        userRideCountSinceXDays =
            userRideCountFromFewDaysToToday(trophy.timeLimit?.inDays);
        if (!userTrophies.contains(trophyLevel) &&
            userRideCountSinceXDays >= trophy.minRideCount) {
          trophiesWon += trophyLevel;
        }
      });
      return trophiesWon;
    } on FirebaseException {
      throw UserDataAccessException.unknown();
    }
  }

  @visibleForTesting
  int userRideCountFromFewDaysToToday(int numberOfDays) {
    if (numberOfDays == null) {
      return _sharedPreferences.getInt(totalRideCountKey);
    }
    var rideCountSinceXDays = 0;
    final todaysDate = DateTime.now();
    final rideCountHistoryJson =
        _sharedPreferences.getString(rideCountHistoryKey);
    final rideCountHistory = json.decode(rideCountHistoryJson);
    var currentHistoryDate;
    var currentHistoryKey;
    while (numberOfDays-- > 0) {
      currentHistoryDate = todaysDate.subtract(Duration(days: numberOfDays));
      currentHistoryKey = generateKeyFromDateTime(currentHistoryDate);
      rideCountSinceXDays += rideCountHistory[currentHistoryKey] ?? 0;
    }
    return rideCountSinceXDays;
  }

  // @override
  // Future<void> setReview({@required String userId, @required String review}) {
  //   _additionalDataReference.doc('$userId/$reviewsKey').
  // }
}
