import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_communication/src/messaging/notification_exception.dart';
import 'package:network_communication/src/messaging/notification_handler.dart';
import 'package:network_communication/src/voip/agora_rtc_engine_adapter.dart';
import 'package:network_communication/src/voip/voip_exception.dart';
import 'package:network_communication/src/voip/voip_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../mocks/mock_notification_handler.dart';

class MockRtcEngine extends Mock implements RtcEngine {}

class MockRtcEngineEventHandler extends Mock implements RtcEngineEventHandler {
  @override
  void Function(ConnectionStateType, ConnectionChangedReason)
      connectionStateChanged;
  @override
  void Function(int, int) userJoined;
  @override
  void Function(String, int, int) joinChannelSuccess;
  @override
  void Function(ErrorCode) error;
  @override
  void Function(int, UserOfflineReason) userOffline;
}

class MockPermissionHandler extends Mock implements PermissionHandler {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  VoIPProvider voipProvider;
  RtcEngine rtcEngine;
  RtcEngineEventHandler eventHandler;
  PermissionHandler permissionHandler;
  NotificationHandler notificationHandler;
  const fakeCallId = 'callId';
  const fakeRecipientId = 'recipientID';
  setUp(() async {
    rtcEngine = MockRtcEngine();
    eventHandler = MockRtcEngineEventHandler();
    permissionHandler = MockPermissionHandler();
    notificationHandler = MockNotificationHandler();
    voipProvider = AgoraRtcEnginAdapter.forTest(
      realTimeCommunicationEngine: rtcEngine,
      eventHandler: eventHandler,
      permissionHandler: permissionHandler,
      notificationHandler: notificationHandler,
    );
    MockNotificationHandler.silentNotificatiionListenerCount = 0;
    when(permissionHandler.requestMicrophonePermission())
        .thenAnswer((_) => Future.value(PermissionStatus.granted));
    await voipProvider.initialize(fakeCallId);
  });
  test('Should initialize VoIP needed resources', () async {
    // initialize method is called in the setUp method.
    verifyInOrder([
      permissionHandler.requestMicrophonePermission(),
      rtcEngine.setChannelProfile(ChannelProfile.Communication),
      rtcEngine.enableAudio(),
      rtcEngine.setEventHandler(eventHandler),
      rtcEngine.setParameters('{"che.audio.opensl":true}')
    ]);
    expect(MockNotificationHandler.silentNotificatiionListenerCount, 1);
  });

  group('VoIP connection state handling', () {
    VoIPConnectionState connectionState;
    final fakeConnectionChangedReason = ConnectionChangedReason.Connecting;
    setUp(() {
      voipProvider.connectionStateStream.listen((_connectionState) {
        connectionState = _connectionState;
      });
    });
    test(
        'Should change the the connection state to [VoIPConnectionState.connected]',
        () async {
      eventHandler.connectionStateChanged(
          ConnectionStateType.Connected, fakeConnectionChangedReason);
      await Future.delayed(Duration.zero); //wait for stream data to be received
      expect(connectionState, equals(VoIPConnectionState.connected));
    });
    test(
        'Should change the the connection state to [VoIPConnectionState.disconnected]',
        () async {
      eventHandler.connectionStateChanged(
          ConnectionStateType.Disconnected, fakeConnectionChangedReason);
      await Future.delayed(Duration.zero); //wait for stream data to be received
      expect(connectionState, equals(VoIPConnectionState.disconnected));
    });

    test(
        'Should change the the connection state to [VoIPConnectionState.connecting]',
        () async {
      eventHandler.connectionStateChanged(
          ConnectionStateType.Connecting, fakeConnectionChangedReason);
      await Future.delayed(Duration.zero); //wait for stream data to be received
      expect(connectionState, equals(VoIPConnectionState.connecting));
    });

    test(
        'Should change the the connection state to [VoIPConnectionState.reconnecting]',
        () async {
      eventHandler.connectionStateChanged(
          ConnectionStateType.Reconnecting, fakeConnectionChangedReason);
      await Future.delayed(Duration.zero); //wait for stream data to be received
      expect(connectionState, equals(VoIPConnectionState.reconnecting));
    });
  });

