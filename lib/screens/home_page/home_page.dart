import 'package:ahmini/services/auth.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/user.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/theme_controller.dart';

class HomePage extends StatelessWidget {
  final GlobalKey? parentKey;
  UserModel? user;
  final ThemeController themeController = Get.find<ThemeController>();

  HomePage({
    super.key,
    this.parentKey,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    user = controller.user;

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: const Text(
            'Ahmini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: user == null
              ? []
              : [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications/'.tr);
              },
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/messages/home'.tr);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${user?.firstName ?? ''} 👋'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vos données sont en sécurité'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Security Status Card
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: secondaryColorTheme,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.shield, color: Colors.white),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Statut de Protection'.tr,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Toutes vos données sont protégées'.tr,
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quick Actions
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actions Rapides'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickActionButton(
                                icon: Icons.description,
                                label: 'Nouveau\nContrat'.tr,
                                onTap: () {},
                                secondaryColor: secondaryColorTheme,
                                isDark: isDark,
                              ),
                              _buildQuickActionButton(
                                icon: Icons.verified_user,
                                label: 'Vérifier\nStatut'.tr,
                                onTap: () {},
                                secondaryColor: secondaryColorTheme,
                                isDark: isDark,
                              ),
                              _buildQuickActionButton(
                                icon: Icons.security,
                                label: 'Scanner\nMenaces'.tr,
                                onTap: () {},
                                secondaryColor: secondaryColorTheme,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Active Contracts
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contrats Actifs'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 15),
                          _buildContractCard(
                            company: 'Tech Solutions Inc.'.tr,
                            status: 'En cours'.tr,
                            date: '15 Feb 2025'.tr,
                            amount: '45,000 DA'.tr,
                            progress: 0.7,
                            secondaryColor: secondaryColorTheme,
                            primaryColor: primaryColorTheme,
                            isDark: isDark,
                          ),
                          SizedBox(height: 10),
                          _buildContractCard(
                            company: 'Digital Agency SARL'.tr,
                            status: 'En attente'.tr,
                            date: '20 Feb 2025'.tr,
                            amount: '30,000 DA'.tr,
                            progress: 0.3,
                            secondaryColor: secondaryColorTheme,
                            primaryColor: primaryColorTheme,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    // Security Tips
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: secondaryColorTheme,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conseil du Jour'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Activez l\'authentification à deux facteurs pour une sécurité renforcée de votre compte.'.tr,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                              },
                              child: Text('Activer maintenant'.tr),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColorTheme,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color secondaryColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: isDark ? Colors.white70 : Colors.black87),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard({
    required String company,
    required String status,
    required String date,
    required String amount,
    required double progress,
    required Color secondaryColor,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                company,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'En cours' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white24 : Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

