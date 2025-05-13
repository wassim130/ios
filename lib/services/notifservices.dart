import 'dart:convert';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../services/auth_service.dart';

class NotificationService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  Future<NotificationService> init() async {
    // Initialize OneSignal with the correct API
    OneSignal.initialize('9553a858-c50a-4e3d-b381-6b92214bc882');

    // Enable debug logs
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Request permission
    OneSignal.Notifications.requestPermission(true);

    // Set notification opened handler
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
      // Handle notification click
      final data = event.notification.additionalData;
      if (data != null && data.containsKey('notification_id')) {
        final notificationId = data['notification_id'];
        // Navigate to notification details
        Get.toNamed('/notifications/details', arguments: {'id': notificationId});
      }
    });

    // Set notification will show in foreground handler
    OneSignal.Notifications.addForegroundWillDisplayListener((OSNotificationWillDisplayEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display the notification while the app is in the foreground
      event.notification.display();
    });

    // Get device state and register with backend
    final deviceState = await OneSignal.User.pushSubscription.id;
    if (deviceState != null) {
      await _registerDeviceWithBackend(deviceState);
    }

    return this;
  }

  Future<void> _registerDeviceWithBackend(String playerId) async {
    if (!_authService.isLoggedIn) return;

    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notification/register-device/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'player_id': playerId,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to register device: ${response.body}');
      }
    } catch (e) {
      print('Error registering device: $e');
    }
  }

  // Method to handle external user ID (call after login)
  Future<void> setExternalUserId(String userId) async {
    OneSignal.login(userId);
  }

  // Method to clear external user ID (call after logout)
  Future<void> removeExternalUserId() async {
    OneSignal.logout();
  }
}