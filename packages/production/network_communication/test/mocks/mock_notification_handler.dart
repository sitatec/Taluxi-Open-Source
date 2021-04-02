import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:network_communication/src/messaging/notification_handler.dart';

class MockNotificationHandler extends Mock implements NotificationHandler {
  static final _silentNotificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  // static final _pushNotificationStreamController =
  //     StreamController<Notification>.broadcast();

  MockNotificationHandler() {
    _silentNotificationStreamController
      ..onCancel = () {
        silentNotificatiionListenerCount--;
      }
      ..onListen = () => silentNotificatiionListenerCount++;
  }

  static var silentNotificatiionListenerCount = 0;

  @override
  // TODO: implement silentNotificationStream
  Stream<Map<String, dynamic>> get silentNotificationStream =>
      _silentNotificationStreamController.stream;
  // @override
  // Stream<Notification> get pushNotificationStream =>
  //     _pushNotificationStreamController.stream;
  // static void simulateReceivingPushNotification(Notification notification) {
  //   _pushNotificationStreamController.add(notification);
  // }

  static void simulateReceivingSilentNotification(
      Map<String, dynamic> notification) {
    _silentNotificationStreamController.add(notification);
  }
}

// @override
// Future<void> sendIncomingCallNotification(String recipientId) {
//   // TODO: implement sendIncomingCallNotification
//   throw UnimplementedError();
// }

// @override
// Future<void> sendPushNotification(
//     {String recipientId, Notification notification}) {
//   // TODO: implement sendPushNotification
//   throw UnimplementedError();
// }

// @override
// Future<void> sendSilentNotification(
//     {String recipientId, Map<String, dynamic> data}) {
//   // TODO: implement sendSilentNotification
//   throw UnimplementedError();
// }
