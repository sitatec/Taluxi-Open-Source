import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:user_manager/src/entities/user.dart';
import 'package:user_manager/src/exceptions/authentication_exception.dart';
import 'package:user_manager/src/firebase_gateways/firebase_auth_provider.dart';
import 'package:user_manager/src/firebase_gateways/firebase_user_data_repository.dart';
import 'package:user_manager/src/repositories/user_data_repository.dart';
import 'package:user_manager/src/authentication_provider.dart';

import '../mocks/mock_firebase_auth.dart';
import '../mocks/mock_shared_preferences.dart';

class MockFacebookAuth extends Mock implements FacebookAuth {}

void main() {
  FirebaseAuthProvider firebaseAuthProvider;
  UserDataRepository userDataRepository;
  firebase_auth.FirebaseAuth mockFirebaseAuth;
  setUp(() async {
    MockSharedPreferences.enabled = true;
    mockFirebaseAuth = MockFirebaseAuth();
    final firebaseFirestore = MockFirestoreInstance();
    final userAdditionalDataCollection = await firebaseFirestore
        .collection(FirebaseUserDataRepository.usersAdditionalDataKey);
    await userAdditionalDataCollection
        .doc('aabbcc')
        .set(FirebaseUserDataRepository.initialAdditionalData);

    userDataRepository = FirebaseUserDataRepository.forTest(
        firestoreDatabase: firebaseFirestore,
        sharedPreferences: MockSharedPreferences());
    firebaseAuthProvider =
        FirebaseAuthProvider.forTest(userDataRepository, mockFirebaseAuth);
  });
  group('Authentication :', () {
    test('FirebaseUserInterface should be null if no user signed in', () {
      expect(firebaseAuthProvider.user, isNull);
    });

    test('Signin with email and password', () async {
      await firebaseAuthProvider.signInWithEmailAndPassword(
          email: 'test@tes.te', password: 'password');
      await Future.delayed(Duration.zero);
      expect(firebaseAuthProvider.user, isA<User>());
    });

    test('Sign out', () async {
      await firebaseAuthProvider.signInWithEmailAndPassword(
          email: 'test@tes.te', password: 'password');
      await Future.delayed(Duration.zero); // wait for next event loop
      expect(firebaseAuthProvider.user, isA<User>());
      await firebaseAuthProvider.signOut();
      expect(firebaseAuthProvider.user, isNull);
    });

    test(
        'FirebaseAuthProvider should notify its listeners when AuthState changes',
        () async {
      var authStateLog = <AuthState>[];
      firebaseAuthProvider.addListener(() {
        authStateLog.add(firebaseAuthProvider.authState);
      });
      await firebaseAuthProvider.signInWithEmailAndPassword(
        email: 'te@tes.tt',
        password: 'password',
      );
      await Future.delayed(Duration.zero); // wait for next event loop
      expect(authStateLog, [
        AuthState.authenticating,
        AuthState.authenticated,
      ]);
      await firebaseAuthProvider.signOut();
      await Future.delayed(Duration.zero); // wait for next event loop
      expect(authStateLog, [
        AuthState.authenticating,
        AuthState.authenticated,
        AuthState.unauthenticated,
      ]);
    });

    test('Register user', () async {
      await firebaseAuthProvider.registerUser(
        firstName: 'firstName',
        lastName: 'lastName',
        email: 'etst@tes.dgg',
        password: 'null',
      );
      await Future.delayed(Duration.zero);
      expect(firebaseAuthProvider.user, isA<User>());
    });

    test('FirebaseAuthProvider should notify its listeners while registration',
        () async {
      var authStateLog = <AuthState>[];
      firebaseAuthProvider.addListener(() {
        authStateLog.add(firebaseAuthProvider.authState);
      });
      await firebaseAuthProvider.registerUser(
        firstName: 'firstName',
        lastName: 'lastName',
        email: 'etst@tes.dgg',
        password: 'null',
      );
      await Future.delayed(Duration.zero); // wait for next event loop
      expect(authStateLog, [AuthState.registering, AuthState.authenticated]);
    });

    test(
        'Once registered user profile should be updated with first and last name',
        () async {
      const firstName = 'Updated', lastName = 'Profile';
      await firebaseAuthProvider.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: 'etst@tes.dgg',
        password: 'null',
      );
      await Future.delayed(Duration.zero); // wait for next event loop
      expect(
          firebaseAuthProvider.user.userName, equals('$firstName $lastName'));
    });

    // TODO test Facebook sign in sign out.
    // test('Sign in with facebook login', () {
    //
    //
    // });
    // TODO : test password reset
  });

