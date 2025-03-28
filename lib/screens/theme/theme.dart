import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../theme.dart';

class ThemeSettingsPage extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thème'.tr),
        backgroundColor: themeController.isDarkMode.value ? darkPrimaryColor : primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sélectionnez votre thème préféré'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Obx(() => SwitchListTile(
            title: Text('Mode sombre'.tr),
            subtitle: Text('Basculer entre le mode clair et sombre'.tr),
            value: themeController.isDarkMode.value,
            onChanged: (_) {
              themeController.toggleTheme();
            },
          )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Aperçu'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _buildThemePreviewCard(
              context,
              'Mode clair'.tr,
              myTheme
          ),
          _buildThemePreviewCard(
              context,
              'Mode sombre'.tr,
              myDarkTheme
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCard(BuildContext context, String title, ThemeData theme) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Theme(
        data: theme,
        child: ListTile(
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          tileColor: theme.scaffoldBackgroundColor,
          textColor: theme.textTheme.bodyLarge?.color,
          subtitle: Text(
            'Exemple de texte de sous-titre'.tr,
            style: theme.textTheme.bodySmall,
          ),
          trailing: Icon(Icons.preview, color: theme.iconTheme.color),
        ),
      ),
    );
  }
}