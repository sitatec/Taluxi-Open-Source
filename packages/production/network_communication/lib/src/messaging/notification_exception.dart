import 'package:flutter/foundation.dart';

class NotificationException implements Exception {
  final String message;
  final NotificationExceptionType exceptionType;

  const NotificationException({
    @required this.exceptionType,
    @required this.message,
  });

  const NotificationException.unknown()
      : this(
          exceptionType: NotificationExceptionType.unknown,
          message: 'unknown error',
        );

  const NotificationException.unknownRecipientId()
      : this(
          exceptionType: NotificationExceptionType.unknownRecipientId,
          message:
              'The provided recipientId is not registred on the server. Provide subscribed recipient identifier.',
        );
}

enum NotificationExceptionType {
  unknown,

  /// When the recipient id isn't registered on the notification server
  unknownRecipientId
}
