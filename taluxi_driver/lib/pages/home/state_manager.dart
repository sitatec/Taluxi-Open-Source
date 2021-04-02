import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:network_communication/network_communication.dart';
import 'package:real_time_location/real_time_location.dart';

//TODO handle errors in the two apps.
// TODO Refactore.

class StateManager {
  final String _currentUserId;
  final _voIpProvider = VoIPProvider.instance;
  final RealTimeLocation _realTimeLocation;
  final BuildContext _context;
  var _callAccepted = false;
  Timer _antiSpamTimer;
  var _connectionStateRecentlyChanged = false;
  var _canChangeConnectionState = true;
  final _stateStreamController = StreamController<State>();
  String _incomingCallId;

  Stream<State> get state => _stateStreamController.stream;

  StateManager({
    @required String currentUserId,
    @required BuildContext context,
    @required RealTimeLocation realTimeLocation,
  })  : _currentUserId = currentUserId,
        _context = context,
        _realTimeLocation = realTimeLocation;

  Future<void> connectsDriver() async {
    // await _voIpProvider.initialize(_currentUserId);
    // await Future.delayed(Duration(seconds: 5));
    // final incomingCallHandler =
    //     IncomingCallPlatformInterface(onCallAccepted: () {
    //   _voIpProvider.acceptCall(
    //     callId: "sitatech",
    //     onCallAccepted: () => print("\n\n_____CALL-ACCEPTED_____\n\n"),
    //     onCallLeft: (_) => print("\n\n_____CALL-LEFT_____\n\n"),
    //     onFail: (_) => print("\n\n_____CALL-FAIL_____\n\n"),
    //   );
    // });
    // return incomingCallHandler.displayIncomingCall('callerName', 'phoneNumber');
    if (!(await CallKeep.isCurrentDeviceSupported)) {
      _stateStreamController.add(
        ConnectionFailed(
          'Désolé, votre téléphone ne prend pas en charge certaines fonctionnalités de Taluxi. Veuillez essayer avec un autre téléphone.',
        ),
      );
    }
    try {
      await _realTimeLocation.initialize(currentUserId: _currentUserId);
      await _voIpProvider.initialize(_currentUserId);
      await CallKeep.setup();
      await CallKeep.askForPermissionsIfNeeded(_context);
      _voIpProvider.incomingCallStream.listen(_inComingCallHandler);
      _realTimeLocation.startSharingLocation();
    } on DeviceLocationHandlerException catch (e) {
      _handleDeviceLocationHandlerExceptions(e);
    } on LocationRepositoryException catch (e) {
      _handleLocationRepositoryExceptions(e, ConnectionFailed(''));
    } on Exception {
      // TODO raport
      _stateStreamController.add(
        ConnectionFailed(
          "Une erreur s'est produite, s'il vous plaît veuillez réessayer. Si l'erreur persiste veuillez relancer l'application et vérifier votre connexion internet.",
        ),
      );
    }
  }

  void _handleDeviceLocationHandlerExceptions(
    DeviceLocationHandlerException exception,
  ) {
    switch (exception.exceptionType) {
      case DeviceLocationHandlerExceptionType.permissionDenied:
        _stateStreamController.add(
          ConnectionFailed(
            "L'application Taluxi a besoin d'accéder à votre localisation pour pouvoir fonctionner. Veuillez autoriser Taluxi à accéder à votre localisation en appuyant sur \"Toujours autoriser\" lorsqu'on vous le demande.",
          ),
        );
        break;
      case DeviceLocationHandlerExceptionType.permissionPermanentlyDenied:
        _stateStreamController.add(
          ConnectionFailed(
            "Taluxi n'arrive pas à accéder à votre localisation, son accès à été permanent bloqué. Vous devez réinstaller l'application taluxi et l'autoriser à accéder à votre localisation en appuyant sur \"Toujours autoriser\" lorsqu'on vous le demandera après l'avoir réinstaller car taluxi ne peut pas fonctionner sans localisation. Merci de votre compréhension.",
          ),
        );
        break;
      case DeviceLocationHandlerExceptionType.locationServiceDisabled:
        _stateStreamController.add(
          ConnectionFailed(
            "Veuillez activer le GPS de votre téléphone puis réessayer.",
          ),
        );
        break;
      default:
    }
  }

