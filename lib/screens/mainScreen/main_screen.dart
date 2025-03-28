import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../bottom_bar/bottom_bar.dart';
import '../explore/main_explore.dart';
import '../home_page/home_page.dart';
import '../settings/settings.dart';

import '../../services/auth.dart';

import '../../models/user.dart';

class MainScreen extends StatefulWidget {
  @override
  final GlobalKey<MainScreenState>? key;
  final UserModel? user;
  const MainScreen({required this.key, required this.user});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  final int currentPage = 0;
  UserModel? user;
  bool? isLoggedIn;

  @override
  void initState() {
    if (widget.user == null) {
      _checkIfUserIsLoggedIn();
    } else {
      print("got user from login or registation page");
      user = widget.user;
      isLoggedIn = true;
      saveUserInMemory();
    }
    super.initState();
  }

  void _checkIfUserIsLoggedIn() async {
    isLoggedIn = await AuthService.isLoggedIn();
    final prefs = await SharedPreferences.getInstance();
    if (isLoggedIn == null) {
      final data = jsonDecode(prefs.getString('user'.tr) ?? 'null'.tr);
      if (data != null) {
        print("user in local storage getting it ...");
        user = UserModel.fromMap(data);
        saveUserInMemory();
        if (mounted) {
          setState(() {});
        }
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text("Offline Mode"),
          content: Text(
              """Connection to the server failed.\nOffline mode activated. please check your internet connection and try again later. If you need help, please contact support.
               """),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("close"),
            ),
          ],
        ),
      );
      return;
    }
    if (!isLoggedIn!) {
      print("Not logged in");
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login'.tr, (route) => false);
      }
    } else {
      print("Logged in getting user from database");
      user = await AuthService.getUser();
      prefs.setString('user'.tr, jsonEncode(user!.toMap()));
      saveUserInMemory();
      print("Saved user in local storage");
      if (mounted) {
        setState(() {});
      }
    }
    String device = await getDeviceName();
    print(device);
  }

  void saveUserInMemory() {
    final controller = Get.find<AppController>();
    controller.user = user;
    controller.mainScreenKey = widget.key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomePage(parentKey: widget.key),
          ExploreScreen(isLoggedIn: isLoggedIn, parentKey: widget.key),
          SettingsPage(isLoggedIn: isLoggedIn, parentKey: widget.key),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        pageIndex: currentPage,
        pageController: _pageController,
      ),
    );
  }
}
