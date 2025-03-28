import 'package:ahmini/services/constants.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../screens/mainScreen/main_screen.dart';
import '../notifactions/notification_settings.dart';

import '../../helper/CustomDialog/custom_dialog.dart';

import '../../services/auth.dart';

import '../../models/user.dart';

import '../../screens/theme/theme.dart';

class SettingsPage extends StatelessWidget {
  final bool? isLoggedIn;
  final GlobalKey<MainScreenState>? parentKey;
  late final UserModel? user;
  final ThemeController themeController = Get.find<ThemeController>();

  bool _isLoading = false;
  final String apiBaseUrl = '$httpURL/api';

  SettingsPage({
    super.key,
    this.isLoggedIn,
    this.parentKey,
  }) {
    user = Get.find<AppController>().user;
  }

  // Fonction pour vérifier si l'utilisateur a un portfolio
  Future<bool> _checkUserHasPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/portefolio/check/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasPortfolio'] ?? false;
      } else {
        print('Erreur lors de la vérification du portfolio: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la vérification du portfolio: $e');
      return false;
    }
  }

  // Fonction pour rediriger vers la page appropriée
  // Fonction pour rediriger vers la page appropriée
  Future<void> _navigateToPortfolioPage(BuildContext context) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final hasPortfolio = await _checkUserHasPortfolio();

      // Fermer l'indicateur de chargement
      Navigator.pop(context);

      if (hasPortfolio) {
        // Rediriger vers la page de modification du portfolio
        // Ne pas passer d'ID pour afficher le portfolio de l'utilisateur connecté
        Navigator.pushNamed(context, '/freelancer_portfolio');
      } else {
        // Rediriger vers la page de création du portfolio
        Navigator.pushNamed(
            context,
            '/portefolioedit',
            arguments: {'isFirstLogin': true}
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      Navigator.pop(context);

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la vérification du portfolio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {  // Wrap the entire build method with Obx()
      final isDark = themeController.isDarkMode.value;
      final bgColor = isDark ? darkPrimaryColor : primaryColor;
      final textColor = Colors.white;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: Text(
            'Paramètres'.tr,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: textColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Aide'.tr),
                    content: Text(
                        'Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0549819905'.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'.tr),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section with Avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgColor,
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: "profile_picture_hero",
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              color: isDark ? darkSecondaryColor : secondaryColor,
                            ),
                            child: user?.profilePicture?.isNotEmpty ?? false
                                ? ClipOval(
                              child: Image.network(
                                "http://$baseURL/$userAPI${user!.profilePicture!}",
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                    Text('Erreur de chargement'.tr),
                              ),
                            )
                                : Icon(Icons.person,
                                size: 50, color: Colors.black54),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child:
                              Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    if (user != null) ...[
                      Text(
                        "${user!.lastName} ${user!.firstName}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user!.email,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ]
                  ],
                ),
              ),

              // Settings Sections
              Container(
                decoration: BoxDecoration(
                  color: isDark ? darkBackgroundColor : backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Compte'.tr),
                    _buildSettingTile(
                        icon: Icons.person,
                        title: 'Modifier le profil'.tr,
                        subtitle: 'Modifiez vos informations personnelles'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/profile/edit'.tr);
                        }),
                    _buildSettingTile(
                        icon: Icons.notifications,
                        title: 'Modifier le compte'.tr,
                        subtitle: 'Modifier votre compte public et portefolio'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          // Utiliser la nouvelle fonction pour rediriger vers la page appropriée
                          _navigateToPortfolioPage(context);
                        }),

                    _buildSettingTile(
                        icon: Icons.dashboard,
                        title: 'Tableau de bord'.tr,
                        subtitle: 'Vue globale des offres d emplois'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/dashboard'.tr);
                        }),
                    _buildSettingTile(
                      icon: Icons.notifications,
                      title: 'Notifications'.tr,
                      subtitle: 'Gérez vos préférences de notification'.tr,
                      iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                      onTap: () {
                        Navigator.pushNamed(
                            context, NotificationSettingsPage.routeName);
                      },
                    ),
                    _buildSettingTile(
                        icon: Icons.lock_outline,
                        title: 'Confidentialité'.tr,
                        subtitle: 'Gérez la sécurité de votre compte'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/confidentialite'.tr);
                        }),
                    _buildSettingTile(
                        icon: Icons.description,
                        title: 'Contrats'.tr,
                        subtitle: 'Gérez vos contrats'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/contract/'.tr);
                        }),
                    _buildSettingTile(
                        icon: Icons.bar_chart,
                        title: 'Statistiques'.tr,
                        subtitle: 'Consultez vos statistiques d\'utilisation'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/profile/statistics'.tr);
                        }),

                    _buildSectionHeader('Abonnement'.tr),
                    _buildSettingTile(
                        icon: Icons.star,
                        title: 'Plan Premium'.tr,
                        subtitle: 'Gérez votre abonnement'.tr,
                        trailing: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ACTIF'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/subscription'.tr);
                        }),

                    _buildSectionHeader('Préférences'.tr),
                    _buildSettingTile(
                      icon: Icons.language,
                      title: 'Langue'.tr,
                      subtitle: 'Français'.tr,
                      iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                      onTap: () {
                        Navigator.pushNamed(context, '/language'.tr);
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.dark_mode,
                      title: 'Thème'.tr,
                      subtitle: themeController.isDarkMode.value
                          ? 'Mode sombre'.tr
                          : 'Mode clair'.tr,
                      iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ThemeSettingsPage())
                        );
                      },
                    ),

                    _buildSectionHeader('Support'.tr),
                    _buildSettingTile(
                        icon: Icons.help_outline,
                        title: 'Centre d\'aide'.tr,
                        subtitle: 'FAQ et guides'.tr,
                        iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/faq'.tr);
                        }),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: 'À propos'.tr,
                      subtitle: 'Version 1.0.0'.tr,
                      iconBgColor: isDark ? darkSecondaryColor : secondaryColor,
                    ),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            _handleLogout(context);
                          },
                          child: Text('Déconnexion'.tr),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          color: themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required Color iconBgColor,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: themeController.isDarkMode.value ? Colors.white : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: themeController.isDarkMode.value ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
      ),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16,
          color: themeController.isDarkMode.value ? Colors.white70 : Colors.black54),
      onTap: onTap,
    );
  }

  void _handleLogout(context) async {
    final dynamic success = await AuthService.logout();
    myCustomDialog(context, success);
    if (success['status'] == 'success'.tr) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login'.tr,
            (route) => false,
      );
    }
  }
}
