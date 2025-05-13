import 'package:ahmini/screens/explore/components/progress_indicator.dart';
import 'package:ahmini/screens/register/documentverificationpage.dart';
import 'package:ahmini/services/auth.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/CustomDialog/custom_dialog.dart';
import '../../helper/CustomDialog/loading_indicator.dart';
import '../../models/user.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/theme_controller.dart';
import '../confidentialite/confidentialite.dart';

class HomePage extends StatefulWidget {
  final GlobalKey? parentKey;
  final UserModel? user;
  final ThemeController themeController = Get.find<ThemeController>();

  HomePage({
    Key? key,
    this.parentKey,
    this.user,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ThemeController themeController = Get.find<ThemeController>();
  List<dynamic> activeContracts = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool showTrendingInsights = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchActiveContracts();

    // Animation pour les boutons et effets visuels
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchActiveContracts() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null) {
        throw Exception('Session cookie non trouvé');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/contracts/active/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          activeContracts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Échec du chargement des contrats: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showCreateContractForm(
      BuildContext context, bool isDark, Color primaryColorTheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateContractForm(
        isDark: isDark,
        primaryColorTheme: primaryColorTheme,
        onContractCreated: () {
          _fetchActiveContracts();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleLogout(context) async {
    final dynamic success = await AuthService.logout();
    myCustomDialog(context, success);
    if (success['status'] == 'success'.tr) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login'.tr,
            (route) => false,
      );
    }
  }

  void _showStatisticsInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Statistiques de performance disponibles'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  Future<bool> _checkUserHasPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/portefolio/check/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasPortfolio'] ?? false;
      } else {
        print(
            'Erreur lors de la vérification du portfolio: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la vérification du portfolio: $e');
      return false;
    }
  }

