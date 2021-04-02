import 'package:flutter/foundation.dart';

import 'entities/user.dart';
import 'firebase_gateways/firebase_auth_provider.dart';

/// {@template auth_provider}
/// An authentication APIs provider (Sign in, Sign out, register, reset password...)
/// {@endtemplate}
abstract class AuthenticationProvider with ChangeNotifier {
  /// The authentication status
  AuthState get authState;

  /// The [user]
  User get user;

  /// Return a binary state of authentication which can be wether
  /// [AuthState.authenticated] or [AuthState.unauthenticated].
  Stream<AuthState> get authBinaryState;

  /// Return the authentication provider singleton
  static AuthenticationProvider get instance => FirebaseAuthProvider();

  /// Attempts to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and [authState]
  /// and [user] will be updated and all [AuthenticationProvider] listeners
  /// will be notified (by the [AuthenticationProvider] it self).
  ///
  /// A [AuthenticationException] maybe thrown with the following
  /// exception types:
  /// - `AuthenticationExceptionType.invalidEmail`:
  ///  - Thrown if the email address is not valid.
  /// - `AuthenticationExceptionType.userDisabled`:
  ///  - Thrown if the user corresponding to the given email has been disabled.
  /// - `AuthenticationExceptionType.userNotFound`:
  ///  - Thrown if there is no user corresponding to the given email.
  /// - `AuthenticationExceptionType.wrongPassword`:
  ///  - Thrown if the password is invalid for the given email, or the account
  ///    corresponding to the email does not have a password set.
  /// - `AuthenticationExceptionType.unknown`
  ///  - Thrown if an unidentified error occurred such as server side error
  ///    or Dart exception.
  Future<void> signInWithEmailAndPassword(
      {@required String email, @required String password});

  /// Tries to create a new user account with the given email address and
  /// password.
  ///
  /// A [AuthenticationException] maybe thrown with the following
  /// exception types:
  /// - `AuthenticationExceptionType.emailAlreadyUsed`:
  ///  - Thrown if there already exists an account with the given email address.
  /// - `AuthenticationExceptionType.invalidEmail`:
  ///  - Thrown if the email address is not valid.
  /// - `AuthenticationException.userNotFound`:
  ///  - Thrown if the password is not strong enough.
  Future<void> registerUser({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  });

  /// Triggers the Authentication backend (in the current case the Firebase
  /// Authentication backend) to send a password-reset
  /// email to the given email address, which must correspond to an existing
  /// user of your app.
  Future<void> sendPasswordResetEmail(String email);

  /// Signs out the current user.
  ///
  /// If successful, [user] and [authState] will be updated and all
  /// [AuthenticationProvider] listeners will be notified.
  Future<void> signOut();

  /// Make a login request using the facebook SDK
  Future<void> signInWithFacebook();
}

enum AuthState {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
  registering,
}
