import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDeepLink {
  const NotificationDeepLink._();

  static String? fromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route == null) return null;
    if (RegExp(r'^/orders/[A-Za-z0-9_-]{1,128}$').hasMatch(route) ||
        RegExp(r'^/admin/orders/[A-Za-z0-9_-]{1,128}$').hasMatch(route)) {
      return route;
    }
    return null;
  }
}

enum NotificationPermissionState {
  unavailable,
  notDetermined,
  denied,
  authorized,
  provisional
}

class ForegroundNotification {
  const ForegroundNotification(this.title, this.body);
  final String title;
  final String body;
}

abstract interface class NotificationService {
  Stream<String> get deepLinks;
  Stream<ForegroundNotification> get foregroundNotifications;
  Future<void> start();
  Future<NotificationPermissionState> permissionState();
  Future<NotificationPermissionState> requestPermissionAndRegister();
  Future<void> deactivateCurrentDevice();
  void dispose();
}

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService(this._messaging, this._functions, this._auth);

  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final _deepLinks = StreamController<String>.broadcast();
  final _foreground = StreamController<ForegroundNotification>.broadcast();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _tapSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  String? _activeUid;
  bool _started = false;

  @override
  Stream<String> get deepLinks => _deepLinks.stream;
  @override
  Stream<ForegroundNotification> get foregroundNotifications =>
      _foreground.stream;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _authSubscription = _auth.authStateChanges().listen((user) async {
      final previousUid = _activeUid;
      _activeUid = user?.uid;
      if (previousUid != null && previousUid != user?.uid) {
        await _deactivateFor(previousUid);
      }
      if (user != null) await _registerIfPermissionGranted();
    });
    _tokenSubscription = _messaging.onTokenRefresh.listen((_) async {
      await _registerIfPermissionGranted();
    });
    _tapSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title;
      final body = message.notification?.body;
      if (title != null || body != null) {
        _foreground.add(ForegroundNotification(title ?? 'BM', body ?? ''));
      }
    });
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  @override
  Future<NotificationPermissionState> permissionState() async =>
      _toState(await _messaging.getNotificationSettings());

  @override
  Future<NotificationPermissionState> requestPermissionAndRegister() async {
    final settings = await _messaging.requestPermission(
        alert: true, badge: true, sound: true);
    final state = _toState(settings);
    if (state == NotificationPermissionState.authorized ||
        state == NotificationPermissionState.provisional) {
      await _registerIfPermissionGranted();
    }
    return state;
  }

  Future<void> _registerIfPermissionGranted() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final state = await permissionState();
    if (state != NotificationPermissionState.authorized &&
        state != NotificationPermissionState.provisional) {
      return;
    }
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    final deviceId = await _deviceId();
    await _functions.httpsCallable('registerDeviceToken').call<void>({
      'deviceId': deviceId,
      'token': token,
      'platform': _platformName(),
      'locale': PlatformDispatcher.instance.locale.languageCode,
      'appVersion': '0.1.0',
    });
  }

  @override
  Future<void> deactivateCurrentDevice() async {
    final uid = _auth.currentUser?.uid ?? _activeUid;
    if (uid != null) await _deactivateFor(uid);
  }

  Future<void> _deactivateFor(String uid) async {
    if (_auth.currentUser?.uid != uid) return;
    try {
      await _functions
          .httpsCallable('deactivateDeviceToken')
          .call<void>({'deviceId': await _deviceId()});
    } on FirebaseFunctionsException {
      // Logout must not be blocked by a transient side-effect failure.
    }
  }

  Future<String> _deviceId() async {
    const key = 'bm_notification_device_id';
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final bytes = List<int>.generate(18, (_) => random.nextInt(256));
    final created = base64Url.encode(bytes).replaceAll('=', '');
    await preferences.setString(key, created);
    return created;
  }

  void _handleTap(RemoteMessage message) {
    final route = NotificationDeepLink.fromData(message.data);
    if (route != null) _deepLinks.add(route);
  }

  String _platformName() => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        _ => 'web',
      };

  NotificationPermissionState _toState(NotificationSettings settings) =>
      switch (settings.authorizationStatus) {
        AuthorizationStatus.authorized =>
          NotificationPermissionState.authorized,
        AuthorizationStatus.provisional =>
          NotificationPermissionState.provisional,
        AuthorizationStatus.denied => NotificationPermissionState.denied,
        AuthorizationStatus.notDetermined =>
          NotificationPermissionState.notDetermined,
      };

  @override
  void dispose() {
    _authSubscription?.cancel();
    _tokenSubscription?.cancel();
    _tapSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _deepLinks.close();
    _foreground.close();
  }
}

class UnavailableNotificationService implements NotificationService {
  UnavailableNotificationService();
  final _deepLinks = StreamController<String>.broadcast();
  final _foreground = StreamController<ForegroundNotification>.broadcast();
  @override
  Stream<String> get deepLinks => _deepLinks.stream;
  @override
  Stream<ForegroundNotification> get foregroundNotifications =>
      _foreground.stream;
  @override
  Future<void> deactivateCurrentDevice() async {}
  @override
  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.unavailable;
  @override
  Future<NotificationPermissionState> requestPermissionAndRegister() async =>
      NotificationPermissionState.unavailable;
  @override
  Future<void> start() async {}
  @override
  void dispose() {
    _deepLinks.close();
    _foreground.close();
  }
}

NotificationService createNotificationService() => Firebase.apps.isEmpty
    ? UnavailableNotificationService()
    : FirebaseNotificationService(FirebaseMessaging.instance,
        FirebaseFunctions.instance, FirebaseAuth.instance);