/******************************************************************************/
/****************************** [ New Group ] *********************************/
/******************************************************************************/

  group('handling Many wrong password', () {
    setUp(() {
      MockFirebaseAuth.mustThrowsException = true;
      MockFirebaseAuth.errorCode = 'wrong-password';
    });
    test('Should increment wrong password counter', () async {
      expect(firebaseAuthProvider.wrongPasswordCounter, isZero);
      expect(
          () async => await firebaseAuthProvider.signInWithEmailAndPassword(
              email: 'test@gjs.sg', password: 'password'),
          throwsException);
      expect(firebaseAuthProvider.wrongPasswordCounter, equals(1));
      // second time
      expect(
          () async => await firebaseAuthProvider.signInWithEmailAndPassword(
              email: 'test@gjs.sg', password: 'password'),
          throwsException);
      expect(firebaseAuthProvider.wrongPasswordCounter, equals(2));
    });

    test(
        'Should reset wrong password counter if user is successfully signed in',
        () async {
      MockFirebaseAuth.mustThrowsException = false;
      firebaseAuthProvider.wrongPasswordCounter = 4;
      expect(firebaseAuthProvider.wrongPasswordCounter, equals(4));
      await firebaseAuthProvider.signInWithEmailAndPassword(
          email: '', password: '');
      expect(firebaseAuthProvider.user, isA<User>());
      expect(firebaseAuthProvider.wrongPasswordCounter, isZero);
    });

    test(
        'Should throw a exception with a exceptionType [accountExistsWithDifferentCredential] if the initial sign in method of user is facebook and the user try to sign in with email and password.',
        () async {
      firebaseAuthProvider.wrongPasswordCounter = 3;
      firebaseAuthProvider.lastTryedEmail = 'same';
      MockFirebaseAuth.signInMethds = ['facebook.com'];
      expect(
        () async => await firebaseAuthProvider.signInWithEmailAndPassword(
            email: 'same', password: ''),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.exceptionType,
            'Exception type',
            equals(
              AuthenticationExceptionType.accountExistsWithDifferentCredential,
            ),
          ),
        ),
      );
    });

    test(
        'Should throw an exception with a message which suggests the user to reset him password.',
        () async {
      firebaseAuthProvider.wrongPasswordCounter = 3;
      firebaseAuthProvider.lastTryedEmail = 'same';
      MockFirebaseAuth.signInMethds = ['password'];
      expect(
        () async => await firebaseAuthProvider.signInWithEmailAndPassword(
            email: 'same', password: ''),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.message,
            'Exception type',
            equals(
              'Mot de passe incorrect. Vous avez tenté de vous connecter ${firebaseAuthProvider.wrongPasswordCounter + 1} fois avec la même adresse email sans succès, si vous avez oublié votre mot de passe veuillez appuyer sur ”Mot de passe oublié ?”  juste en dessous à droite du bouton “Valider” pour le récupérer.',
            ), //! [wrongPasswordCount] will be incremented when signing in.
          ),
        ),
      );
    });
  });

/******************************************************************************/
/****************************** [ New Group ] *********************************/
/******************************************************************************/

  group('Should convert [FirebaseAuthException] with error code', () {
    final methodsToTest = {
      'signInWithEmailAndPassword': () async =>
          await firebaseAuthProvider.signInWithEmailAndPassword(
            email: 'e',
            password: 'p',
          ),
      'registerUser': () async => await firebaseAuthProvider.registerUser(
            firstName: 'firstName',
            lastName: 'lastName',
            email: 'etst@tes.dgg',
            password: 'null',
          ),
    };
    setUp(() {
      // if true any method call on [MockFirebaseAuth] will throw a exception.
      MockFirebaseAuth.mustThrowsException = true;
    });
    tearDownAll(() {
      MockFirebaseAuth.mustThrowsException = false;
    });
    methodsToTest.forEach((methodName, method) {
      final errorCodeMatcher = errorCodeMatcherForEachMethod[methodName];
      errorCodeMatcher.keys.forEach((errorCode) {
        test(
            '[$errorCode] to [AuthenticationException] with ExceptionType [${errorCodeMatcher[errorCode]}].',
            () {
          MockFirebaseAuth.errorCode =
              errorCode; // set error code which will be used to throw the next [FirebaseAuthException].
          expect(
            method,
            throwsA(
              isA<AuthenticationException>().having(
                (e) => e.exceptionType,
                'Exception type',
                equals(errorCodeMatcher[errorCode]),
              ),
            ),
          );
        });
      });
    });
  });
}

final errorCodeMatcherForEachMethod =
    <String, Map<String, AuthenticationExceptionType>>{
  'signInWithEmailAndPassword': {
    'user-not-found': AuthenticationExceptionType.userNotFound,
    'invalid-email': AuthenticationExceptionType.invalidEmail,
    'wrong-password': AuthenticationExceptionType.wrongPassword,
    'user-disabled': AuthenticationExceptionType.userDisabled,
    'too-many-requests': AuthenticationExceptionType.tooManyRequests,
  },
  'registerUser': {
    'invalid-email': AuthenticationExceptionType.invalidEmail,
    'email-already-in-use': AuthenticationExceptionType.emailAlreadyUsed,
    'weak-password': AuthenticationExceptionType.weakPassword,
  },
  // 'signInWithFacebook': {
  //   'invalid-verification-code':
  //       AuthenticationExceptionType.invalidVerificationCode,
  //   'account-exists-with-different-credential':
  //       AuthenticationExceptionType.accountExistsWithDifferentCredential,
  //   'invalid-credential': AuthenticationExceptionType.invalidCredential,
  // }
};
