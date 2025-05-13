import 'package:ahmini/helper/CustomDialog/loading_indicator.dart';
import 'package:ahmini/services/constants.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../controllers/theme_controller.dart';
import '../notifactions/notification_settings.dart';

import '../../helper/CustomDialog/custom_dialog.dart';

import '../../services/auth.dart';

import '../../models/user.dart';

import '../../screens/theme/theme.dart';

class SettingsPage extends StatefulWidget {
  final bool? isLoggedIn;
  final UserModel? user;
  const SettingsPage({
    super.key,
    this.isLoggedIn,
    this.user,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeController themeController = Get.find<ThemeController>();
  final String apiBaseUrl = '$httpURL/api';

  bool _isLoading = false;
  bool hasSubscription = false;
  String? currentPlan;
  DateTime? startDate;
  DateTime? endDate;
  bool isSubscriptionActive = false;

  @override
  void initState() {
    super.initState();
    fetchUserSubscription();
  }

  Future<void> fetchUserSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/payment/user-subscriptions/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          hasSubscription = data['has_subscription'] ?? false;
          currentPlan = "";
          isSubscriptionActive = false;

          if (data['subscription'] != null) {
            currentPlan = data['subscription']['plan_type'] ?? "";
            isSubscriptionActive = data['subscription']['is_active'] ?? false;

            if (data['subscription']['start_date'] != null) {
              startDate = DateTime.parse(data['subscription']['start_date']);
            }
            if (data['subscription']['end_date'] != null) {
              endDate = DateTime.parse(data['subscription']['end_date']);
            }
          }
        });
      }
    } catch (e) {
      print('Exception lors de la récupération de l\'abonnement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getSubscriptionStatus() {
    if (!hasSubscription) return "INACTIF";
    if (endDate == null) return "INACTIF";

    final now = DateTime.now();
    if (endDate!.isBefore(now)) {
      return "EXPIRÉ";
    } else {
      return "ACTIF";
    }
  }

  Color _getStatusColor() {
    final status = _getSubscriptionStatus();
    if (status == "ACTIF") return Colors.green;
    if (status == "EXPIRÉ") return Colors.orange;
    return Colors.grey;
  }

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
        print(
            'Erreur lors de la vérification du portfolio: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la vérification du portfolio: $e');
      return false;
    }
  }

  Future<void> _navigateToPortfolioPage(BuildContext context) async {
    if (widget.user == null) return;
    myCustomLoadingIndicator(context);

    try {
      final hasPortfolio = await _checkUserHasPortfolio();
      if (mounted) {
        Navigator.pop(context);
        if (!hasPortfolio) {
          if (widget.user!.isEnterprise) {
            Navigator.pushNamed(context, '/entreprise/create');
          } else {
            Navigator.pushNamed(context, '/freelancer_portfolio');
          }
        } else {
          if (widget.user!.isEnterprise) {
            Navigator.pushNamed(context, '/entreprise/home');
          } else {
            Navigator.pushNamed(context, '/portefolioedit',
                arguments: {'isFirstLogin': true});
          }
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la vérification du portfolio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                        'Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0549819905'
                            .tr),
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
                              color:
                                  isDark ? darkSecondaryColor : secondaryColor,
                            ),
                            child: widget.user?.profilePicture?.isNotEmpty ??
                                    false
                                ? ClipOval(
                                    child: Image.network(
                                      "http://$baseURL/$userAPI${widget.user!.profilePicture!}",
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
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    if (widget.user != null) ...[
                      Text(
                        "${widget.user!.lastName} ${widget.user!.firstName}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.user!.email,
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
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/profile/edit'.tr);
                        }),
                    _buildSettingTile(
                        icon: Icons.notifications,
                        title: 'Modifier le compte'.tr,
                        subtitle: widget.user == null
                            ? ""
                            : widget.user!.isEnterprise
                                ? 'Modifier les coordonnées de votre entreprise'.tr
                                : 'Modifier votre compte public et portefolio'
                                    .tr,
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          _navigateToPortfolioPage(context);
                        }),

                    _buildSettingTile(
                        icon: Icons.dashboard,
                        title: 'Tableau de bord'.tr,
                        subtitle: 'Vue globale des offres d emplois'.tr,
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
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
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/confidentialite'.tr);
                        }),
                    _buildSettingTile(
                        icon: Icons.description,
                        title: 'Contrats'.tr,
                        subtitle: 'Gérez vos contrats'.tr,
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/contract/'.tr);
                        }),
                    _buildSettingTile(
                        icon: Icons.bar_chart,
                        title: 'Statistiques'.tr,
                        subtitle:
                            'Consultez vos statistiques d\'utilisation'.tr,
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/profile/statistics'.tr);
                        }),

                    _buildSectionHeader('Abonnement'.tr),
                    _buildSettingTile(
                        icon: Icons.star,
                        title: currentPlan == null
                            ? ""
                            : currentPlan!.isNotEmpty
                                ? currentPlan!
                                : 'Aucun abonnement'.tr,
                        subtitle: hasSubscription && endDate != null
                            ? 'Expire le ${DateFormat('dd/MM/yyyy').format(endDate!)}'
                            : 'Gérez votre abonnement'.tr,
                        trailing: currentPlan == null
                            ? CircularProgressIndicator(
                                color: isDark ? darkPrimaryColor : primaryColor)
                            : Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getSubscriptionStatus().tr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
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
                            MaterialPageRoute(
                                builder: (context) => ThemeSettingsPage()));
                      },
                    ),

                    _buildSectionHeader('Support'.tr),
                    _buildSettingTile(
                        icon: Icons.help_outline,
                        title: 'Centre d\'aide'.tr,
                        subtitle: 'FAQ et guides'.tr,
                        iconBgColor:
                            isDark ? darkSecondaryColor : secondaryColor,
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
          color: themeController.isDarkMode.value
              ? Colors.white70
              : Colors.black54,
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
        child: Icon(icon,
            color: themeController.isDarkMode.value
                ? Colors.white
                : Colors.black87),
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
          color: themeController.isDarkMode.value
              ? Colors.white70
              : Colors.black54,
          fontSize: 14,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios,
              size: 16,
              color: themeController.isDarkMode.value
                  ? Colors.white70
                  : Colors.black54),
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
