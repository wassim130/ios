import 'package:ahmini/services/auth.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ahmini/controllers/theme_controller.dart';
class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final ThemeController themeController = Get.find<ThemeController>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Password strength indicators
  double _passwordStrength = 0.0;
  String _passwordStrengthText = 'Faible';
  Color _strengthColor = Colors.red;

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'''[!@#\$%^&*(),.?'":;/\\{}|<>`~\-_=+\§¤°€£¥©®™¶•¿¡]'''))) strength += 0.2;


    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.2) {
        _passwordStrengthText = 'Très faible';
        _strengthColor = Colors.red;
      } else if (strength <= 0.4) {
        _passwordStrengthText = 'Faible';
        _strengthColor = Colors.orange;
      } else if (strength <= 0.6) {
        _passwordStrengthText = 'Moyen';
        _strengthColor = Colors.yellow;
      } else if (strength <= 0.8) {
        _passwordStrengthText = 'Fort';
        _strengthColor = Colors.lightGreen;
      } else {
        _passwordStrengthText = 'Très fort';
        _strengthColor = Colors.green;
      }
    });
  }

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Les mots de passe ne correspondent pas";
        _isLoading = false;
      });
      return;
    }

    final data = await AuthService.changePassword({
      "old_password": _oldPasswordController.text,
      "new_password": _newPasswordController.text,
    });
    print(data);
    if (data?['status'] == "success") {
      // Succès
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: themeController.isDarkMode.value ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Succès'.tr,
                style: TextStyle(
                  color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          content: Text(
            'Votre mot de passe a été modifié avec succès.'.tr,
            style: TextStyle(
              color: themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'OK'.tr,
                style: TextStyle(
                  color: themeController.isDarkMode.value ? darkPrimaryColor : primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (data?['status'] == 'error'.tr) {
      // Erreur
      final errorData = data['detail'];
      setState(() {
        _errorMessage = errorData ?? 'Une erreur est survenue';
      });
    } else {
      setState(() {
        _errorMessage = "Erreur de connexion au serveur";
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final textColor = isDark ? Colors.white : Colors.black;
      final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: Text(
            'Changer le mot de passe'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: primaryColorTheme,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Créez un nouveau mot de passe'.tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Votre nouveau mot de passe doit être différent des précédents'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColorSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Password Form
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Current Password
                      buildPasswordField(
                        "Mot de passe actuel",
                        "Entrez votre mot de passe actuel",
                        _obscureOldPassword,
                            (val) => setState(
                                () => _obscureOldPassword = !_obscureOldPassword),
                        controller: _oldPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe actuel';
                          }
                          return null;
                        },
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                        secondaryColorTheme: secondaryColorTheme,
                      ),
                      SizedBox(height: 20),

                      // New Password
                      buildPasswordField(
                        "Nouveau mot de passe",
                        "Entrez votre nouveau mot de passe",
                        _obscureNewPassword,
                            (val) => setState(
                                () => _obscureNewPassword = !_obscureNewPassword
                                ),
                        controller: _newPasswordController,
                        onChanged: (val) {
                          _checkPasswordStrength(val);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nouveau mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'.tr))) {
                            return 'Le mot de passe doit contenir au moins une majuscule';
                          }
                          if (!value.contains(RegExp(r'[a-z]'.tr))) {
                            return 'Le mot de passe doit contenir au moins une minuscule';
                          }
                          if (!value.contains(RegExp(r'[0-9]'.tr))) {
                            return 'Le mot de passe doit contenir au moins un chiffre';
                          }
                          if (!value.contains(RegExp(r'''[!@#\$%^&*(),.?'":;/\\{}|<>`~\-_=+\§¤°€£¥©®™¶•¿¡]'''))) {
                            return 'Le mot de passe doit contenir au moins un caractère spécial';
                          }
                          return null;
                        },
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                        secondaryColorTheme: secondaryColorTheme,
                      ),

                      // Password Strength Indicator
                      if (_passwordStrength > 0)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Force du mot de passe:'.tr,
                                    style: TextStyle(
                                      color: textColorSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _passwordStrengthText,
                                    style: TextStyle(
                                      color: _strengthColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _strengthColor),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 20),

                      // Confirm Password
                      buildPasswordField(
                        "Confirmer le mot de passe",
                        "Confirmez votre nouveau mot de passe",
                        _obscureConfirmPassword,
                            (val) => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                        secondaryColorTheme: secondaryColorTheme,
                      ),

                      // Afficher le message d'erreur s'il y en a un
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // Password Requirements
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: secondaryColorTheme,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Le mot de passe doit contenir:'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            buildRequirement('Au moins 8 caractères'.tr, isDark, primaryColorTheme),
                            buildRequirement('Au moins une lettre majuscule'.tr, isDark, primaryColorTheme),
                            buildRequirement('Au moins une lettre minuscule'.tr, isDark, primaryColorTheme),
                            buildRequirement('Au moins un chiffre'.tr, isDark, primaryColorTheme),
                            buildRequirement('Au moins un caractère spécial'.tr, isDark, primaryColorTheme),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColorTheme,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              _changePassword();
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Sauvegarder'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
        ),
      );
    });
  }

  Widget buildPasswordField(
      String label,
      String hint,
      bool obscureText,
      Function(bool) onToggle, {
        Function(String)? onChanged,
        TextEditingController? controller,
        String? Function(String?)? validator,
        required bool isDark,
        required Color primaryColorTheme,
        required Color secondaryColorTheme,
      }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white60 : Colors.black38,
          ),
          filled: true,
          fillColor: secondaryColorTheme,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: primaryColorTheme,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: primaryColorTheme,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: primaryColorTheme,
            ),
            onPressed: () => onToggle(!obscureText),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget buildRequirement(String text, bool isDark, Color primaryColorTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: primaryColorTheme,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

