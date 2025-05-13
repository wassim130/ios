// login.dart
import 'package:ahmini/screens/login/resetpassword/forgotpassword.dart';
import 'package:ahmini/screens/login/twoverificationscreen.dart';
import 'package:ahmini/theme.dart';
import 'package:get/get.dart';

import '../../helper/CustomDialog/loading_indicator.dart';
import '../../helper/CustomDialog/custom_dialog.dart';

import '../../services/auth.dart';
import 'package:flutter/material.dart';
import '../register/register.dart';
import 'components/input_field.dart';
import 'components/check_box.dart';
import '../../controllers/theme_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<String?> _emailErrorNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _passwordErrorNotifier = ValueNotifier(null);
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    _emailErrorNotifier.value = email.isEmpty ? "Email cannot be empty" : null;
    _passwordErrorNotifier.value =
    password.isEmpty ? "Password cannot be empty" : null;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Veuillez saisir votre email et votre mot de passe'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    myCustomLoadingIndicator(context);

    try {
      final dynamic data = await AuthService.login(email, password);

      if (mounted) {
        // Close loading indicator
        Navigator.pop(context);

        switch (data?['status']) {
          case 'success':
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/'.tr,
                  (args) => false,
              arguments: {'user': data['user']},
            );
            break;
          case 'two_factor_required':
          // Navigate to 2FA verification screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TwoFactorVerificationScreen(
                  twoFactorId: data['two_factor_id'],
                ),
              ),
            );
            break;
          case 'error':
            _passwordErrorNotifier.value =
                data['content']?['message'] ?? 'Invalid email or password'.tr;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                data['content']?['message'] ?? 'Invalid email or password'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ));
            break;
          default:
            myCustomDialog(context, {
              'type': 'Connection error'.tr,
              'message':
              'Could not connect to server. Please check your connection'
                  .tr,
            });
            break;
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
      final backgroundColorTheme =
      isDark ? darkBackgroundColor : backgroundColor;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // En-tête avec logo et texte de bienvenue
                  _buildHeader(),
                  // Formulaire de connexion
                  _buildForm(
                      context, isDark, primaryColorTheme, backgroundColorTheme),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Container _buildForm(BuildContext context, bool isDark,
      Color primaryColorTheme, Color backgroundColorTheme) {
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
          const SizedBox(height: 20),
          InputField(
            errorNotifier: _passwordErrorNotifier,
            controller: _passwordController,
            icon: Icons.lock_outline,
            hint: 'Mot de passe'.tr,
            isPassword: true,
            obscureText: true,
          ),

          // Options supplémentaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MyCheckBox(
                    rememberMe: _rememberMe,
                    callBack: () {
                      _rememberMe = !_rememberMe;
                    },
                  ),
                  Text(
                    'Se souvenir de moi'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  'Mot de passe oublié?'.tr,
                  style: TextStyle(
                    color: primaryColorTheme,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Bouton de connexion
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColorTheme,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Se connecter'.tr,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          // Séparateur
          Row(
            children: [
              Expanded(
                  child: Divider(
                      color: isDark ? Colors.white30 : Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('ou'.tr,
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600])),
              ),
              Expanded(
                  child: Divider(
                      color: isDark ? Colors.white30 : Colors.grey[300])),
            ],
          ),

          const SizedBox(height: 20),

          // Lien d'inscription
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Vous n\'avez pas de compte?'.tr,
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'S\'inscrire'.tr,
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

  Container _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Image.asset('assets/images/applogo.png'.tr, height: 170),
          const SizedBox(height: 0),
          Text(
            'Bienvenue sur Ahmini'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Votre sécurité, notre priorité'.tr,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
