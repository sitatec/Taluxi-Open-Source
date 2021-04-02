import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../exceptions/user_data_access_exception.dart';
import '../exceptions/authentication_exception.dart';
import '../authentication_provider.dart';
import '../repositories/user_data_repository.dart';
import '../entities/user.dart';
import 'firebase_user_interface.dart';

class FirebaseAuthProvider
    with ChangeNotifier
    implements AuthenticationProvider {
  firebase_auth.FirebaseAuth _firebaseAuth;
  AuthState _currentAuthState = AuthState.uninitialized;
  final _authStateStreamController = StreamController<AuthState>.broadcast();
  final UserDataRepository _userDataRepository;
  User _user;
  static final _singleton = FirebaseAuthProvider._internal();
  @visibleForTesting
  var wrongPasswordCounter = 0;
  @visibleForTesting
  String lastTryedEmail;

  factory FirebaseAuthProvider() => _singleton;

  FirebaseAuthProvider._internal()
      : _userDataRepository = UserDataRepository.instance,
        _firebaseAuth = firebase_auth.FirebaseAuth.instance {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    _authStateStreamController.onListen =
        () => _authStateStreamController.sink.add(_currentAuthState);
    FacebookAuth.instance.logOut();
  }

  @visibleForTesting
  FirebaseAuthProvider.forTest(this._userDataRepository, this._firebaseAuth)
      : assert(_userDataRepository != null && _firebaseAuth != null) {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    _authStateStreamController.onListen =
        () => _authStateStreamController.sink.add(_currentAuthState);
  }

  @override
  AuthState get authState => _currentAuthState;
  @override
  User get user => _user;
  @override
  Stream<AuthState> get authBinaryState => _authStateStreamController.stream;

  @override
  void dispose() {
    _authStateStreamController.close();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(firebase_auth.User firebaseUser) async {
    // TODO: refactoring
    try {
      if (firebaseUser == null) {
        _user = null;
        _switchState(AuthState.unauthenticated);
      } else {
        if (authState == AuthState.registering) {
          // fetch user profile data that was updated while registering.
          await firebaseUser.reload();
          firebaseUser = _firebaseAuth.currentUser;
        }
        _user = FirebaseUserInterface(
          firebaseUser: firebaseUser,
          userDataRepository: _userDataRepository,
        );
        _switchState(AuthState.authenticated);
        wrongPasswordCounter = 0;
      }
    } catch (e) {
      //TODO: rapport error.
      if (_firebaseAuth.currentUser != null &&
          authState != AuthState.authenticated) {
        _switchState(AuthState.authenticated);
      }
    }
  }

  @override
  Future<void> signInWithFacebook() async {
    try {
      // TODO test signInWithFacebook
      _switchState(AuthState.authenticating);
      final facebookLoginAccessToken = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.DIALOG_ONLY);
      final facebookOAuthCredential =
          firebase_auth.FacebookAuthProvider.credential(
              facebookLoginAccessToken.token);
      final userCredential =
          await _firebaseAuth.signInWithCredential(facebookOAuthCredential);
      if (userCredential.additionalUserInfo.isNewUser) {
        await _userDataRepository.initAdditionalData(userCredential.user.uid);
      }
    } catch (e) {
      throw await _handleException(e);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      _switchState(AuthState.authenticating);
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw await _handleException(firebase_auth.FirebaseAuthException(
        email: email,
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      throw await _handleException(e);
    }
  }

  @override
  Future<void> registerUser({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) async {
    try {
      _switchState(AuthState.registering);
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _userDataRepository.initAdditionalData(userCredential.user.uid);
      await userCredential.user
          .updateProfile(displayName: '$firstName $lastName');
    } catch (e) {
      throw await _handleException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      //TODO: tests sendPasswordResetEmail.
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw await _handleException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw await _handleException(e);
    }
  }

  void _switchState(AuthState targetState) {
    if (_currentAuthState == targetState) return null;
    _currentAuthState = targetState;
    if (targetState == AuthState.authenticated ||
        targetState == AuthState.unauthenticated) {
      _authStateStreamController.sink.add(targetState);
    }
    notifyListeners();
  }

  Future _handleException(dynamic exception) async {
    if (_firebaseAuth.currentUser == null) {
      _switchState(AuthState.unauthenticated);
    }
    if (exception is firebase_auth.FirebaseAuthException) {
      print('\n\n------$exception-----\n\n');
      return await _convertFirebaseAuthException(exception);
    }
    if (exception is UserDataAccessException) {
      return exception; // <==> rethrow
    }
    if (exception is FacebookAuthException) {
      return const AuthenticationException.facebookLoginFailed();
    }
    // TODO: implement error rapport systéme.
    return const AuthenticationException.unknown();
  }

  Future<AuthenticationException> _convertFirebaseAuthException(
      firebase_auth.FirebaseAuthException exception) async {
    switch (exception.code) {
      case 'account-exists-with-different-credential':
        return const AuthenticationException
            .accountExistsWithDifferentCredential();
      case 'invalid-credential':
        return const AuthenticationException.invalidCredential();
      case 'invalid-verification-code':
        return const AuthenticationException.invalidVerificationCode();
      case 'email-already-in-use':
        return const AuthenticationException.emailAlreadyUsed();
      case 'weak-password':
        return const AuthenticationException.weakPassword();
      case 'invalid-email':
        return const AuthenticationException.invalidEmail();
      case 'user-disabled':
        return const AuthenticationException.userDisabled();
      case 'user-not-found':
        return const AuthenticationException.userNotFound();
      case 'wrong-password':
        if (lastTryedEmail != exception.email) {
          wrongPasswordCounter = 0;
          lastTryedEmail = exception.email;
        }
        if (++wrongPasswordCounter >= 3) {
          return await _handleManyWrongPassword(exception);
        }
        return const AuthenticationException.wrongPassword();
      case 'too-many-requests':
        return const AuthenticationException.tooManyRequests();
      default:
        return AuthenticationException.unknown();
    }
  }

  Future<AuthenticationException> _handleManyWrongPassword(
    firebase_auth.FirebaseAuthException exception,
  ) async {
    final userSignInMethods = await _firebaseAuth
        .fetchSignInMethodsForEmail(exception.email)
        .catchError((_) => []);
    if (userSignInMethods.first == 'facebook.com') {
      return AuthenticationException(
        exceptionType:
            AuthenticationExceptionType.accountExistsWithDifferentCredential,
        message:
            "L'adresse email \"${exception.email}\" est déjà liée à un compte facebook que vous avez utilisé auparavant pour vous connecter. Veuillez appuyer sur le bouton ci-dessous pour vous connecter à l’aide de votre compte facebook.",
      );
    }
    if (userSignInMethods.first == 'password') {
      return AuthenticationException(
        exceptionType: AuthenticationExceptionType.wrongPassword,
        message:
            'Mot de passe incorrect. Vous avez tenté de vous connecter $wrongPasswordCounter fois avec la même adresse email sans succès, si vous avez oublié votre mot de passe veuillez appuyer sur ”Mot de passe oublié ?”  juste en dessous à droite du bouton “Valider” pour le récupérer.',
      );
    }
    return const AuthenticationException.wrongPassword();
  }
}
