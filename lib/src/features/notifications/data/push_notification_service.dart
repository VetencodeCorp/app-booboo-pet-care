import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(ref.watch(apiClientProvider));
});

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'booboo_high_priority',
  'Booboo Pet Care',
  description: 'Notifikasi penting dari Booboo Pet Care',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return;
  }
}

class PushNotificationService {
  PushNotificationService(this._client);

  final ApiClient _client;
  Future<void>? _initialization;
  bool _firebaseAvailable = false;

  Future<void> initialize() async {
    if (_initialization != null) return _initialization!;
    _initialization = _initialize();
    return _initialization!;
  }

  Future<void> _initialize() async {
    try {
      await Firebase.initializeApp();
      _firebaseAvailable = true;
    } catch (error) {
      debugPrint('FCM belum dikonfigurasi: $error');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload);
          if (data is Map) unawaited(_openActionUrl(data['action_url']));
        } catch (_) {
          // Ignore malformed local notification payloads.
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleOpenedMessage(initialMessage);
  }

  Future<void> registerCurrentDevice() async {
    await initialize();
    if (!_firebaseAvailable) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerToken(token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
    } catch (error) {
      debugPrint('Token FCM gagal didaftarkan: $error');
    }
  }

  Future<void> _registerToken(String token) {
    return _client.dio.post(
      '/api/push-tokens',
      data: {'token': token, 'platform': defaultTargetPlatform.name},
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    await _localNotifications.show(
      id: message.hashCode,
      title: title ?? 'Booboo Pet Care',
      body: body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'booboo_high_priority',
          'Booboo Pet Care',
          channelDescription: 'Notifikasi penting dari Booboo Pet Care',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    unawaited(_openActionUrl(message.data['action_url']));
  }

  Future<void> _openActionUrl(Object? value) async {
    final url = value?.toString() ?? '';
    final uri = Uri.tryParse(url);
    if (uri == null || !{'http', 'https'}.contains(uri.scheme)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
