import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../models/user.dart';

class BottomNavBar extends StatefulWidget {
  final int pageIndex;
  final PageController pageController;
  final UserModel? user;
  const BottomNavBar({
    super.key,
    required this.pageIndex,
    required this.pageController,
    required this.user,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int pageIndex;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    pageIndex = widget.pageIndex;
  }

  void _handlePress(int index) {
    if (pageIndex == index) return;
    if (widget.user == null || widget.user!.isNew) {
      return;
    }
    widget.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    pageIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilt");
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : Colors.white;

      return Container(
        decoration: BoxDecoration(
          color: backgroundColorTheme,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: backgroundColorTheme,
          selectedItemColor: primaryColorTheme,
          unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
          currentIndex: pageIndex,
          onTap: (index) {
            _handlePress(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(widget.user == null || widget.user!.isNew
                  ? Icons.lock
                  : Icons.explore),
              label: 'Explorer'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(widget.user == null || widget.user!.isNew
                  ? Icons.lock
                  : Icons.person),
              label: 'Compte'.tr,
            ),
            if (widget.user?.isSuperUser ?? false)
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Admin'.tr,
              ),
          ],
        ),
      );
    });
  }
}
