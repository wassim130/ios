import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../screens/mainScreen/main_screen.dart';
import '../screens/messages/chat_page/components/app_bar.dart';

class AppController extends GetxController {
  UserModel? user;
  GlobalKey<MainScreenState>? mainScreenKey;
  GlobalKey<OnlineStatusState>? chatAppBarKey;

  // In app_controller.dart
  void updateUser(UserModel user) {
    this.user = user;
    update();
  }
}