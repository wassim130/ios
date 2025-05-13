import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../services/auth_service.dart';
import '../services/constants.dart';

class NotificationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = true.obs;
  final RxBool messagesEnabled = true.obs;
  final RxBool subscriptionsEnabled = true.obs;
  final RxBool securityEnabled = true.obs;
  final RxBool contractsEnabled = true.obs;
  final RxBool adsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    if (!_authService.isLoggedIn) return;

    isLoading.value = true;
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notification/notification-settings/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final settings = data['settings'];
          messagesEnabled.value = settings['messages'] ?? true;
          subscriptionsEnabled.value = settings['subscriptions'] ?? true;
          securityEnabled.value = settings['security'] ?? true;
          contractsEnabled.value = settings['contracts'] ?? true;
          adsEnabled.value = settings['ads'] ?? true;
        }
      }
    } catch (e) {
      print('Error fetching notification settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSetting(String setting, bool value) async {
    if (!_authService.isLoggedIn) return;

    try {
      // Update local state immediately for better UX
      switch (setting) {
        case 'messages':
          messagesEnabled.value = value;
          break;
        case 'subscriptions':
          subscriptionsEnabled.value = value;
          break;
        case 'security':
          securityEnabled.value = value;
          break;
        case 'contracts':
          contractsEnabled.value = value;
          break;
        case 'ads':
          adsEnabled.value = value;
          break;
      }

      // Send update to server
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notification/notification-settings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          setting: value,
        }),
      );

      if (response.statusCode != 200) {
        // Revert local state if server update failed
        fetchSettings();
        Get.snackbar(
          'Error'.tr,
          'Failed to update settings'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error updating notification setting: $e');
      // Revert local state if there was an error
      fetchSettings();
      Get.snackbar(
        'Error'.tr,
        'Failed to update settings'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