  test('Should Add incoming call notification to the stream', () {
    final fakeNotification = {
      'senderId': 'id',
      'reason': SilentNotificationReason.incomingCall
    };
    voipProvider.incomingCallStream.listen((notification) {
      expect(notification, equals(fakeNotification['senderId']));
    });
    MockNotificationHandler.simulateReceivingSilentNotification(
        fakeNotification);
  });

  test('Should throw a [VoIPException.microphonePermissionDenied]', () {
    when(permissionHandler.requestMicrophonePermission())
        .thenAnswer((_) => Future.value(PermissionStatus.denied));
    expect(
      () async => await voipProvider.initialize(fakeCallId),
      throwsA(
        isA<VoIPException>().having(
          (e) => e.exceptionType,
          'exception type',
          equals(VoIPExceptionType.microphonePermissionDenied),
        ),
      ),
    );
  });

  test('Should throw a [VoIPException.microphonePermissionDenied]', () {
    when(permissionHandler.requestMicrophonePermission())
        .thenAnswer((_) => Future.value(PermissionStatus.permanentlyDenied));
    expect(
      () async => await voipProvider.initialize(fakeCallId),
      throwsA(
        isA<VoIPException>().having(
          (e) => e.exceptionType,
          'exception type',
          equals(VoIPExceptionType.microphonePermissionPermanentlyDenied),
        ),
      ),
    );
  });

  test('Should throw a [VoIPException.microphonePermissionDenied]', () {
    when(permissionHandler.requestMicrophonePermission())
        .thenAnswer((_) => Future.value(PermissionStatus.restricted));
    expect(
      () async => await voipProvider.initialize(fakeCallId),
      throwsA(
        isA<VoIPException>().having(
          (e) => e.exceptionType,
          'exception type',
          equals(VoIPExceptionType.microphonePermissionRestricted),
        ),
      ),
    );
  });

  test('Should destroy all resources used by [VoIPProvider]', () async {
    await voipProvider.destroy();
    verify(rtcEngine.destroy());
  });

  test('Should leave the current call', () async {
    await voipProvider.leaveCall();
    verify(rtcEngine.leaveChannel());
  });

  group('Calling :', () {
    VoidCallback onCallAccepted;
    void Function(CallLeaveReason) onCallLeft;
    void Function(CallFailureReason) onCallFailed;
    VoidCallback onCallRejected;
    VoidCallback onCallSuccess;
    var callResponseTimeout = Duration.zero;

    setUp(() {
      onCallAccepted = onCallRejected = onCallSuccess = () {};
      onCallLeft = (_) {};
      onCallFailed = (_) {};
    });

    Future<void> makeFakeCall() async {
      await voipProvider.makeCall(
          callId: fakeCallId,
          recipientId: fakeRecipientId,
          onCallAccepted: onCallAccepted,
          onCallLeft: onCallLeft,
          onCallFailed: onCallFailed,
          onCallRejected: onCallRejected,
          onCallSuccess: onCallSuccess,
          responseTimeout: callResponseTimeout);
    }

    test('Should call [onCallaccepted] callback', () async {
      var callIsAccepted = false;
      onCallAccepted = () => callIsAccepted = true;
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.userJoined(0, 0);
      expect(callIsAccepted, isTrue);
    });

    test('Should call [onCallLeft] with [hangUp] reason. (make)', () async {
      CallLeaveReason callLeaveReason;
      onCallLeft = (reason) => callLeaveReason = reason;
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.userOffline(0, UserOfflineReason.Quit);
      expect(callLeaveReason, equals(CallLeaveReason.hangUp));
    });

    test('Should call [onCallLeft] with [offline] reason. (make)', () async {
      CallLeaveReason callLeaveReason;
      onCallLeft = (reason) => callLeaveReason = reason;
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.userOffline(0, UserOfflineReason.Dropped);
      expect(callLeaveReason, equals(CallLeaveReason.offline));
    });

    test('Should call [onCallRejected] callback', () async {
      var callIsRejected = false;
      onCallRejected = () => callIsRejected = true;
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      MockNotificationHandler.simulateReceivingSilentNotification(
          {'senderId': 'id', 'reason': SilentNotificationReason.callRejected});
      await Future.delayed(Duration.zero); //Waiting for stream data to be ready
      expect(callIsRejected, isTrue);
    });

    test('Should call [onCallFailed] with [unregestredRecipientId] reason',
        () async {
      when(notificationHandler.sendIncomingCallNotification(fakeRecipientId))
          .thenThrow(NotificationException.unknownRecipientId());
      CallFailureReason callFailureReason;
      onCallFailed = (failReason) => callFailureReason = failReason;
      await makeFakeCall();
      verifyNever(rtcEngine.joinChannel(any, any, any, any));
      expect(
          callFailureReason, equals(CallFailureReason.unregisteredRecipientId));
    });

    test('Should call [onCallFailed] with [unknown] reason', () async {
      when(notificationHandler.sendIncomingCallNotification(fakeRecipientId))
          .thenThrow(NotificationException.unknown());
      CallFailureReason callFailureReason;
      onCallFailed = (failReason) => callFailureReason = failReason;
      await makeFakeCall();
      verifyNever(rtcEngine.joinChannel(any, any, any, any));
      expect(callFailureReason, equals(CallFailureReason.unknwon));
    });

    test('Should call [onCallFailed] with [timedOut] reason', () async {
      CallFailureReason callFailureReason;
      onCallFailed = (failReason) => callFailureReason = failReason;
      callResponseTimeout = Duration(seconds: 1);
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      await Future.delayed(callResponseTimeout);
      expect(callFailureReason, equals(CallFailureReason.timedOut));
    });

    test('Should call [onCallFailed] with [invalidCallId] reason', () async {
      CallFailureReason callFailureReason;
      onCallFailed = (failReason) => callFailureReason = failReason;
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.error(ErrorCode.InvalidChannelId);
      expect(callFailureReason, equals(CallFailureReason.invalidCallId));
    });

    test('Should call [onCallSuccess] callback', () async {
      var callSuccess = false;
      onCallSuccess = () => callSuccess = true;
      await makeFakeCall();
      verify(notificationHandler.sendIncomingCallNotification(fakeRecipientId));
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.joinChannelSuccess('', 0, 0);
      expect(callSuccess, isTrue);
    });
  });

