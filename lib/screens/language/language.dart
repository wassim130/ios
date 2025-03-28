import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/theme_controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Map language names to locale codes
  final Map<String, Locale> _languageLocales = {
    'Français': const Locale('fr', 'FR'),
    'English': const Locale('en', 'US'),
    'العربية': const Locale('ar', 'SA'),
  };

  String _selectedLanguage = 'Français';
  final ThemeController themeController = Get.find<ThemeController>();

  final List<String> _languages = [
    'Français',
    'English'.tr,
    'العربية'.tr,
  ];

  @override
  void initState() {
    super.initState();
    // Set initial selected language based on current locale
    final currentLocale = Get.locale;
    if (currentLocale != null) {
      for (var entry in _languageLocales.entries) {
        if (entry.value.languageCode == currentLocale.languageCode) {
          _selectedLanguage = entry.key;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: Text(
            "language".tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: backgroundColorTheme,
                    title: Text(
                      'help'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      'help_content'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                            'close'.tr,
                            style: TextStyle(color: primaryColorTheme)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "select_language".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _languages.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = language == _selectedLanguage;

                  return ListTile(
                    title: Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: primaryColorTheme)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });

                      // Change the app language
                      final newLocale = _languageLocales[language];
                      if (newLocale != null) {
                        Get.updateLocale(newLocale);
                        // Save the selected language preference
                        saveLanguagePreference(newLocale);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // Save language preference (you can use shared_preferences)
  void saveLanguagePreference(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
  }
}

