import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../../models/user.dart';
import 'components/entreprise_list.dart';
import 'components/filters.dart';
import 'components/freelancer_list.dart';
import 'components/search_bar.dart';
// import 'package:google_fonts/google_fonts.dart';


class ExploreScreen extends StatefulWidget {
  final bool? isLoggedIn;
  final UserModel? user;
  const ExploreScreen({
    super.key,
    this.isLoggedIn,
    this.user,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController();
  bool isEnterpriseActive = true;
  final TextEditingController searchController = TextEditingController();
  UserModel? user;
  GlobalKey<EntrepriseListState> entrepriseKey =
      GlobalKey<EntrepriseListState>();
  GlobalKey<FreelancerListState> freelancerKey =
      GlobalKey<FreelancerListState>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    user = widget.user;
    super.initState();
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
      final backgroundColorTheme =
          isDark ? darkBackgroundColor : backgroundColor;

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
            if (user != null)
            SizedBox(height: 10,),
              ExploreSearchBar(
                searchController: searchController,
                listKey: user!.isEnterprise ? freelancerKey : entrepriseKey,
                isEntreprise: user!.isEnterprise,
                isDark: isDark,
              ),
              // Tabs Section
            // _buildTabBar(context),

            // // Suggestions Section
            //TODO : IF WE HAVE EXTRA TIME DO THIS
            // if (searchController.text.isNotEmpty)
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     color: isDark ? darkSecondaryColor.withOpacity(0.2) : Colors.grey.shade50,
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Suggestions populaires:'.tr,
            //           style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             color: isDark ? Colors.white : Colors.grey.shade700,
            //           ),
            //         ),
            //         Wrap(
            //           spacing: 8,
            //           children: [
            //             _buildSuggestionChip('React Developer'.tr, isDark, primaryColorTheme),
            //             _buildSuggestionChip('UI Designer'.tr, isDark, primaryColorTheme),
            //             _buildSuggestionChip('Full Stack'.tr, isDark, primaryColorTheme),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            
            // Filters Section
            if (user != null)
              Filter(
                listKey: user!.isEnterprise ? freelancerKey : entrepriseKey,
                isEnterprise: user!.isEnterprise,
              ),
            // _buildQuickFilterChip("test123", Icons.tab),
            // _buildSuggestionChip("test", isDark, primaryColorTheme),
            if (user != null)
              Expanded(
                child: user!.isEnterprise
                    ? FreeLancerList(key: freelancerKey)
                    : EntrepriseList(key: entrepriseKey),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSuggestionChip(
      String label, bool isDark, Color primaryColorTheme) {
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
      side: BorderSide(
          color: isDark
              ? darkPrimaryColor.withOpacity(0.3)
              : Colors.grey.shade300),
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
        side: BorderSide(
            color: isDark
                ? darkPrimaryColor.withOpacity(0.3)
                : Colors.grey.shade300),
      ),
    );
  }
}
