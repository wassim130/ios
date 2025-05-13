import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../admin/admin.dart';
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
      final data = jsonDecode(prefs.getString('user') ?? 'null');
      if (data != null) {
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
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } else {
      user = await AuthService.getUser();
      prefs.setString('user', jsonEncode(user!.toMap()));
      saveUserInMemory();
      if (mounted) {
        setState(() {});
      }
    }
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
          HomePage(parentKey: widget.key,user:user),
          ExploreScreen(key:UniqueKey(),isLoggedIn: isLoggedIn,user:user),
          SettingsPage(isLoggedIn: isLoggedIn, user: user),
          AdminPage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        pageIndex: currentPage,
        pageController: _pageController,
        user:user,
      ),
    );
  }
}
