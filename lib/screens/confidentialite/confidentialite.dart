import 'dart:convert';
import 'dart:ffi';
import 'package:ahmini/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahmini/screens/confidentialite/changemdp/changermdp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../controllers/app_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/user.dart';
import '../../services/auth.dart';
import '../../services/user.dart';

final String apiBaseUrl = 'http://10.0.2.2:8000';

class SecurityPrivacyScreen extends StatefulWidget {
  late final UserModel user;
  SecurityPrivacyScreen({super.key}) {
    user = Get.find<AppController>().user!;
  }

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  String activeDevices = "", lastConnection = "";
  bool two_factor_enabled = false;
  bool privateMode = false;
  final ThemeController themeController = Get.find<ThemeController>();
  // Security score calculation variables
  int securityScore = 0;
  String securityLevel = "";

  @override
  void initState() {
    myInitState();
    super.initState();
  }

  String formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return "Dernière connexion: Aujourd'hui at ${DateFormat('HH:mm'.tr).format(dateTime)}";
    } else if (dateOnly == yesterday) {
      return "Dernière connexion: Hier ${DateFormat('HH:mm'.tr).format(dateTime)}";
    } else {
      return "Dernière connexion: ${DateFormat('yyyy MMMM dd'.tr).format(dateTime)}";
    }
  }

  // Calculate security score based on A2F and password age
  void calculateSecurityScore() {
    securityScore = 0;

    // Add points for A2F
    if (two_factor_enabled) {
      securityScore += 40;
    }

    // Add points based on password age
    if (widget.user.lastPasswordChange < 60 * 24) {
      // Password changed within last day
      securityScore += 40;
    } else if (widget.user.lastPasswordChange < 60 * 24 * 30) {
      // Password changed within last month
      securityScore += 25;
    } else {
      // Password older than a month
      securityScore += 10;
    }

    // Add base points for having an account
    securityScore += 20;

    // Determine security level text
    if (securityScore >= 80) {
      securityLevel = 'Votre compte est très sécurisé'.tr;
    } else if (securityScore >= 60) {
      securityLevel = 'Votre compte est modérément sécurisé'.tr;
    } else {
      securityLevel = 'Votre compte présente des risques '.tr;
    }
  }

  void myInitState() async {
    final data = await AuthService.confidentialite();
    if (data == null) {
      return;
    }
    if (data['type'] == "success") {
      activeDevices = data['content']['devices_connected'].toString();
      lastConnection =
          formatLastSeen(DateTime.parse(data['content']['last_connection']));
      two_factor_enabled = data['content']['two_factor_enabled'];
      privateMode = data['content']['private_mode'];
      // Calculate security score after getting data
      calculateSecurityScore();
      setState(() {});
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(data['message']),
          content: Text('Error fetching data from the server'.tr),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme =
          isDark ? darkBackgroundColor : backgroundColor;
      final textColor = isDark ? Colors.white : Colors.black;
      final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: Text(
            'Sécurité & Confidentialité'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        secondaryColorTheme,
                        isDark ? Colors.grey[800]! : Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Score de Sécurité'.tr,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                securityLevel,
                                style: TextStyle(
                                  color: textColorSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 60,
                            width: 40,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$securityScore%'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColorTheme,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: securityScore / 100,
                          backgroundColor:
                              isDark ? Colors.grey[700] : Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColorTheme,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points à améliorer'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 15),
                    // Only show A2F warning if it's disabled
                    if (!two_factor_enabled)
                      _buildSecurityIssueCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Authentification à deux facteurs désactivée'.tr,
                        description:
                            'Activez-la pour une sécurité renforcée'.tr,
                        severity: 'Élevé'.tr,
                        severityColor: Colors.red,
                        action: 'Activer'.tr,
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                      ),
                    _buildSecurityIssueCard(
                      icon: Icons.lock_clock,
                      title: 'Mot de passe ancien'.tr,
                      description:
                          'Dernier changement il y a ${(widget.user.lastPasswordChange / 60 / 24).toInt()} jour'
                              .tr,
                      severity: widget.user.lastPasswordChange < 60 * 24
                          ? "Pas de risque"
                          : widget.user.lastPasswordChange < 60 * 24 * 30
                              ? 'Moyen'
                              : "Élevé",
                      severityColor: widget.user.lastPasswordChange < 60 * 24
                          ? Colors.green
                          : widget.user.lastPasswordChange < 60 * 24 * 30
                              ? Colors.orange
                              : Colors.red,
                      action: 'Changer'.tr,
                      isDark: isDark,
                      primaryColorTheme: primaryColorTheme,
                      onTap: () {
                        Navigator.pushNamed(
                            context, '/confidentialite/changemdp'.tr);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions de sécurité'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildSecurityActionCard(
                      context,
                      icon: Icons.password,
                      title: 'Changer le mot de passe'.tr,
                      subtitle:
                          "Dernier modification il y a ${(widget.user.lastPasswordChange / 60 / 24).toInt()} jour",
                      onTap: () {
                        Navigator.pushNamed(
                            context, "/confidentialite/changemdp");
                      },
                      isDark: isDark,
                      primaryColorTheme: primaryColorTheme,
                      secondaryColorTheme: secondaryColorTheme,
                    ),
                    _buildSecurityActionCard(
                      context,
                      icon: Icons.phone_android,
                      title: 'Authentification à deux facteurs'.tr,
                      subtitle:
                          two_factor_enabled ? 'Activée'.tr : 'Non activée'.tr,
                      isToggle: true,
                      isDark: isDark,
                      primaryColorTheme: primaryColorTheme,
                      secondaryColorTheme: secondaryColorTheme,
                    ),
                    _buildSecurityActionCard(
                      context,
                      icon: Icons.security,
                      title: 'Vérification des appareils connectés'.tr,
                      subtitle: '$activeDevices appareils actifs'.tr,
                      onTap: () {
                        Navigator.pushNamed(
                            context, "/confidentialite/connected_devices");
                      },
                      isDark: isDark,
                      primaryColorTheme: primaryColorTheme,
                      secondaryColorTheme: secondaryColorTheme,
                    ),
                    _buildSecurityActionCard(
                      context,
                      icon: Icons.history,
                      title: 'Historique des connexions'.tr,
                      subtitle: lastConnection,
                      onTap: () {
                        Navigator.pushNamed(
                            context, "/confidentialite/login_history");
                      },
                      isDark: isDark,
                      primaryColorTheme: primaryColorTheme,
                      secondaryColorTheme: secondaryColorTheme,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: secondaryColorTheme,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paramètres de confidentialité'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 11),
                      _buildPrivacyToggle(
                        'Notifications de connexion'.tr,
                        'Recevoir une alerte lors d\'une nouvelle connexion'.tr,
                        true,
                        () {},
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                        textColor: textColor,
                        textColorSecondary: textColorSecondary,
                      ),
                      _buildPrivacyToggle(
                        'Mode privé'.tr,
                        'Masquer votre statut en ligne'.tr,
                        privateMode,
                        (value) async {
                          final s = await UserService.updateProfile(
                              {'private_mode': value});
                          if (s['status'] == 'success') {
                            privateMode = value;
                            setState(() {});
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                s['status'] == 'success'
                                    ? 'mise a jour de mode prive avec success'
                                        .tr
                                    : "Erreur dans la modification de status"
                                        .tr,
                              ),
                              backgroundColor: s['status'] == 'success'
                                  ? Colors.green
                                  : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                        textColor: textColor,
                        textColorSecondary: textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withOpacity(isDark ? 0.4 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Conseil de sécurité'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Utilisez un gestionnaire de mots de passe pour créer et stocker des mots de passe forts et uniques pour chacun de vos comptes.'
                            .tr,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSecurityIssueCard({
    required IconData icon,
    required String title,
    required String description,
    required String severity,
    required Color severityColor,
    required String action,
    required bool isDark,
    required Color primaryColorTheme,
    Function? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: severityColor),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Risque $severity'.tr,
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (onTap != null) {
                onTap();
              }
            },
            child: Text(
              action,
              style: TextStyle(
                color: primaryColorTheme,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isToggle = false,
    VoidCallback? onTap,
    required bool isDark,
    required Color primaryColorTheme,
    required Color secondaryColorTheme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: isToggle ? null : onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColorTheme,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryColorTheme,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: isToggle
            ? Switch(
                value: two_factor_enabled,
                onChanged: (value) async {
                  try {
                    // Get shared preferences to retrieve tokens
                    final prefs = await SharedPreferences.getInstance();
                    final sessionCookie = prefs.getString('session_cookie'.tr);
                    String? csrfToken = prefs.getString('csrf_token'.tr);
                    String? csrfCookie = prefs.getString('csrf_cookie'.tr);

                    // If tokens are missing, get them
                    if (csrfCookie == null || csrfToken == null) {
                      final temp = await AuthService.getCsrf();
                      csrfToken = temp['csrf_token'];
                      csrfCookie = temp['csrf_cookie'];
                    }

                    // Appel à l'API pour activer/désactiver l'A2F
                    final response = await http.post(
                      Uri.parse('${apiBaseUrl}/api/auth/toggle-two-factor/'.tr),
                      headers: {
                        'Content-Type': 'application/json'.tr,
                        'Cookie':
                            "sessionid=$sessionCookie;csrftoken=$csrfCookie",
                        'X-CSRFToken': csrfToken!,
                      },
                      body: jsonEncode({'enable': value}),
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      if (data['status'] == 'success'.tr) {
                        // Mettre à jour l'état local
                        setState(() {
                          two_factor_enabled = value;
                          widget.user.twoFactorEnabled = value;
                          // Recalculate security score
                          calculateSecurityScore();
                        });

                        // Mettre à jour l'utilisateur dans le contrôleur global
                        Get.find<AppController>().updateUser(widget.user);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Authentification à deux facteurs ${value ? 'activée' : 'désactivée'} avec succès.'
                                    .tr),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        throw Exception(data['message'] ??
                            'Erreur lors de la modification de l\'A2F'.tr);
                      }
                    } else {
                      final data = jsonDecode(response.body);
                      throw Exception(data['content']['message'] ??
                          'Erreur lors de la modification de l\'A2F'.tr);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'.tr),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Réinitialiser le switch à son état précédent
                    setState(() {});
                  }
                },
                activeColor: primaryColorTheme,
              )
            : Icon(Icons.arrow_forward_ios,
                size: 16, color: isDark ? Colors.white70 : Colors.grey),
      ),
    );
  }

  Widget _buildPrivacyToggle(
    String title,
    String subtitle,
    bool initialValue,
    Function callBack, {
    required bool isDark,
    required Color primaryColorTheme,
    required Color textColor,
    required Color textColorSecondary,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColorSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (value) {
              callBack(value);
            },
            activeColor: primaryColorTheme,
          ),
        ],
      ),
    );
  }
}
