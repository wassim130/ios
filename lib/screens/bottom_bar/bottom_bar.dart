import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class BottomNavBar extends StatefulWidget {
  final int pageIndex;
  final PageController pageController;
  const BottomNavBar({
    super.key,
    required this.pageIndex,
    required this.pageController,
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

  @override
  Widget build(BuildContext context) {
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
            if (pageIndex == index) return;
            if (index == 0) {
              widget.pageController.animateToPage(
                widget.pageController.initialPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }else if (index == 2){
              widget.pageController.animateToPage(
                widget.pageController.initialPage + 2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            else if (pageIndex < index) {
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else if (pageIndex > index) {
              widget.pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            pageIndex = index;
            setState(() {});
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explorer'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Compte'.tr,
            ),
          ],
        ),
      );
    });
  }
}