  Future<void> _navigateToPortfolioPage(BuildContext context) async {
    if (widget.user == null) return;
    myCustomLoadingIndicator(context);

    try {
      final hasPortfolio = await _checkUserHasPortfolio();
      if (mounted) {
        Navigator.pop(context);
        if (!hasPortfolio) {
          if (widget.user!.isEnterprise) {
            Navigator.pushNamed(context, '/entreprise/create');
          } else {
            Navigator.pushNamed(context, '/freelancer_portfolio');
          }
        } else {
          if (widget.user!.isEnterprise) {
            Navigator.pushNamed(context, '/entreprise/home');
          } else {
            Navigator.pushNamed(context, '/portefolioedit',
                arguments: {'isFirstLogin': true});
          }
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la vérification du portfolio: $e')),
      );
    }
  }
  void _showAppGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Guide d\'utilisation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bienvenue dans votre guide d\'utilisation Ahmini!'),
                SizedBox(height: 15),
                Text('Suivez les étapes ci-dessous pour utiliser l\'application efficacement:'),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.looks_one, color: Colors.purple),
                  title: Text('Créez un nouveau contrat'),
                  subtitle: Text('Utilisez le bouton "Nouveau Contrat"'),
                ),
                ListTile(
                  leading: Icon(Icons.looks_two, color: Colors.purple),
                  title: Text('Suivez vos contrats actifs'),
                  subtitle: Text('Consultez la section "Contrats Actifs"'),
                ),
                ListTile(
                  leading: Icon(Icons.looks_3, color: Colors.purple),
                  title: Text('Profitez des offres spéciales'),
                  subtitle: Text('Consultez régulièrement les nouvelles offres'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Méthode améliorée pour contacter l'admin
  void _contactAdmin(BuildContext context, bool isDark) {
    final List<Map<String, dynamic>> contactOptions = [
      {
        'icon': Icons.phone,
        'title': 'Appel téléphonique',
        'subtitle': 'Parler directement avec un conseiller',
        'action': () async {
          final Uri phoneUri = Uri(scheme: 'tel', path: '+213541692831');
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Impossible de lancer l\'appel')),
            );
          }
          Navigator.pop(context);
        }
      },
      {
        'icon': Icons.email,
        'title': 'Email',
        'subtitle': 'Envoyer un email à notre équipe',
        'action': () async {
          final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'biskriwassim440@gmail.com',
              queryParameters: {
                'subject': 'Demande d\'assistance Ahmini',
                'body': 'Bonjour, j\'ai besoin d\'aide concernant...'
              }
          );
          if (await canLaunchUrl(emailUri)) {
            await launchUrl(emailUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Impossible d\'ouvrir l\'application email')),
            );
          }
          Navigator.pop(context);
        }
      },
      {
        'icon': Icons.chat_bubble,
        'title': 'Chat en direct',
        'subtitle': 'Discuter avec un agent en ligne',
        'action': () {
          Navigator.pop(context);
          // Ouvrir une interface de chat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Le chat en direct sera disponible prochainement'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      'Contacter l\'administrateur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Choisissez votre méthode de contact préférée',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10),
                itemCount: contactOptions.length,
                itemBuilder: (context, index) {
                  final option = contactOptions[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: Colors.purple,
                        ),
                      ),
                      title: Text(
                        option['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        option['subtitle'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: option['action'] as Function(),
                      tileColor: isDark ? Color(0xFF2A2A2A) : Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notre équipe est disponible du lundi au vendredi de 9h à 17h',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher le portfolio
  void _showPortfolio(BuildContext context) {
    Navigator.pushNamed(context, '/portfolio');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    final user = controller.user;

    // Vérifier si l'utilisateur est un freelancer
    final bool isFreelancer = user != null && user.isEnterprise == false;

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme =
      isDark ? darkBackgroundColor : backgroundColor;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: const Text(
            'Ahmini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: user == null
              ? []
              : [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications/'.tr);
              },
            ),
            IconButton(
              icon:
              const Icon(Icons.message_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/messages/home'.tr);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Text(
                      'Bonjour, ${user?.firstName ?? ''} 👋'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vos données sont en sécurité'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (user != null)
                !user.isNew
                    ? Container(
                  decoration: BoxDecoration(
                    color: backgroundColorTheme,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Nouvelle offre section avec bouton en haut
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple,
                                Colors.deepPurple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'NOUVEAU'.tr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/subscription');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.purple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Profiter maintenant'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(Icons.arrow_forward, size: 14),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nouvelle Offre'.tr,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Obtenez 30% de réduction sur votre abonnement annuel'.tr,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.white70, size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    'Offre valable jusqu\'au 30 juin'.tr,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quick Actions - Tous les boutons sur une même ligne
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actions Rapides'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Afficher le bouton "Nouveau Contrat" uniquement si l'utilisateur n'est PAS un freelancer
                                  if (!isFreelancer)
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: _buildQuickActionButton(
                                        icon: Icons.description,
                                        label: 'Nouveau Contrat'.tr,
                                        onTap: () => _showCreateContractForm(context, isDark, primaryColorTheme),
                                        secondaryColor: secondaryColorTheme,
                                        isDark: isDark,
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: _buildQuickActionButton(
                                      icon: Icons.auto_awesome,
                                      label: 'Conseils Premium'.tr,
                                      onTap: () => _showAppGuide(context),
                                      secondaryColor: secondaryColorTheme,
                                      isDark: isDark,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: _buildQuickActionButton(
                                      icon: Icons.contact_support,
                                      label: 'Nous Contacter'.tr,
                                      onTap: () => _contactAdmin(context, isDark),
                                      secondaryColor: secondaryColorTheme,
                                      isDark: isDark,
                                    ),
                                  ),
                                  // Afficher le bouton "Mon Portfolio" uniquement pour les freelancers
                                  if (isFreelancer)
                                    _buildQuickActionButton(
                                      icon: Icons.work,
                                      label: 'Mon Portfolio'.tr,
                                      onTap: () => _navigateToPortfolioPage(context),
                                      secondaryColor: secondaryColorTheme,
                                      isDark: isDark,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Active Contracts
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contrats Actifs'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/contracts');
                                  },
                                  child: Text(
                                    'Voir tous'.tr,
                                    style: TextStyle(
                                      color: primaryColorTheme,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            if (isLoading)
                              Center(
                                child:
                                CircularProgressIndicator(color: primaryColorTheme),
                              )
                            else if (hasError)
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 40),
                                    SizedBox(height: 10),
                                    Text(
                                      'Erreur de chargement'.tr,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      errorMessage,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: _fetchActiveContracts,
                                      icon:
                                      Icon(Icons.refresh, color: primaryColorTheme),
                                      label: Text(
                                        'Réessayer'.tr,
                                        style: TextStyle(color: primaryColorTheme),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (activeContracts.isEmpty)
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        color: isDark ? Colors.white54 : Colors.black38,
                                        size: 40,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Aucun contrat actif'.tr,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Créez votre premier contrat'.tr,
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children:
                                  activeContracts.take(2).map<Widget>((contract) {
                                    return _buildContractCard(
                                      company: contract['client_name'] ?? 'Client',
                                      status: contract['status'] ?? 'pending',
                                      date: _formatDate(contract['end_date']),
                                      amount: '${contract['amount']} DA',
                                      progress: _calculateProgress(
                                          contract['start_date'], contract['end_date']),
                                      secondaryColor: secondaryColorTheme,
                                      primaryColor: primaryColorTheme,
                                      isDark: isDark,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/contracts/detail',
                                          arguments: contract['id'],
                                        ).then((_) => _fetchActiveContracts());
                                      },
                                    );
                                  }).toList(),
                                ),
                          ],
                        ),
                      ),

                      // Security Tips - Only show if A2F is not enabled
                      if (user != null && !user.twoFactorEnabled)
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: secondaryColorTheme,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Conseil du Jour'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Activez l\'authentification à deux facteurs pour une sécurité renforcée de votre compte.'
                                      .tr,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DocumentVerificationPage(
                                                user: user),
                                      ),
                                    );
                                  },
                                  child: Text('Activer maintenant'.tr),
                                  style: TextButton.styleFrom(
                                    foregroundColor: primaryColorTheme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                    : Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.73,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColorTheme,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Account still being proccessed by administrators'
                              .tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () {
                                _handleLogout(context);
                              },
                              child: Text('Déconnexion'.tr),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color secondaryColor,
    required bool isDark,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 130,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: isDark ? Colors.white70 : Colors.black87),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractCard({
    required String company,
    required String status,
    required String date,
    required String amount,
    required double progress,
    required Color secondaryColor,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? Colors.white24 : Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  double _calculateProgress(String? startDateStr, String? endDateStr) {
    if (startDateStr == null || endDateStr == null) return 0.0;

    try {
      final startDate = DateTime.parse(startDateStr);
      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();

      if (now.isBefore(startDate)) return 0.0;
      if (now.isAfter(endDate)) return 1.0;

      final totalDuration = endDate.difference(startDate).inDays;
      final elapsedDuration = now.difference(startDate).inDays;

      return elapsedDuration / totalDuration;
    } catch (e) {
      return 0.0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class CreateContractForm extends StatefulWidget {
  final bool isDark;
  final Color primaryColorTheme;
  final VoidCallback onContractCreated;

  const CreateContractForm({
    Key? key,
    required this.isDark,
    required this.primaryColorTheme,
    required this.onContractCreated,
  }) : super(key: key);

  @override
  _CreateContractFormState createState() => _CreateContractFormState();
}

class _CreateContractFormState extends State<CreateContractForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _freelancerEmailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bankAccountHolderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankRibController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 30));

  bool _hasAdvancePayment = true;
  int _advancePaymentPercentage = 30;

  bool _isLoading = false;
  bool _isLoadingFreelancer = false;
  String _errorMessage = '';
  Map<String, dynamic>? _freelancerData;
  Map<String, dynamic>? _clientData;

  @override
  void initState() {
    super.initState();
    _fetchClientData();
    _cityController.text = 'Alger'; // Valeur par défaut
  }

  Future<void> _fetchClientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null) {
        throw Exception('Session cookie non trouvé');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/contracts/user-profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _clientData = json.decode(response.body);
          // Pré-remplir la ville si disponible
          if (_clientData != null && _clientData!.containsKey('profile') &&
              _clientData!['profile'] != null) {
            if (_clientData!['profile']['city'] != null) {
              _cityController.text = _clientData!['profile']['city'];
            }

            // Pré-remplir les informations bancaires si disponibles
            if (_clientData!['profile']['bank_account_holder'] != null) {
              _bankAccountHolderController.text = _clientData!['profile']['bank_account_holder'];
            }
            if (_clientData!['profile']['bank_name'] != null) {
              _bankNameController.text = _clientData!['profile']['bank_name'];
            }
            if (_clientData!['profile']['bank_rib'] != null) {
              _bankRibController.text = _clientData!['profile']['bank_rib'];
            }
          }
        });
      } else {
        print('Erreur lors de la récupération des données client: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors de la récupération des données client: $e');
    }
  }

  Future<void> _lookupFreelancer(String email) async {
    if (email.isEmpty || !email.contains('@')) return;

    setState(() {
      _isLoadingFreelancer = true;
      _freelancerData = null;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null) {
        throw Exception('Session cookie non trouvé');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/users/lookup/?email=${Uri.encodeComponent(email)}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      setState(() {
        _isLoadingFreelancer = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          _freelancerData = json.decode(response.body);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Aucun utilisateur trouvé avec cet email.';
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la recherche de l\'utilisateur.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingFreelancer = false;
        _errorMessage = 'Erreur de connexion au serveur.';
      });
      print('Exception lors de la recherche du freelancer: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _freelancerEmailController.dispose();
    _cityController.dispose();
    _bankAccountHolderController.dispose();
    _bankNameController.dispose();
    _bankRibController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColorTheme,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final csrfToken = prefs.getString('csrf_token');

      if (sessionCookie == null || csrfToken == null) {
        throw Exception('Session cookie ou CSRF token non trouvé');
      }

      // Format the contract data
      final contractData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
        'amount': double.parse(_amountController.text),
        'freelancer_email': _freelancerEmailController.text,
        'city': _cityController.text,
        'has_advance_payment': _hasAdvancePayment,
        'advance_payment_percentage': _advancePaymentPercentage,
        'bank_account_holder': _bankAccountHolderController.text,
        'bank_name': _bankNameController.text,
        'bank_rib': _bankRibController.text,
      };

      print('Sending contract data: $contractData');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/contracts/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie; csrftoken=$csrfToken",
          'X-CSRFToken': csrfToken,
        },
        body: json.encode(contractData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        widget.onContractCreated();
        Get.snackbar(
          'Succès',
          'Contrat créé avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          throw Exception(
              errorData['detail'] ?? 'Erreur inconnue: ${response.statusCode}');
        } catch (e) {
          throw Exception(
              'Erreur serveur: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final backgroundColor = widget.isDark ? Color(0xFF121212) : Colors.white;
    final inputBgColor =
    widget.isDark ? Color(0xFF1E1E1E) : Colors.grey.shade50;
    final borderColor =
    widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: widget.primaryColorTheme,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                'Créer un nouveau contrat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'Titre du contrat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Développement d\'application mobile',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Décrivez les détails du contrat...',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Ville',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Alger',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une ville';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date de début',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: inputBgColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(_startDate),
                                        style: TextStyle(color: textColor),
                                      ),
                                      Icon(Icons.calendar_today, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date de fin',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: inputBgColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(_endDate),
                                        style: TextStyle(color: textColor),
                                      ),
                                      Icon(Icons.calendar_today, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Montant (DA)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Ex: 45000',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un montant valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email du freelancer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _freelancerEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Ex: freelancer@example.com',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'email du freelancer';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Debounce the API call
                        if (_freelancerEmailController.text.isNotEmpty) {
                          Future.delayed(Duration(milliseconds: 500), () {
                            if (value == _freelancerEmailController.text) {
                              _lookupFreelancer(value);
                            }
                          });
                        }
                      },
                    ),
                    if (_isLoadingFreelancer)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.primaryColorTheme,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Recherche en cours...',
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_freelancerData != null)
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Freelancer trouvé:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${_freelancerData!['first_name']} ${_freelancerData!['last_name']}',
                              style: TextStyle(color: textColor),
                            ),
                            if (_freelancerData!.containsKey('nif') && _freelancerData!['nif'] != null)
                              Text(
                                'NIF: ${_freelancerData!['nif']}',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            if (_freelancerData!.containsKey('phone_number') && _freelancerData!['phone_number'] != null)
                              Text(
                                'Téléphone: ${_freelancerData!['phone_number']}',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            if (_freelancerData!.containsKey('address') && _freelancerData!['address'] != null)
                              Text(
                                'Adresse: ${_freelancerData!['address']}',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),

                    // Informations bancaires
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: widget.isDark ? Color(0xFF1E1E1E).withOpacity(0.5) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations bancaires',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Titulaire du compte',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _bankAccountHolderController,
                            decoration: InputDecoration(
                              hintText: 'Ex: Mohamed Ali',
                              filled: true,
                              fillColor: inputBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Banque',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _bankNameController,
                            decoration: InputDecoration(
                              hintText: 'Ex: BNA',
                              filled: true,
                              fillColor: inputBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              prefixIcon: Icon(Icons.account_balance),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'RIB',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _bankRibController,
                            decoration: InputDecoration(
                              hintText: 'Ex: 00100 00012 0000000000 45',
                              filled: true,
                              fillColor: inputBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Acompte à la signature',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Switch(
                          value: _hasAdvancePayment,
                          onChanged: (value) {
                            setState(() {
                              _hasAdvancePayment = value;
                            });
                          },
                          activeColor: widget.primaryColorTheme,
                        ),
                      ],
                    ),
                    if (_hasAdvancePayment) ...[
                      SizedBox(height: 10),
                      Text(
                        'Pourcentage d\'acompte (%)',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _advancePaymentPercentage.toDouble(),
                              min: 10,
                              max: 50,
                              divisions: 8,
                              label: _advancePaymentPercentage.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _advancePaymentPercentage = value.round();
                                });
                              },
                              activeColor: widget.primaryColorTheme,
                            ),
                          ),
                          Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              '$_advancePaymentPercentage%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_amountController.text.isNotEmpty && double.tryParse(_amountController.text) != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Montant de l\'acompte: ${(double.parse(_amountController.text) * _advancePaymentPercentage / 100).toStringAsFixed(2)} DA',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                    SizedBox(height: 20),
                    if (_clientData != null && _clientData!.containsKey('profile') &&
                        _clientData!['profile'] != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations client:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 5),
                            if (_clientData!['profile']['nif'] != null)
                              Text(
                                'NIF: ${_clientData!['profile']['nif']}',
                                style: TextStyle(color: textColor),
                              ),
                            if (_clientData!['profile']['rc'] != null)
                              Text(
                                'RC: ${_clientData!['profile']['rc']}',
                                style: TextStyle(color: textColor),
                              ),
                            if (_clientData!['profile']['phone_number'] != null)
                              Text(
                                'Téléphone: ${_clientData!['profile']['phone_number']}',
                                style: TextStyle(color: textColor),
                              ),
                            if (_clientData!['profile']['address'] != null)
                              Text(
                                'Adresse: ${_clientData!['profile']['address']}',
                                style: TextStyle(color: textColor),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColorTheme,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor:
                          widget.primaryColorTheme.withOpacity(0.6),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          'Créer le contrat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
