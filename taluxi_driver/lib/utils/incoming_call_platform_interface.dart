import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

typedef StateSwitcherCallback = void Function(bool);

class IncomingCallPlatformInterface {
  static const incomingCallChannel =
      const MethodChannel("INCOMING_CALL_CHANNEL");
  static const callEventChannel = const MethodChannel("CALL_EVENTS_CHANNEL");

  VoidCallback onCallAccepted;
  VoidCallback onCallHangedUp;
  StateSwitcherCallback toggleSpeaker;
  StateSwitcherCallback toggleMicrophone;

  IncomingCallPlatformInterface(
      {@required this.onCallAccepted,
      @required this.onCallHangedUp,
      @required this.toggleSpeaker,
      @required this.toggleMicrophone}) {
    incomingCallChannel.setMethodCallHandler((call) {
      if (call.method == "callRejected") onCallHangedUp();
      return;
    });

    callEventChannel.setMethodCallHandler(callEventsHandler);
  }

  void callEventsHandler(MethodCall call) {
    switch (call.method) {
      case "answerCall":
        onCallAccepted();
        break;
      case "toggleSpeaker":
        toggleSpeaker(call.arguments);
        break;
      case "toggleMicrophone":
        toggleMicrophone(call.arguments);
        break;
      case "callHangedUp":
        onCallHangedUp();
    }
  }

  Future<void> displayIncomingCall() {
    return incomingCallChannel.invokeMethod<void>('displayIncomingCall');
  }

  Future<void> callerHangedUp() {
    return incomingCallChannel.invokeMethod<void>("hangUpIncomingCall");
  }

  Future<void> callerLeftTheCall() {
    return callEventChannel.invokeMethod<void>("hangUpAnsweredCall");
  }
}
