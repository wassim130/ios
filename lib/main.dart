import 'package:ahmini/services/auth_service.dart';
import 'package:ahmini/services/notifservices.dart';
import 'package:get/get.dart';
import 'app.dart';
import 'package:flutter/material.dart';
import 'controllers/app_controller.dart';
import 'controllers/theme_controller.dart';
import 'package:get_storage/get_storage.dart';


void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage before using it
  await GetStorage.init();

  // Initialize services
  await initServices();

  // Initialize controllers
  Get.put(AppController());
  Get.put(ThemeController());

  runApp(MyApp());
}

Future<void> initServices() async {
  // Initialize auth service
  await Get.putAsync(() => AuthService().init());

  // Initialize notification service
  await Get.putAsync(() => NotificationService().init());
}
