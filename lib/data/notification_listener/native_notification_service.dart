import 'package:flutter/services.dart';

class NativeNotificationService {
  static const _methods =
      MethodChannel('mr_finn/notification_listener/methods');

  static const _events =
      EventChannel('mr_finn/notification_listener/events');

  static Future<bool> isAccessGranted() async {
    return await _methods.invokeMethod<bool>('isAccessGranted') ?? false;
  }

  static Future<void> openAccessSettings() async {
    await _methods.invokeMethod('openAccessSettings');
  }

  static Future<List<Map<String, dynamic>>> consumeBufferedNotifications() async {
    final raw = await _methods.invokeMethod<List<dynamic>>(
          'consumeBufferedNotifications',
        ) ??
        [];

    return raw
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Stream<Map<String, dynamic>> get events {
    return _events.receiveBroadcastStream().map(
          (event) => Map<String, dynamic>.from(event as Map),
        );
  }
}