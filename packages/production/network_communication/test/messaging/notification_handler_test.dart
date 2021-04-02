import 'package:mockito/mockito.dart';
import 'package:network_communication/src/config.dart';
import 'package:network_communication/src/messaging/notification_exception.dart';
import 'package:network_communication/src/messaging/notification_handler.dart';
import 'package:network_communication/src/messaging/on_signal_adapter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:test/test.dart';

class MockOneSignal extends Mock implements OneSignal {
  static void Function(OSNotification) notificationReceptionHandler;
  @override
  void setNotificationReceivedHandler(void Function(OSNotification) handler) {
    notificationReceptionHandler = handler;
  }

  static void sendFakeNotification(OSNotification notification) {
    notificationReceptionHandler(notification);
  }
}

void main() {
  OneSignal oneSignal;
  NotificationHandler notificationHandler;
  const currentUserId = 'user_id';
  const recipientId = 'recipient_id';
  var fakeNotificationData = {'key': 'value', 'key1': 'value1', 'key2': 5};
  final fakeNotificationButtons = [
    OSActionButton(id: 'id', text: 'text', icon: 'icon').mapRepresentation(),
    OSActionButton(id: 'id1', text: 'text1', icon: 'icon1').mapRepresentation()
  ];
  final fakeNotificationPayLoad = {
    'title': 'pushTitile',
    'subtitle': 'pushSubtitle',
    'body': 'pushBody',
    'buttons': fakeNotificationButtons,
    'additionalData': fakeNotificationData
  };
  final fakeSilentNotification = OSNotification({
    'shown': false,
    'payload': {'additionalData': fakeNotificationData},
  });
  final fakePushNotification = OSNotification({
    'shown': true,
    'payload': fakeNotificationPayLoad,
  });

  setUp(() {
    oneSignal = MockOneSignal();
    notificationHandler = OneSignalAdapter.forTest(oneSignal: oneSignal);
    when(oneSignal.postNotificationWithJson(any)).thenAnswer(
        (_) => Future.value({'id': 'lsjf-jsdjfsls-sjfjlsjf', 'recipient': 1}));
  });

  test('Should initialize [NotificationHandler]', () async {
    expect(MockOneSignal.notificationReceptionHandler, isNull);
    await notificationHandler.initialize(currentUserId);
    verifyInOrder([
      oneSignal.init(any),
      oneSignal.setInFocusDisplayType(OSNotificationDisplayType.notification),
      oneSignal.setLocationShared(false),
      oneSignal.setExternalUserId(currentUserId)
    ]);
    expect(MockOneSignal.notificationReceptionHandler, isA<Function>());
  });

  group('', () {
    setUp(() async {
      await notificationHandler.initialize(currentUserId);
    });

    test('Should add received push notification to [pushNotificationStream]',
        () async {
      final receivedNotification =
          notificationHandler.pushNotificationStream.first;
      MockOneSignal.sendFakeNotification(fakePushNotification);
      expect(
          (await receivedNotification).title, fakeNotificationPayLoad['title']);
    });

    test(
        'Should add received silent notification to [silentNotificationStream]',
        () async {
      final receivedNotification =
          notificationHandler.silentNotificationStream.first;
      MockOneSignal.sendFakeNotification(fakeSilentNotification);
      expect((await receivedNotification), fakeNotificationData);
    });

    test('Should send push notification', () async {
      final notification =
          Notification(body: 'body_notif', title: 'title_notif');
      await notificationHandler.sendPushNotification(
        notification: notification,
        recipientId: recipientId,
      );
      verify(oneSignal.postNotificationWithJson(
        argThat(
          equals(
            {
              'app_id': oneSignalAppId,
              'include_external_user_ids': [recipientId],
              'channel_for_external_user_ids': 'push',
            }..addAll(notification.toMap()),
          ),
        ),
      ));
    });

    test('Should send silent notification', () async {
      await notificationHandler.sendSilentNotification(
        recipientId: recipientId,
        data: fakeNotificationData,
      );
      verify(
        oneSignal.postNotificationWithJson(
          argThat(
            equals({
              'app_id': oneSignalAppId,
              'include_external_user_ids': [recipientId],
              'data': fakeNotificationData,
              'content_available': true,
              'priority': 9,
            }),
          ),
        ),
      );
    });

    test('Should send incoming call notification', () async {
      await notificationHandler.sendIncomingCallNotification(recipientId);
      verify(
        oneSignal.postNotificationWithJson(
          argThat(
            equals({
              'app_id': oneSignalAppId,
              'include_external_user_ids': [recipientId],
              'content_available': true,
              'priority': 10,
              'ttl': 30,
              'data': {
                'reason': SilentNotificationReason.incomingCall,
                'senderId': currentUserId
              },
            }),
          ),
        ),
      );
    });

    test('Should throw a [NotificationException.unknown]', () async {
      final notification =
          Notification(body: 'body_notif', title: 'title_notif');
      when(oneSignal.postNotificationWithJson(any)).thenAnswer(
        (_) async => Future.value({
          'id': 'fslsjfsl-sjfksj-sjfsfs-sfssf',
          'recipients': 1,
          'errors': 'Some error'
        }),
      );
      expect(
        () async => await notificationHandler.sendPushNotification(
          recipientId: recipientId,
          notification: notification,
        ),
        throwsA(isA<NotificationException>().having((e) => e.exceptionType,
            'Exception type', equals(NotificationExceptionType.unknown))),
      );
    });

    test('Should throw a [NotificationException.unknownRecipientId]', () async {
      final notification =
          Notification(body: 'body_notif', title: 'title_notif');
      when(oneSignal.postNotificationWithJson(any)).thenAnswer(
        (_) async => Future.value({
          'id': 'fslsjfsl-sjfksj-sjfsfs-sfssf',
          'recipients': 1,
          'errors': ['All included players are not subscribed']
        }),
      );
      expect(
        () async => await notificationHandler.sendPushNotification(
          recipientId: recipientId,
          notification: notification,
        ),
        throwsA(
          isA<NotificationException>().having(
            (e) => e.exceptionType,
            'Exception type',
            equals(NotificationExceptionType.unknownRecipientId),
          ),
        ),
      );
    });
  });
}
