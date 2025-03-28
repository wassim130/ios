import 'dart:convert';

import 'package:ahmini/models/freelancer.dart';
import 'package:ahmini/services/constants.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/user.dart';
import 'components/entreprise_list.dart';
import 'components/filters.dart';
import 'components/freelancer_list.dart';
// import 'package:google_fonts/google_fonts.dart';

class ExploreScreen extends StatefulWidget {
  final bool? isLoggedIn;
  final GlobalKey? parentKey;
  const ExploreScreen({
    super.key,
    this.isLoggedIn,
    this.parentKey,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController();
  bool isEnterpriseActive = true;
  bool isSearchFocused = false;
  final TextEditingController searchController = TextEditingController();
  UserModel? user;
  GlobalKey<EntrepriseListState> entrepriseKey =
  GlobalKey<EntrepriseListState>();
  GlobalKey<FreelancerListState> freelancerKey =
  GlobalKey<FreelancerListState>();
  final ThemeController themeController = Get.find<ThemeController>();


  @override
  void initState() {
    super.initState();
    user = Get.find<AppController>().user;
  }


  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: Text(
            "Explore",
            style: TextStyle(color: Colors.white),
          ),
          // actions: [
          //   IconButton(
          //     icon: Stack(
          //       children: [
          //         Icon(Icons.notifications_outlined,
          //             color: Color.fromARGB(255, 255, 255, 255)),
          //         Positioned(
          //           right: 0,
          //           top: 0,
          //           child: Container(
          //             padding: EdgeInsets.all(2),
          //             decoration: BoxDecoration(
          //               color: primaryColor,
          //               borderRadius: BorderRadius.circular(6),
          //             ),
          //             constraints: BoxConstraints(
          //               minWidth: 12,
          //               minHeight: 12,
          //             ),
          //             child: Text(
          //               '2'.tr,
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 8,
          //               ),
          //               textAlign: TextAlign.center,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: isDark ? darkSecondaryColor.withOpacity(0.3) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSearchFocused
                    ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
                    : [],
              ),
              child: TextField(
                controller: searchController,
                onTap: () => setState(() => isSearchFocused = true),
                onSubmitted: (_) => setState(() => isSearchFocused = false),
                decoration: InputDecoration(
                  hintText: 'Rechercher un profil...'.tr,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  prefixIcon: Icon(
                      Icons.search,
                      color: primaryColorTheme
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () => searchController.clear(),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Tabs Section
            // _buildTabBar(context),

            // Suggestions Section
            if (searchController.text.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: isDark ? darkSecondaryColor.withOpacity(0.2) : Colors.grey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions populaires:'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildSuggestionChip('React Developer'.tr, isDark, primaryColorTheme),
                        _buildSuggestionChip('UI Designer'.tr, isDark, primaryColorTheme),
                        _buildSuggestionChip('Full Stack'.tr, isDark, primaryColorTheme),
                      ],
                    ),
                  ],
                ),
              ),

            // Filters Section
            Filter(
              listKey: user!.isEnterprise ? freelancerKey : entrepriseKey,
              isEnterprise: user!.isEnterprise,
            ),
            // _buildQuickFilterChip("test123", Icons.tab),
            if (user != null)
              Expanded(
                child: user!.isEnterprise
                    ? FreeLancerList(key:freelancerKey)
                    : EntrepriseList(key: entrepriseKey),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSuggestionChip(String label, bool isDark, Color primaryColorTheme) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onPressed: () {
        searchController.text = label;
      },
      backgroundColor: isDark ? darkSecondaryColor : Colors.white,
      side: BorderSide(color: isDark ? darkPrimaryColor.withOpacity(0.3) : Colors.grey.shade300),
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon) {
    final isDark = themeController.isDarkMode.value;
    final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColorTheme),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      selected: false,
      onSelected: (selected) {
        // Implement filter logic
      },
      backgroundColor: isDark ? darkSecondaryColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? darkPrimaryColor.withOpacity(0.3) : Colors.grey.shade300),
      ),
    );
  }
}

