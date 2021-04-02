import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class IncomingCallHandler {
  VoidCallback _onCallAccepted;
  IncomingCallHandler({@required VoidCallback onCallAccepted})
      : _onCallAccepted = onCallAccepted;
  void displayIncomingCall(String callerName, String phoneNumber);
}

abstract class CallEventHandler {
  void onCallAccepted();
}

class IncomingCallPlatformInterface extends IncomingCallHandler {
  static const platformChannel = const MethodChannel("INCOMING_CALL_CHANNEL");

  IncomingCallPlatformInterface({@required VoidCallback onCallAccepted})
      : super(onCallAccepted: onCallAccepted) {
    platformChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "acceptCall":
          print("\n\n____ Call Accepted ____\n\n");
          _onCallAccepted();
          break;
      }
      return;
    });
  }

  @override
  void displayIncomingCall(String callerName, String phoneNumber) {
    platformChannel.invokeMethod('displayIncomingCall');
  }
}
