import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ahmini/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/components/input_field.dart';
import '../../../controllers/theme_controller.dart';
import '../../../helper/CustomDialog/loading_indicator.dart';
import '../../../helper/CustomDialog/custom_dialog.dart';
import 'confirmpassword.dart';
import '../../../services/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final ValueNotifier<String?> _emailErrorNotifier = ValueNotifier(null);
  final ThemeController themeController = Get.find<ThemeController>();

  Future<void> _requestPasswordReset() async {
    final String email = _emailController.text.trim();

    _emailErrorNotifier.value = email.isEmpty ? "Email cannot be empty" : null;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Veuillez saisir votre email'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    myCustomLoadingIndicator(context);

    try {
      final response = await http.post(
        Uri.parse('$httpURL/$authAPI/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (mounted) {
        // Close loading indicator
        Navigator.pop(context);

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (data['status'] == 'success') {
            // Assurez-vous que reset_id est converti en String
            if (data.containsKey('reset_id')) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VerifyResetCodeScreen(
                    resetId: data['reset_id'].toString(), // Conversion explicite en String
                    email: email,
                  ),
                ),
              );
            } else {
              // Just show a message if no reset_id (for security)
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  data['message'] ?? 'Instructions envoyées si l\'email existe'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                data['content']?['message'] ?? 'Une erreur s\'est produite'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              data['content']?['message'] ?? 'Une erreur s\'est produite'.tr,
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
            'Mot de passe oublié'.tr,
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
                _buildForm(context, isDark, primaryColorTheme, backgroundColorTheme),
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
            'Réinitialisation du mot de passe'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Entrez votre adresse e-mail pour recevoir un code de réinitialisation'.tr,
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

  Container _buildForm(BuildContext context, bool isDark, Color primaryColorTheme, Color backgroundColorTheme) {
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
            errorNotifier: _emailErrorNotifier,
            controller: _emailController,
            icon: Icons.email_outlined,
            hint: 'Adresse e-mail'.tr,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 30),

          // Bouton de demande de réinitialisation
          ElevatedButton(
            onPressed: _requestPasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColorTheme,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Envoyer le code'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lien de retour à la connexion
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Vous vous souvenez de votre mot de passe?'.tr,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Se connecter'.tr,
                  style: TextStyle(
                    color: primaryColorTheme,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
