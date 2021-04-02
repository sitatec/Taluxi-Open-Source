import 'dart:convert';

import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:user_manager/src/firebase_gateways/firebase_user_data_repository.dart';
import 'package:user_manager/src/firebase_gateways/firebase_user_interface.dart';
import 'package:user_manager/src/utils/helpers.dart';

import '../mocks/mock_shared_preferences.dart';

class MockFirebaseUser extends Mock implements User {
  @override
  String get displayName => _name;
  static String _name = 'Unitialized';
  @override
  String get uid => 'uid';
}

void main() {
  FirebaseUserDataRepository userDataRepository;
  FirebaseUserInterface user;
  //! in some case [user] most be initialized manualy by colling [initUser]
  //! because some initialization is done in the [FirebaseUserInterface] constructor.
  void initUser() {
    userDataRepository = FirebaseUserDataRepository.forTest(
      firestoreDatabase: MockFirestoreInstance(),
      sharedPreferences: MockSharedPreferences(),
    );
    user = FirebaseUserInterface(
      firebaseUser: MockFirebaseUser(),
      userDataRepository: userDataRepository,
    );
  }

  test('Should format user name', () {
    MockFirebaseUser._name = 'sita bérété';
    initUser();
    expect(user.formatedName, equals('Sita'));
  });
  test('Should format user name ', () {
    MockFirebaseUser._name = 'elhadj sita berete';
    initUser();
    expect(user.formatedName, equals('Elhadj sita'));
  });
  test('Should format user name  ', () {
    MockFirebaseUser._name = 'Elhadj sita berete oteh sljfjsl';
    initUser();
    expect(user.formatedName, equals('Elhadj sita'));
  });

  test('Should format user name   ', () {
    MockFirebaseUser._name = 'berete';
    initUser();
    expect(user.formatedName, equals('Berete'));
  });

  group('Errors handling :', () {
    setUp(() {
      MockSharedPreferences.enabled = true;
      MockSharedPreferences.throwException = true;
    });
    tearDownAll(() {
      MockSharedPreferences.enabled = false;
      MockSharedPreferences.throwException = false;
    });

    test(
        "The values of user's additional data should contain 'Erreur' when a exception is thrown.",
        () async {
      initUser();
      await Future.delayed(Duration.zero);
      expect(user.rideCount, equals('Erreur'));
      expect(user.trophies, equals('Erreur'));
      expect(user.rideCount, equals('Erreur'));
      expect(user.rideCountHistory.keys, contains('Erreur'));
    });
  });

  group('Ride count history handling: ', () {
    final fakeInitialHistory = {
      '2019-01-04': 34,
      '2020-01-03': 6,
      '2020-06-02': 0,
      '2020-12-01': 23,
      '2020-12-03': 17,
      '2012-12-30': 0,
      '2017-12-29': 04
    };

    setUp(() {
      MockSharedPreferences.enabled = true;
      MockSharedPreferences
              .data[FirebaseUserDataRepository.rideCountHistoryKey] =
          json.encode(fakeInitialHistory);
      // MockSharedPreferences.data[FirebaseUserDataRepository.totalRideCountKey] = 20;
      // MockSharedPreferences.data[FirebaseUserDataRepository.trophiesKey] = 'A3';
    });

    final now = DateTime.now();
    final todayHistoryKey = generateKeyFromDateTime(now);
    final yesterdayHistoryKey =
        generateKeyFromDateTime(now.subtract(Duration(days: 1)));
    final beforeYesterdayHistoryKey =
        generateKeyFromDateTime(now.subtract(Duration(days: 2)));
    void initHistoryWithThe3LastDaysKeys() {
      MockSharedPreferences
          .data[FirebaseUserDataRepository.rideCountHistoryKey] = json.encode({
        todayHistoryKey: 45,
        yesterdayHistoryKey: 9,
        beforeYesterdayHistoryKey: 23,
      });
    }

    test('Should get ride count hisotry', () async {
      initUser();
      // Wait for end of user Initialization.
      await Future.delayed(Duration.zero);
      expect(user.rideCountHistory.keys, containsAll(fakeInitialHistory.keys));
    });

    test(
        'Should initialize the ride count history with the current day history whose initial value equals 0.',
        () async {
      MockSharedPreferences.data.clear();
      initUser();
      // Wait for end of user Initialization.
      await Future.delayed(Duration.zero);
      //! [user.rideCountHistory] also contains 'Hier' and 'Avant-hier' keys
      //! which is initialized in the [FirebaseUserInterface] class.
      expect(user.rideCountHistory.keys, contains("Aujourd'hui"));
      expect(user.rideCountHistory.values, contains(0));
    });

    test('Should get ride count hisotry with user friendly keys', () async {
      initUser();
      // Wait for end of user Initialization
      await Future.delayed(Duration.zero);
      expect(user.rideCountHistory.keys,
          containsAll(['Aujourd\'hui', 'Hier', 'Avant-hier']));
    });

    test(
        'Should initialize user friendly keys with 0 if the corresponding initial key is not present.',
        () async {
      // TODO: Rewrite description.
      initUser();
      // Wait for end of user Initialization
      await Future.delayed(Duration.zero);
      expect(user.rideCountHistory["Aujourd'hui"], equals(0));
      expect(user.rideCountHistory['Hier'], equals(0));
      expect(user.rideCountHistory['Avant-hier'], equals(0));
    });

    test('Should  replace key with user friendly key without changing value',
        () async {
      initHistoryWithThe3LastDaysKeys();
      final initialHistory = json.decode(MockSharedPreferences
          .data[FirebaseUserDataRepository.rideCountHistoryKey]);
      initUser();
      // Wait for end of user Initialization.
      await Future.delayed(Duration.zero);
      expect(
        user.rideCountHistory["Aujourd'hui"],
        equals(initialHistory[todayHistoryKey]),
      );
      expect(
        user.rideCountHistory['Hier'],
        equals(initialHistory[yesterdayHistoryKey]),
      );

      expect(
        user.rideCountHistory['Avant-hier'],
        equals(initialHistory[beforeYesterdayHistoryKey]),
      );
    });
  });
}
