import 'package:get/get.dart';
import 'app.dart';
import 'package:flutter/material.dart';
import 'controllers/app_controller.dart';
import 'controllers/theme_controller.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  // Initialiser GetStorage avant de l'utiliser
  await GetStorage.init();

  // Initialiser les contrôleurs
  Get.put(AppController());
  Get.put(ThemeController());

  runApp(MyApp());
}