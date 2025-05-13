import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahmini/theme.dart';
import '../../controllers/theme_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum NotificationType {
  messages,
  subscriptions,
  security,
  contracts,
  ads,
}

class NotificationSettingsPage extends StatefulWidget {
  static const String routeName = '/notifications/settings';

  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late ThemeController themeController;
  Map<NotificationType, bool> notificationSettings = {
    NotificationType.messages: true,
    NotificationType.subscriptions: true,
    NotificationType.security: true,
    NotificationType.contracts: true,
    NotificationType.ads: true,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final csrfToken = prefs.getString('csrf_token');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/notification/notification-settings/'),
        headers: {
          'Cookie': sessionCookie != null ? "sessionid=$sessionCookie" : "",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notificationSettings[NotificationType.messages] = data['settings']['messages'] ?? true;
          notificationSettings[NotificationType.subscriptions] = data['settings']['subscriptions'] ?? true;
          notificationSettings[NotificationType.security] = data['settings']['security'] ?? true;
          notificationSettings[NotificationType.contracts] = data['settings']['contracts'] ?? true;
          notificationSettings[NotificationType.ads] = data['settings']['ads'] ?? true;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading settings: $e');
    }
  }

  Future<void> _updateNotificationSetting(NotificationType type, bool value) async {
    setState(() {
      notificationSettings[type] = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final csrfToken = prefs.getString('csrf_token');
      final csrfCookie = prefs.getString('csrf_cookie');

      final payload = {
        'messages': notificationSettings[NotificationType.messages],
        'subscriptions': notificationSettings[NotificationType.subscriptions],
        'security': notificationSettings[NotificationType.security],
        'contracts': notificationSettings[NotificationType.contracts],
        'ads': notificationSettings[NotificationType.ads],
      };

      final headers = {
        'Content-Type': 'application/json',
      };

      if (sessionCookie != null) {
        headers['Cookie'] = "sessionid=$sessionCookie";
        if (csrfCookie != null) {
          headers['Cookie'] = "${headers['Cookie']}; csrftoken=$csrfCookie";
        }
      }

      if (csrfToken != null) {
        headers['X-CSRFToken'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/notification/notification-settings/'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        // Revert if update fails
        setState(() {
          notificationSettings[type] = !value;
        });
        Get.snackbar(
          'Error',
          'Failed to update notification settings: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        notificationSettings[type] = !value;
      });
      Get.snackbar(
        'Error',
        'Failed to update notification settings: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final textColor = isDark ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          title: Text('Notifications'.tr,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_sharp, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Notifications Settings'.tr),
                    content: Text('Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0542794170'.tr),
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Gérez les notifications",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choisissez quelles notifications vous souhaitez recevoir",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: _buildSettingsList(isDark, textColor),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettingsList(bool isDark, Color textColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Messages", isDark),
          _buildNotificationSwitch(
            "Messages",
            "Recevoir des notifications pour les nouveaux messages",
            NotificationType.messages,
            isDark,
          ),
          _buildSectionHeader("Abonnements", isDark),
          _buildNotificationSwitch(
            "Abonnements",
            "Recevoir des notifications concernant votre abonnement",
            NotificationType.subscriptions,
            isDark,
          ),
          _buildSectionHeader("Sécurité", isDark),
          _buildNotificationSwitch(
            "Sécurité",
            "Recevoir des notifications de sécurité importantes",
            NotificationType.security,
            isDark,
          ),
          _buildSectionHeader("Contrats", isDark),
          _buildNotificationSwitch(
            "Contrats",
            "Recevoir des notifications concernant vos contrats",
            NotificationType.contracts,
            isDark,
          ),
          _buildSectionHeader("Publicité", isDark),
          _buildNotificationSwitch(
            "Publicité",
            "Recevoir des offres promotionnelles et publicitaires",
            NotificationType.ads,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch(
      String title,
      String subtitle,
      NotificationType type,
      bool isDark,
      ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      value: notificationSettings[type] ?? true,
      onChanged: (value) => _updateNotificationSetting(type, value),
      activeColor: primaryColor,
      inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}