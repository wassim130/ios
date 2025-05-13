import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'notifservices.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final RxBool _isLoggedIn = false.obs;

  bool get isLoggedIn => _isLoggedIn.value;

  Future<AuthService> init() async {
    // Check if user is logged in
    final token = _storage.read('token');
    _isLoggedIn.value = token != null;

    return this;
  }

  Future<String?> getToken() async {
    return _storage.read('token');
  }

  Future<void> login(String token, String userId) async {
    await _storage.write('token', token);
    await _storage.write('user_id', userId);
    _isLoggedIn.value = true;

    // Set external user ID for OneSignal
    final notificationService = Get.find<NotificationService>();
    await notificationService.setExternalUserId(userId);
  }

  Future<void> logout() async {
    // Clear external user ID from OneSignal
    final notificationService = Get.find<NotificationService>();
    await notificationService.removeExternalUserId();

    // Clear local storage
    await _storage.remove('token');
    await _storage.remove('user_id');
    _isLoggedIn.value = false;
  }
}

