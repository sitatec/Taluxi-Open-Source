import 'package:flutter/foundation.dart';
import 'package:network_communication/src/messaging/on_signal_adapter.dart';

/// A Notification Handler (Send & Receive)
abstract class NotificationHandler {
  /// The push notifications stream.
  Stream<Notification> get pushNotificationStream;

  /// The silent notifications stream.
  Stream<Map<String, dynamic>> get silentNotificationStream;

  static NotificationHandler get instance => OneSignalAdapter();

  /// Initializes all resources needed by the [NotificationHandler].
  ///
  /// [currentUserId] : The currently logged in user identifier. It is helpful
  /// for notification recipients and the notification server to send
  /// notifications to the current user.
  Future<void> initialize(String currentUserId);

  /// Disposes all resources used by the [NotificationHandler].
  ///
  /// Most be called when the [NotificationHandler] is no longer needed.
  Future<void> destroy();

  /// Sends a push [notification] to the user whose identifier is [recipientId]
  ///
  /// May throw a [NotificationException] if the send fail
  Future<void> sendPushNotification({
    @required String recipientId,
    @required Notification notification,
  });

  /// Sends a [data] only notification (silent notification) to the user whose
  /// identifier is [recipientId]
  ///
  /// May throw a [NotificationException] if the send fail
  Future<void> sendSilentNotification({
    @required String recipientId,
    @required Map<String, dynamic> data,
  });

  /// Sends a incoming call notification to the user whose id is [recipientId].
  ///
  /// May throw a [NotificationException] if the send fail
  Future<void> sendIncomingCallNotification(String recipientId);
}

class SilentNotificationReason {
  //* Might be a [enum] but to make easy data conversion when sending and
  //* receiving, we make a "custom enum" that don't require any conversion and
  //* each value takes only one byte encoded in utf8.
  static const String incomingCall = '0';
  static const String simpleData = '1';
  static const String callRejected = '2';
}

class Notification {
  final String title;
  final String subTitle;
  final String body;
  final List<NotificationActionButton> actionButtons;
  Map<String, dynamic> additionalData;

  Notification({
    @required this.title,
    @required this.body,
    this.subTitle,
    this.actionButtons,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    final notificationMap = <String, dynamic>{
      'contents': {'en': body},
      'headings': {'en': title},
    };
    if (subTitle != null) {
      notificationMap['subtitle'] = subTitle;
    }
    if (additionalData != null) {
      notificationMap['data'] = additionalData;
    }
    if (actionButtons != null) {
      /* Buttons show on device in reverse order of array indexes i.e. the last
       item in array shows as first button. So to preserve the buttons order
       we reverse the list. */
      notificationMap['buttons'] = actionButtons.reversed
          .map((actionButton) => actionButton.toMap())
          .toList();
    }
    return notificationMap;
  }
}

class NotificationActionButton {
  final String id;
  final String text;
  final String iconFilenameOrUrl;

  const NotificationActionButton({
    @required this.id,
    @required this.text,
    @required this.iconFilenameOrUrl,
  });

  NotificationActionButton.fromMap(Map<String, String> buttonMap)
      : this(
            id: buttonMap['id'],
            text: buttonMap['text'],
            iconFilenameOrUrl: buttonMap['icon']);

  Map<String, String> toMap() => {
        'id': id,
        'text': text,
        'icon': iconFilenameOrUrl,
      };
}
