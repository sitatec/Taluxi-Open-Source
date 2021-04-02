import 'package:flutter/foundation.dart';
import 'package:network_communication/src/voip/agora_rtc_engine_adapter.dart';

/// A Voice call provider.
abstract class VoIPProvider {
  /// The incoming call identifiers stream.
  Stream<String> get incomingCallStream;

  Stream<VoIPConnectionState> get connectionStateStream;

  /// Returns the VoIPProvider singleton.
  static VoIPProvider get instance => AgoraRtcEnginAdapter();

  /// Initializes all required resources.
  ///
  /// Must be called before doing anything related to VoIP.
  ///
  /// May throw a [VoIPException] with one of the following [VoIPExceptionType]:
  /// - `microphonePermissionDenied`
  ///  - Thrown if the microphone permission is denied.
  /// - `microphonePermissionPermanentlyDenied`
  ///  - Thrown if the microphone permission is permanently denied. Can happen
  ///  if the user check the "don't ask again" check box when asking for
  ///  permission.
  /// - `microphonePermissionRestricted`
  ///  - Thrown If the OS denied access to the microphone, possibly due
  ///  to active restrictions such as parental controls being in place. Only
  ///  supported on iOS.
  Future<void> initialize(String currentUserId);

  /// Disposes all resources used by the VoIP provider.
  ///
  /// Afer you call this method if you need to use [VoIPProvider] again you need
  /// to reinitialize all ressources by calling [VoIPProvider.initialize()]
  /// otherwise you will get an error.
  ///
  /// Must be called when no VoIP service is needed again.
  Future<void> destroy();

  /// Leaves the current call (Hang up).
  Future<void> leaveCall();

  /// Makes a call.
  ///
  /// __Parameters :__
  /// - [callId]
  ///   - The call unique identifier, the user that have to receive the
  /// call need this identifier to accept it. __This ID must be unique__
  /// otherwise an involuntary conference call will happen.
  /// - [recipientId]
  ///   - The call recipient ID.
  /// - [onCallAccepted]
  ///   - Will be called if the call recipient accepts the call.
  /// - [onCallRejected]
  ///   - Will be called if the call recipient rejects the call.
  /// - [onCallLeft]
  ///   - Will be called if the call recipient leaves the call (The call is
  /// already be accepted).
  /// - [onCallSuccess]
  ///   - Will be called if the call is successfully made
  /// (regardless of whether the recipient accept or reject it).
  /// - [onCallFailed]
  ///   - Will be called if the call failed.
  Future<void> makeCall({
    @required String callId,
    @required String recipientId,
    @required VoidCallback onCallAccepted,
    @required VoidCallback onCallRejected,
    @required void Function(CallLeaveReason) onCallLeft,
    @required void Function(CallFailureReason) onCallFailed,
    VoidCallback onCallSuccess,
    Duration responseTimeout = const Duration(seconds: 30),
  });

  /// Accepts an incoming call
  ///
  /// - [callID] :
  ///   - The incoming call ID. It must be provided by the caller by
  /// any method.
  /// - [onCallLeft]
  ///   - Called when the caller(remote user) leave
  /// the call it take a [CallLeaveReason] parameter which can be weither
  /// [CallLeaveReason.offline] or [CallLeaveReason.hangUp].
  /// - [onCallAccepted]
  ///   - Called when the call is successfully accepted, that means the audio
  /// stream is started.
  /// - [onFail]
  ///   - Will be called when accepting the call fails
  Future<void> acceptCall({
    @required String callId,
    @required void Function(CallLeaveReason) onCallLeft,
    @required VoidCallback onCallAccepted,
    @required void Function(CallFailureReason) onFail,
  });

  /// Rejects an incoming call
  ///
  /// [callId] the call id
  Future<void> rejectCall(String callId);

  /// Enable the speaker
  Future<void> enableSpeaker();

  /// Disable the speaker
  Future<void> disableSpeaker();

  /// Disable the microphone
  Future<void> disableMicrophone();

  /// Enable the microphone
  Future<void> enableMicrophone();
}

enum CallLeaveReason {
  /// When the user is offline e.g (wifi signal lost, phone power of...)
  offline,

  /// When the user voluntarily leave the call by taping the hang up button.
  hangUp
}

enum CallFailureReason {
  /// When the call response timeout is ecouled.
  timedOut,

  /// When the provided call id is invalid like when it content unsupported
  /// character
  invalidCallId,

  /// When the fail reason is unknown
  unknwon,

  /// When the recipient's id isn't registered on the server
  unregisteredRecipientId
}

enum VoIPConnectionState {
  /// When the user use connected.
  connected,

  /// When the user connection is in progress.
  connecting,

  /// When the user is disconnected.
  disconnected,

  /// When the user is disconnected and VoIP client try to reconnect.
  reconnecting,
}
