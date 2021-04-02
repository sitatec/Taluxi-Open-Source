import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_communication/src/messaging/notification_exception.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../config.dart';
import 'notification_handler.dart';

class OneSignalAdapter implements NotificationHandler {
  final OneSignal _oneSignal;
  String _currentUserId;
  StreamController<Map<String, dynamic>> _silentNotificationStreamController;
  StreamController<Notification> _pushNotificationStreamController;

  final _request = Dio(BaseOptions(
    baseUrl: 'https://onesignal.com',
    headers: {
      'Authorization': 'Basic MjA2ZDdlOWMtYTNmNC00MTQ5LWJiYWItYmI2NGZhNDk1MTk0',
      'Content-Type': 'application/json; charset=utf-8',
    },
  ));

  static final _singleton = OneSignalAdapter._internal();

  factory OneSignalAdapter() => _singleton;

  OneSignalAdapter._internal() : _oneSignal = OneSignal.shared;

  OneSignalAdapter.forTest({
    OneSignal oneSignal,
  }) : _oneSignal = oneSignal;

  @override
  Stream<Notification> get pushNotificationStream =>
      _pushNotificationStreamController.stream;

  @override
  Stream<Map<String, dynamic>> get silentNotificationStream =>
      _silentNotificationStreamController.stream;

  @override
  Future<void> initialize(String currentUserId) async {
    _currentUserId = currentUserId;
    await _oneSignal.init(oneSignalAppId);
    await _oneSignal
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    await _oneSignal.setLocationShared(false);
    await _oneSignal.setExternalUserId(_currentUserId);
    print('\n\n____on____\n$_currentUserId\n_____si___\n\n');
    _setUpNotificationReceptionHandlers();
  }

  void _setUpNotificationReceptionHandlers() {
    _pushNotificationStreamController =
        StreamController<Notification>.broadcast();
    _silentNotificationStreamController =
        StreamController<Map<String, dynamic>>.broadcast();
    _oneSignal.setNotificationReceivedHandler((osNotification) {
      if (osNotification.shown) _addToPushNotificationStream(osNotification);
      _silentNotificationStreamController
          .add(osNotification.payload.additionalData);
    });
  }

  void _addToPushNotificationStream(OSNotification osNotification) {
    _pushNotificationStreamController.add(
      Notification(
        title: osNotification.payload.title,
        subTitle: osNotification.payload.subtitle,
        body: osNotification.payload.body,
        additionalData: osNotification.payload.additionalData,
        actionButtons: osNotification.payload.buttons
            .map((button) => NotificationActionButton.fromMap(
                button.mapRepresentation().cast<String, String>()))
            .toList(),
      ),
    );
  }

  @override
  Future<void> destroy() async {
    await _silentNotificationStreamController.close();
    await _pushNotificationStreamController.close();
  }

  @override
  Future<void> sendPushNotification({
    @required String recipientId,
    @required Notification notification,
  }) async {
    final response = await _request.post(
      '/api/v1/notifications',
      data: {
        'app_id': oneSignalAppId,
        'include_external_user_ids': [recipientId],
        'channel_for_external_user_ids': 'push',
      }..addAll(notification.toMap()),
    );
    if (response.data.containsKey('errors')) {
      throw _handleErrorResponse(response.data);
    }
  }

  @override
  Future<void> sendSilentNotification(
      {@required String recipientId,
      @required Map<String, dynamic> data}) async {
    data['senderId'] = _currentUserId;
    final notification = {
      'app_id': oneSignalAppId,
      'include_external_user_ids': [recipientId],
      'content_available': true
    };
    _setNotificationPriority(data, notification);
    notification['data'] = data;
    final response =
        await _request.post('/api/v1/notifications', data: notification);
    print('\n\n______________\n $recipientId \n______________\n\n');
    if (response.data.containsKey('errors')) {
      throw _handleErrorResponse(response.data);
    }
  }

  void _setNotificationPriority(
      Map<String, dynamic> data, Map<String, Object> notification) {
    if (data['reason'] == SilentNotificationReason.incomingCall) {
      notification['priority'] = 10;
      notification['ttl'] = 30;
      // TODO: Adapts the ttl according to the number of drivers connected in the current zone(drivers++ => ttl--), so if a driver don't take the call quickly we call another to improve user experiance.
    } else {
      notification['priority'] = 9;
      data['reason'] == SilentNotificationReason.simpleData;
    }
  }

  @override
  Future<void> sendIncomingCallNotification(String recipientId) async {
    await sendSilentNotification(
      recipientId: recipientId,
      data: {'reason': SilentNotificationReason.incomingCall},
    );
  }

  NotificationException _handleErrorResponse(Map<String, dynamic> response) {
    final errors = response['errors'];
    if (errors is List &&
        errors.contains('All included players are not subscribed')) {
      return NotificationException.unknownRecipientId();
    }
    return NotificationException.unknown();
  }
}

// List<NotificationActionButton> _oSActionButtonsToNotificationActionButtons(List<OSActionButton> oSActionButton){

//                 .map((button) => NotificationActionButton.fromMap(
//                     button.mapRepresentation().cast<String, String>()))
//                 .toList()
// }