  group('Accepting call :', () {
    void Function(CallLeaveReason) onCallLeft;
    VoidCallback onCallAccepted;
    void Function(CallFailureReason) onFail;
    setUp(() {
      onFail = (_) {};
      onCallAccepted = () {};
      onCallLeft = (_) {};
    });

    Future<void> acceptFakeCall() async {
      await voipProvider.acceptCall(
        callId: fakeCallId,
        onCallAccepted: onCallAccepted,
        onCallLeft: onCallLeft,
        onFail: onFail,
      );
    }

    test('Should call [onCallLeft] with [hangUp] reason. (accept)', () async {
      CallLeaveReason callLeaveReason;
      onCallLeft = (reason) => callLeaveReason = reason;
      await acceptFakeCall();
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.userOffline(0, UserOfflineReason.Quit);
      expect(callLeaveReason, equals(CallLeaveReason.hangUp));
    });

    test('Should call [onCallLeft] with [offline] reason. (accept)', () async {
      CallLeaveReason callLeaveReason;
      onCallLeft = (reason) => callLeaveReason = reason;
      await acceptFakeCall();
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.userOffline(0, UserOfflineReason.Dropped);
      expect(callLeaveReason, equals(CallLeaveReason.offline));
    });

    test('Should call [onCallAccepted] callback', () async {
      var callIsAccepted = false;
      onCallAccepted = () => callIsAccepted = true;
      await acceptFakeCall();
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.joinChannelSuccess('', 0, 0);
      expect(callIsAccepted, isTrue);
    });

    test('Should call [onCallFailed] with [invalidCallId] reason', () async {
      CallFailureReason callFailureReason;
      onFail = (failReason) => callFailureReason = failReason;
      await acceptFakeCall();
      verify(rtcEngine.joinChannel(null, fakeCallId, null, 0));
      eventHandler.error(ErrorCode.InvalidChannelId);
      expect(callFailureReason, equals(CallFailureReason.invalidCallId));
    });
  });

  test('Should reject a call', () async {
    final fakeCallerId = 'fakeId';
    await voipProvider.rejectCall(fakeCallerId);
    verify(
      notificationHandler.sendSilentNotification(
        data: {'reason': SilentNotificationReason.callRejected},
        recipientId: fakeCallerId,
      ),
    );
  });
}
