import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:network_communication/network_communication.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi_driver/utils/incoming_call_platform_interface.dart';

//TODO handle errors in the two apps.
// TODO Refactore.

class StateManager {
  final String _currentUserId;
  final _voIpProvider = VoIPProvider.instance;
  final RealTimeLocation _realTimeLocation;
  final BuildContext _context;
  var _callAccepted = false;
  String _receivedCallId;
  Timer _antiSpamTimer;
  var _connectionStateRecentlyChanged = false;
  var _canChangeConnectionState = true;
  final _stateStreamController = StreamController<State>();
  String _incomingCallId;
  IncomingCallPlatformInterface _incomingCallHandler;

  Stream<State> get state => _stateStreamController.stream;

  StateManager({
    @required String currentUserId,
    @required BuildContext context,
    @required RealTimeLocation realTimeLocation,
  })  : _currentUserId = currentUserId,
        _context = context,
        _realTimeLocation = realTimeLocation {
    _incomingCallHandler = IncomingCallPlatformInterface(
        onCallAccepted: _acceptCall,
        onCallHangedUp: _hangUpCall,
        toggleSpeaker: _changeSpeakerState,
        toggleMicrophone: _changeMicrophoneState);
  }

  Future<void> connectsDriver() async {
    try {
      await _realTimeLocation.initialize(currentUserId: _currentUserId);
      await _voIpProvider.initialize(_currentUserId);
      _voIpProvider.incomingCallStream.listen(_inComingCallHandler);
      _realTimeLocation.startSharingLocation();
    } on DeviceLocationHandlerException catch (e) {
      _handleDeviceLocationHandlerExceptions(e);
    } on LocationRepositoryException catch (e) {
      _handleLocationRepositoryExceptions(e, ConnectionFailed(''));
    } on Exception {
      // TODO rapport
      _stateStreamController.add(
        ConnectionFailed(
          "Une erreur s'est produite, s'il vous pla??t veuillez r??essayer. Si l'erreur persiste veuillez relancer l'application et v??rifier votre connexion internet.",
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
            "L'application Taluxi a besoin d'acc??der ?? votre localisation pour pouvoir fonctionner. Veuillez autoriser Taluxi ?? acc??der ?? votre localisation en appuyant sur \"Toujours autoriser\" lorsqu'on vous le demande.",
          ),
        );
        break;
      case DeviceLocationHandlerExceptionType.permissionPermanentlyDenied:
        _stateStreamController.add(
          ConnectionFailed(
            "Taluxi n'arrive pas ?? acc??der ?? votre localisation, son acc??s ?? ??t?? permanent bloqu??. Vous devez r??installer l'application taluxi et l'autoriser ?? acc??der ?? votre localisation en appuyant sur \"Toujours autoriser\" lorsqu'on vous le demandera apr??s l'avoir r??installer car taluxi ne peut pas fonctionner sans localisation. Merci de votre compr??hension.",
          ),
        );
        break;
      case DeviceLocationHandlerExceptionType.locationServiceDisabled:
        _stateStreamController.add(
          ConnectionFailed(
            "Veuillez activer le GPS de votre t??l??phone puis r??essayer.",
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
            "Le serveur met trop de temps ?? r??pondre (cela est certainement d?? ?? une connexion internet lente). Veuillez vous assurez de disposer d'une bonne connexion internet et r??essayez.";
        break;
      case LocationRepositoryExceptionType.notFound:
        state.reason =
            "Il semblerait que vous ??tes d??j?? d??connect??, si vous pensez que c'est un malentendu veuillez relancer l'application.";
        break;
      case LocationRepositoryExceptionType.serverError:
      case LocationRepositoryExceptionType.unknown:
        state.reason =
            "Une erreur s'est produite. Veuillez r??essayer, si l'erreur persiste relancez l'application.";
        break;
    }
    _stateStreamController.add(state);
  }

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
    _receivedCallId = callId;
    return _incomingCallHandler.displayIncomingCall();
  }

  void _acceptCall() async {
    _callAccepted = true;
    await _voIpProvider.acceptCall(
      callId: _receivedCallId,
      onCallAccepted: _onCallAccepted,
      onCallLeft: _onCallLeft,
      onFail: _onFail,
    );
  }

  void _hangUpCall() {
    if (_callAccepted) {
      _voIpProvider.leaveCall();
    } else
      _voIpProvider.rejectCall(_receivedCallId);
  }

  void _changeSpeakerState(bool enabled) {
    if (enabled) {
      _voIpProvider.disableSpeaker();
    } else
      _voIpProvider.enableSpeaker();
  }

  void _changeMicrophoneState(bool enabled) {
    if (enabled) {
      _voIpProvider.disableMicrophone();
    } else
      _voIpProvider.enableMicrophone();
  }

  // TODO implement call callbacks.

  void _onCallAccepted() {}

  void _onCallLeft(CallLeaveReason reason) {
    if (_callAccepted) {
      _incomingCallHandler.callerLeftTheCall();
    } else
      _incomingCallHandler.callerHangedUp();
  }

  void _onFail(CallFailureReason reason) {}

  Future<void> enableRideMode() async =>
      await _realTimeLocation.enableRideMode(newDistanceFilter: 40);

  void disableRideMode() => _realTimeLocation.disableRideMode();
}

//------- STATES -------///

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
