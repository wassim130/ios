import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth.dart';
import '../../helper/CustomDialog/loading_indicator.dart';
import '../../helper/CustomDialog/custom_dialog.dart';
import '../../controllers/theme_controller.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  final int twoFactorId;

  const TwoFactorVerificationScreen({
    Key? key,
    required this.twoFactorId,
  }) : super(key: key);

  @override
  _TwoFactorVerificationScreenState createState() =>
      _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState
    extends State<TwoFactorVerificationScreen> {
  final _codeController = TextEditingController();
  String? _errorMessage;
  bool _isResending = false;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez entrer le code de vérification";
      });
      return;
    }

    myCustomLoadingIndicator(context);

    try {
      final result = await AuthService.verifyTwoFactor(
          _codeController.text.trim(),
          widget.twoFactorId.toString()
      );

      if (mounted) {
        Navigator.pop(context); // Close loading indicator

        if (result['status'] == 'success'.tr) {
          // Navigate to home and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/'.tr,
                (route) => false,
            arguments: {'user': result['user']},
          );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Code de vérification invalide';
          });
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
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.resendTwoFactor(
        widget.twoFactorId.toString(),
      );

      if (mounted) {
        setState(() {
          _isResending = false;
        });

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nouveau code envoyé'.tr),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Erreur lors de l\'envoi du code';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });

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
      final textColor = Colors.white;

      return Scaffold(
        appBar: AppBar(
          title: Text('Vérification à deux facteurs'.tr),
          backgroundColor: primaryColorTheme,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: primaryColorTheme,
              ),
              SizedBox(height: 30),
              Text(
                'Vérification à deux facteurs'.tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColorTheme,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Veuillez entrer le code de vérification envoyé à votre appareil'.tr,
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 10, color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: '000000'.tr,
                  counterText: ''.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: primaryColorTheme,
                      width: 2,
                    ),
                  ),
                  errorText: _errorMessage,
                ),
              ),
              SizedBox(height: 30),
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
                  'Vérifier'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _isResending ? null : _resendCode,
                child: _isResending
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColorTheme,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Envoi en cours...'.tr,
                      style: TextStyle(
                        color: primaryColorTheme.withOpacity(0.7),
                      ),
                    ),
                  ],
                )
                    : Text(
                  'Renvoyer le code'.tr,
                  style: TextStyle(
                    color: primaryColorTheme,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
