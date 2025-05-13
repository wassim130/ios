import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ahmini/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/components/input_field.dart';
import '../../../controllers/theme_controller.dart';
import '../../../helper/CustomDialog/loading_indicator.dart';
import '../../../helper/CustomDialog/custom_dialog.dart';
import 'resetpassword.dart';
import '../../../services/constants.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String resetId;
  final String email;

  const VerifyResetCodeScreen({
    Key? key,
    required this.resetId,
    required this.email,
  }) : super(key: key);

  @override
  _VerifyResetCodeScreenState createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final _codeController = TextEditingController();
  final ValueNotifier<String?> _codeErrorNotifier = ValueNotifier(null);
  final ThemeController themeController = Get.find<ThemeController>();

  Future<void> _verifyCode() async {
    final String code = _codeController.text.trim();

    _codeErrorNotifier.value = code.isEmpty ? "Code cannot be empty" : null;
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Veuillez saisir le code de vérification'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    myCustomLoadingIndicator(context);

    try {
      // Ensure code is sent as a string in the JSON body
      final response = await http.post(
        Uri.parse('$httpURL/$authAPI/verify-reset-code/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code, // Already a string from text controller
          'reset_id': widget.resetId,
        }),
      );

      if (mounted) {
        // Close loading indicator
        Navigator.pop(context);

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['status'] == 'success') {
          // Navigate to reset password screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                resetId: widget.resetId,
              ),
            ),
          );
        } else {
          // Extract error message from response
          final String errorMessage = data['content'] != null && data['content']['message'] != null
              ? data['content']['message']
              : 'Code invalide'.tr;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              errorMessage,
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

  Future<void> _resendCode() async {
    myCustomLoadingIndicator(context);

    try {
      final response = await http.post(
        Uri.parse('$httpURL/$authAPI/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (mounted) {
        // Close loading indicator
        Navigator.pop(context);

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['status'] == 'success') {
          // Update resetId if provided
          String newResetId = widget.resetId;
          if (data.containsKey('reset_id')) {
            newResetId = data['reset_id'].toString(); // Ensure it's a string

            // Update the widget state - note: this is a workaround
            // In a real app, you might want to use a better state management approach
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyResetCodeScreen(
                  resetId: newResetId,
                  email: widget.email,
                ),
              ),
            );
          } else {
            // Just show success message if no new reset_id
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Code renvoyé avec succès'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              data['content']?['message'] ?? 'Erreur lors du renvoi du code'.tr,
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
            'Vérification du code'.tr,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec logo et texte explicatif
                _buildHeader(),
                // Formulaire de vérification
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
            'Vérification du code'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Entrez le code de vérification envoyé à votre téléphone'.tr,
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
            errorNotifier: _codeErrorNotifier,
            controller: _codeController,
            icon: Icons.lock_outline,
            hint: 'Code de vérification'.tr,
            keyboardType: TextInputType.number, // Use number keyboard for code input
          ),
          const SizedBox(height: 30),

          // Bouton de vérification
          ElevatedButton(
            onPressed: _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColorTheme,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Vérifier le code'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lien pour renvoyer le code
          TextButton(
            onPressed: _resendCode,
            child: Text(
              'Renvoyer le code'.tr,
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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
