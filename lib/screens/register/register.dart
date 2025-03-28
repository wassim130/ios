import 'package:ahmini/theme.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../../helper/CustomDialog/custom_dialog.dart';
import '../../services/auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool? _isFreelancer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  final ThemeController themeController = Get.find<ThemeController>();

  // Contrôleurs pour les champs de texte
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _siretController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptConditions = false;
  bool _useLocation = false;
  bool _useFingerprint = false;
  String _selectedDomaine = 'Technologie';
  final List<String> _domaines = [
    'Technologie'.tr,
    'Design'.tr,
    'Marketing'.tr,
    'Finance'.tr,
    'Autre'
  ];

  // Clés pour la validation des formulaires
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: _getProgressValue(0)).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeInOut,
          ),
        );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _siretController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _getProgressValue(int step) {
    switch (step) {
      case 0:
        return 0.33;
      case 1:
        return 0.66;
      case 2:
        return 1.0;
      default:
        return 0;
    }
  }

  void _animateToProgress(double endValue) {
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: endValue,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
    _progressController.forward();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
        _animateToProgress(_getProgressValue(_currentStep));
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Soumettre le formulaire
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _animateToProgress(_getProgressValue(_currentStep));
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitForm() async {
    final String firstName = _nomController.text.trim();
    final String lastName = _prenomController.text.trim();
    final String email = _emailController.text.trim();
    final String phoneNumber = '+${_telephoneController.text.trim()}';
    final String address = _adresseController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final bool acceptConditions = _acceptConditions;
    final bool useLocation = _useLocation;
    final bool useFingerprint = _useFingerprint;
    final String domain = _selectedDomaine;
    if (!acceptConditions) {
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation.'.tr),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les mots de passe ne correspondent pas.'.tr),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        );
      },
    );
    final dynamic data = await AuthService.register(firstName, lastName, email,
        phoneNumber, address, password, _isFreelancer!, useLocation, useFingerprint, domain);
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    if (data?['status'] == 'success' && mounted) {
      // Check if user is a freelancer
      if (data['isFreelancer'] == true) {
        // Redirect to portfolio creation page
        Navigator.pushReplacementNamed(
            context,
            '/portefolioedit',
            arguments: {'isFirstLogin': true}
        );
      } else {
        // Regular flow for non-freelancers
        Navigator.pushReplacementNamed(
            context,
            '/',
            arguments: {'user': data['user']}
        );
      }
      return;
    } else if (data?['status'] == 'error' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          data['message'] ?? 'unknown error'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ));
    } else if (mounted) {
      Navigator.pop(context);
      myCustomDialog(context, {
        'type': 'Connection error'.tr,
        'message': 'Could not connect to server. Please check your connection'.tr,
      });
    }
    setState(() {});
  }

  Widget _buildTypeSelection(Color primaryColorTheme, Color secondaryColorTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Choisissez votre profil'.tr,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sélectionnez le type de compte qui correspond à votre activité'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProfileCard(
              icon: Icons.person_outline,
              title: 'Free-lanceur'.tr,
              description: 'Je travaille en tant qu\'indépendant'.tr,
              isSelected: _isFreelancer == true,
              onTap: () => setState(() => _isFreelancer = true),
              primaryColorTheme: primaryColorTheme,
            ),
            _buildProfileCard(
              icon: Icons.business,
              title: 'Entreprise'.tr,
              description: 'Je représente une société'.tr,
              isSelected: _isFreelancer == false,
              onTap: () => setState(() => _isFreelancer = false),
              primaryColorTheme: primaryColorTheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColorTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColorTheme
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? primaryColorTheme
                  : Colors.white,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? primaryColorTheme
                    : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black54 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(Color primaryColorTheme, Color secondaryColorTheme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles'.tr,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              'Nom'.tr,
              _nomController,
              Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
              primaryColorTheme: primaryColorTheme,
            ),
            _buildTextField(
              'Prénom'.tr,
              _prenomController,
              Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Veuillez entrer votre prénom';
                }
                return null;
              },
              primaryColorTheme: primaryColorTheme,
            ),
            _buildTextField(
              'Email'.tr,
              _emailController,
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Veuillez entrer votre email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'.tr)
                    .hasMatch(value!)) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
              primaryColorTheme: primaryColorTheme,
            ),
            _buildTextField(
              'Téléphone'.tr,
              _telephoneController,
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Veuillez entrer votre numéro de téléphone';
                }
                return null;
              },
              primaryColorTheme: primaryColorTheme,
            ),
            _buildTextField(
              'Adresse'.tr,
              _adresseController,
              Icons.location_on_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Veuillez entrer votre adresse';
                }
                return null;
              },
              primaryColorTheme: primaryColorTheme,
            ),
            const SizedBox(height: 20),
            // Modification du style du DropdownButton pour correspondre au thème
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primaryColorTheme,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDomaine,
                  isExpanded: true,
                  hint:  Text(
                    'Domaine d\'activité'.tr,
                    style: TextStyle(
                      color: primaryColorTheme,
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  dropdownColor: Colors.white,
                  items: _domaines.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black54,                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDomaine = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSecurityOption(
              icon: Icons.location_on,
              title: 'Utiliser ma localisation'.tr,
              subtitle: 'Pour une meilleure protection'.tr,
              value: _useLocation,
              onChanged: (value) => setState(() => _useLocation = value),
              primaryColorTheme: primaryColorTheme,
              secondaryColorTheme: secondaryColorTheme,
            ),
            _buildSecurityOption(
              icon: Icons.phone,
              title: 'Activer l\'authentification a deux facteurs'.tr,
              subtitle: 'Connexion rapide et sécurisée'.tr,
              value: _useFingerprint,
              onChanged: (value) => setState(() => _useFingerprint = value),
              primaryColorTheme: primaryColorTheme,
              secondaryColorTheme: secondaryColorTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings(Color primaryColorTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sécurité'.tr,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            'Mot de passe'.tr,
            _passwordController,
            Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value!.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              return null;
            },
            primaryColorTheme: primaryColorTheme,
          ),
          _buildTextField(
            'Confirmer le mot de passe'.tr,
            _confirmPasswordController,
            Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
            primaryColorTheme: primaryColorTheme,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _acceptConditions,
                onChanged: (value) {
                  setState(() {
                    _acceptConditions = value ?? false;
                  });
                },
                fillColor: MaterialStateProperty.all(Colors.white),
                checkColor: primaryColorTheme,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _acceptConditions = !_acceptConditions;
                    });
                  },
                  child:  Text(
                    'J\'accepte les conditions d\'utilisation et la politique de confidentialité'.tr,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller,
      IconData icon, {
        TextInputType? keyboardType,
        bool isPassword = false,
        String? Function(String?)? validator,
        required Color primaryColorTheme,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryColorTheme),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          errorStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color primaryColorTheme,
    required Color secondaryColorTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColorTheme),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColorTheme,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _previousStep,
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 5,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTypeSelection(primaryColorTheme, secondaryColorTheme),
                  _buildPersonalInfo(primaryColorTheme, secondaryColorTheme),
                  _buildSecuritySettings(primaryColorTheme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child:  Text(
                        'Précédent'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Terminer' : 'Suivant'.tr,
                      style: TextStyle(
                        color: primaryColorTheme,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

