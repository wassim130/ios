import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ahmini/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../controllers/theme_controller.dart';
import '../../../helper/CustomDialog/loading_indicator.dart';
import '../../../helper/CustomDialog/custom_dialog.dart';
import '../../register/components/passwordInput.dart';
import '../login.dart';
import '../../../services/constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetId;

  const ResetPasswordScreen({
    Key? key,
    required this.resetId,
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ValueNotifier<String?> _passwordErrorNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _confirmPasswordErrorNotifier = ValueNotifier(null);
  final ThemeController themeController = Get.find<ThemeController>();

  // Variables pour la force du mot de passe
  double _passwordStrength = 0.0;
  String _passwordStrengthText = 'Faible';
  Color _strengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
  }

  void _checkPasswordStrength(String password) {
    if (password.length < 8) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthText = 'Très faible';
        _strengthColor = Colors.red;
      });
      return;
    }

    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(
        RegExp(r'''[!@#\$%^&*(),.?'":;/\\{}|<>`~\-_=+\§¤°€£¥©®™¶•¿¡]''')))
      strength += 0.2;

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
      } else if (strength == 1) {
        _passwordStrengthText = 'Très fort';
        _strengthColor = Colors.green;
      }
    });
  }

  Future<void> _resetPassword() async {
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validate password
    _passwordErrorNotifier.value = password.isEmpty ? "Le mot de passe ne peut pas être vide" : null;
    _confirmPasswordErrorNotifier.value = confirmPassword.isEmpty ? "La confirmation ne peut pas être vide" : null;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Veuillez remplir tous les champs'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    if (password != confirmPassword) {
      _confirmPasswordErrorNotifier.value = "Les mots de passe ne correspondent pas";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Les mots de passe ne correspondent pas'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    // Password strength validation
    if (_passwordStrength < 0.6 || password.length < 8) {
      _passwordErrorNotifier.value = "Le mot de passe doit être plus fort";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Le mot de passe doit contenir au moins 8 caractères, une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    myCustomLoadingIndicator(context);

    try {
      final response = await http.post(
        Uri.parse('$httpURL/$authAPI/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reset_id': widget.resetId,
          'new_password': password,
        }),
      );

      if (mounted) {
        // Close loading indicator
        Navigator.pop(context);

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['status'] == 'success') {
          // Show success message
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                child: Container(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 60),
                      SizedBox(height: 20),
                      Text(
                        "Succès !",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Votre mot de passe a été réinitialisé avec succès.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fermer le dialogue
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginPage()),
                                (route) => false,
                          );
                        },
                        icon: Icon(Icons.login),
                        label: Text("Se connecter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );


          // Navigate back to login screen after a short delay
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              data['content']?['message'] ?? 'Erreur lors de la réinitialisation du mot de passe'.tr,
              style: TextStyle(color: Colors.white),
            ),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        myCustomDialog(context, {
          'type': 'Error'.tr,
          'message': 'Une erreur s\'est produite. Veuillez réessayer.'.tr,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final textColor = isDark ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Nouveau mot de passe'.tr,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec logo et texte explicatif
                _buildHeader(),
                // Formulaire de réinitialisation
                _buildForm(context, isDark, primaryColorTheme, backgroundColorTheme, secondaryColorTheme, textColor),
              ],
            ),
          ),
        ),
      );
    });
  }

  Container _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Image.asset('assets/images/applogo.png'.tr, height: 120),
          const SizedBox(height: 20),
          Text(
            'Créer un nouveau mot de passe'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Votre nouveau mot de passe doit être différent des précédents'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildForm(BuildContext context, bool isDark, Color primaryColorTheme, Color backgroundColorTheme, Color secondaryColorTheme, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? darkSecondaryColor : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          InputField(
            errorNotifier: _passwordErrorNotifier,
            controller: _passwordController,
            icon: Icons.lock_outline,
            hint: 'Nouveau mot de passe'.tr,
            isPassword: true,
            obscureText: true,
            onChanged: _checkPasswordStrength,
          ),

          // Indicateur de force du mot de passe
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
                          color: isDark ? Colors.white : Colors.black,
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
                      valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
          InputField(
            errorNotifier: _confirmPasswordErrorNotifier,
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            hint: 'Confirmer le mot de passe'.tr,
            isPassword: true,
            obscureText: true,
          ),
          const SizedBox(height: 20),

          // Critères du mot de passe
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
                buildRequirement('Au moins 8 caractères'.tr),
                buildRequirement('Au moins une lettre majuscule'.tr),
                buildRequirement('Au moins une lettre minuscule'.tr),
                buildRequirement('Au moins un chiffre'.tr),
                buildRequirement('Au moins un caractère spécial'.tr),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Bouton de réinitialisation
          ElevatedButton(
            onPressed: _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColorTheme,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Réinitialiser le mot de passe'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Color(0xFF6F50FF),
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}