  void _handleLocationRepositoryExceptions(
      LocationRepositoryException exception, StateWithReason state) {
    switch (exception.exceptionType) {
      case LocationRepositoryExceptionType.requestTimeout:
        state.reason =
            "Le serveur met trop de temps à répondre (cela est certainement dû à une connexion internet lente). Veuillez vous assurez de disposer d'une bonne connexion internet et réessayez.";
        break;
      case LocationRepositoryExceptionType.notFound:
        state.reason =
            "Il semblerait que vous êtes déjà déconnecté, si vous pensez que c'est un malentendu veuillez relancer l'application.";
        break;
      case LocationRepositoryExceptionType.serverError:
      case LocationRepositoryExceptionType.unknown:
        state.reason =
            "Une erreur s'est produite. Veuillez réessayer, si l'erreur persiste relancez l'application.";
        break;
    }
    _stateStreamController.add(state);
  }

// TODO implement anti spam.
  // bool _preventSpam() {
  //   if (_canChangeConnectionState) {
  //     if (_connectionStateRecentlyChanged) {

  //     }
  //     _connectionStateRecentlyChanged = true;
  //     return true;
  //   }
  //   return false;
  // }

  // void lockConnectionState() {
  //   _canChangeConnectionState = false;
  //   _antiSpamTimer = Timer(Duration(minutes: 5), () {
  //     _canChangeConnectionState = true;
  //     _connectionStateRecentlyChanged = false;
  //   });
  // }

  Future<void> disconnectsDriver() async {
    try {
      await _realTimeLocation.stopLocationSharing();
      await _voIpProvider.destroy();
      _stateStreamController.close();
    } on LocationRepositoryException catch (e) {
      _handleLocationRepositoryExceptions(e, DisconnectionFailed(''));
    }
  }

  Future<void> _inComingCallHandler(String callId) async {
    _manageCallEvent(callId);
    await CallKeep.displayIncomingCall(
      callId,
      "Client Taluxi",
      "Client Taluxi",
      HandleType.number,
      false,
    );
    await CallKeep.backToForeground();
  }

  void _manageCallEvent(String callId) {
    _incomingCallId = callId;

    CallKeep.performAnswerCallAction.listen((_) async {
      _callAccepted = true;
      await _voIpProvider.acceptCall(
        callId: callId,
        onCallAccepted: _onCallAccepted,
        onCallLeft: _onCallLeft,
        onFail: _onFail,
      );
      CallKeep.setCurrentCallActive(callId);
    });

    CallKeep.didPerformSetMutedCallAction.listen((muteEvent) {
      if (muteEvent.muted)
        _voIpProvider.disableMicrophone();
      else
        _voIpProvider.enableMicrophone();
    });

    CallKeep.performEndCallAction.listen((_) {
      if (_callAccepted)
        _voIpProvider.leaveCall();
      else
        _voIpProvider.rejectCall(callId);
    });
  }

  // TODO implement call callbacks.

  void _onCallAccepted() {}

  void _onCallLeft(CallLeaveReason reason) {
    CallKeep.endCall(_incomingCallId);
  }

  void _onFail(CallFailureReason reason) {}

  Future<void> enableRideMode() async =>
      await _realTimeLocation.enableRideMode(newDistanceFilter: 40);

  void disableRideMode() => _realTimeLocation.disableRideMode();
}

class State {
  const State();
}

class SpamAttempt extends State {}

class ConnectionStateLocked extends State {}

class StateWithReason extends State {
  String reason;
  StateWithReason(this.reason);
}

class ConnectionFailed extends StateWithReason {
  ConnectionFailed(String reason) : super(reason);
}

class DisconnectionFailed extends StateWithReason {
  DisconnectionFailed(String reason) : super(reason);
}

class LocationUpdateFailed extends StateWithReason {
  LocationUpdateFailed(String reason) : super(reason);
}
