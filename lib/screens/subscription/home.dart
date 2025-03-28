import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';  // Remplacer uni_links par app_links
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahmini/theme.dart';
import 'package:ahmini/controllers/theme_controller.dart';
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Change this to your actual API URL
  final String apiBaseUrl = 'http://10.0.2.2:8000/api';
  final _appLinks = AppLinks(); // Utiliser AppLinks au lieu de StreamSubscription
  final ThemeController themeController = Get.find<ThemeController>();

  // État de l'abonnement
  bool isLoading = true;
  bool hasSubscription = false;
  String currentPlan = "";
  DateTime? startDate;
  DateTime? endDate;

  // User information
  String? userEmail;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
    _loadUserData().then((_) {
      _fetchCsrfToken();
      fetchUserSubscription();
    });
  }

  // Charger les données de l'utilisateur depuis SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      setState(() {
        userData = jsonDecode(userJson);
        userEmail = userData?['email'];
      });
    }
  }

  // Récupérer le token CSRF
  Future<void> _fetchCsrfToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie != null) {
        final response = await http.get(
          Uri.parse('$apiBaseUrl/auth/get-csrf-token/'),
          headers: {
            'Cookie': "sessionid=$sessionCookie",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final csrfToken = data['csrfToken'];

          // Extraire le cookie CSRF
          String? csrfCookie;
          if (response.headers.containsKey('set-cookie')) {
            final cookies = response.headers['set-cookie']!.split(',');
            for (var cookie in cookies) {
              if (cookie.contains('csrftoken=')) {
                csrfCookie = cookie.split(';')[0].split('=')[1];
                break;
              }
            }
          }

          // Sauvegarder les tokens
          if (csrfToken != null) {
            await prefs.setString('csrf_token', csrfToken);
          }
          if (csrfCookie != null) {
            await prefs.setString('csrf_cookie', csrfCookie);
          }

          print('CSRF Token récupéré avec succès');
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération du token CSRF: $e');
    }
  }

  Future<void> fetchUserSubscription() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Vérifier si l'utilisateur est connecté
      if (userEmail == null) {
        setState(() {
          isLoading = false;
        });
        // Rediriger vers la page de connexion si nécessaire
        // Get.offNamed('/login');
        return;
      }

      // Obtenir le cookie de session pour l'authentification
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/payment/user-subscriptions/'),
        headers: {
          'Cookie': sessionCookie != null ? "sessionid=$sessionCookie" : "",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          hasSubscription = data['has_subscription'] ?? false;

          if (hasSubscription && data['subscription'] != null) {
            currentPlan = data['subscription']['plan_type'] ?? "";

            if (data['subscription']['start_date'] != null) {
              startDate = DateTime.parse(data['subscription']['start_date']);
            }

            if (data['subscription']['end_date'] != null) {
              endDate = DateTime.parse(data['subscription']['end_date']);
            }
          }

          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération de l\'abonnement: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception lors de la récupération de l\'abonnement: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> initDeepLinks() async {
    // Gérer les liens d'ouverture initiale
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      handleDeepLink(appLink.toString());
    }

    // Écouter les liens entrants
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri.toString());
      }
    });
  }

  // Update the handleDeepLink function to handle the case where checkout_id might be missing

  // Modification de la méthode handleDeepLink pour rediriger directement vers PaymentSuccessPage
  void handleDeepLink(String link) {
    print('Deep link received: $link');

    // Parse the URL to extract the parameters
    Uri uri = Uri.parse(link);

    // Check if this is a payment success or failure callback
    if (uri.path.contains('/payment-success')) {
      final planName = uri.queryParameters['plan'] ?? 'Standard';
      final amount = int.tryParse(uri.queryParameters['amount'] ?? '0') ?? 0;
      final checkoutId = uri.queryParameters['checkout_id'];

      // Log the parameters
      print('Deep link parameters: plan=$planName, amount=$amount, checkout_id=$checkoutId');

      // If checkout_id is missing, we can't process the payment
      if (checkoutId == null || checkoutId.isEmpty) {
        print('Warning: checkout_id is missing in the deep link');
        // Show an error message to the user
        Get.snackbar(
          'Erreur',
          'Impossible de traiter le paiement: ID de transaction manquant',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }

      // Refresh subscription data
      fetchUserSubscription();

      // Au lieu d'utiliser Get.offNamed, créez directement une instance de PaymentSuccessPage
      // et naviguez vers cette page
      Get.off(() => PaymentSuccessPage(
        planName: planName,
        amount: amount,
        checkoutId: checkoutId,
      ));
    } else if (uri.path.contains('/payment-failed')) {
      // Navigate to the failure page
      Get.offNamed('/payment-failed');
    }
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
          backgroundColor: primaryColorTheme,
          elevation: 0,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            "Abonnements",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: Text('Aide'.tr),
                        content: Text(
                            'Besoin d\'aide avec les abonnements et les payments ? Contactez notre support technique au 0540274628'
                                .tr),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                                'Fermer'.tr, style: TextStyle(color: primaryColorTheme)),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Gérez vos abonnements",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choisissez votre plan d'abonnement mensuel pour accéder à toutes les fonctionnalités.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Contenu principal avec carte arrondie blanche
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColorTheme,
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 20),
                        child: Text(
                          "Forfaits disponibles",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF333333),
                          ),
                        ),
                      ),

                      _buildSubscriptionCard(
                        context: context,
                        title: "Beginner",
                        price: "2500 DA / mois",
                        description: "Ahmini app beginners, this one's for you",
                        features: [
                          "• Lorem Ipsum",
                          "• Lorem Ipsum",
                          "• Lorem Ipsum",
                        ],
                        isCurrentPlan: currentPlan == "Beginner",
                        buttonText: currentPlan == "Beginner"
                            ? "Forfait actuel"
                            : "Passer à Beginner",
                        onPressed: () {
                          if (currentPlan != "Beginner") {
                            _processApiPayment(context, "Beginner", 2500);
                          }
                        },
                        amount: 2500,
                        startDate: currentPlan == "Beginner" ? startDate : null,
                        endDate: currentPlan == "Beginner" ? endDate : null,
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                      ),
                      const SizedBox(height: 16),
                      _buildSubscriptionCard(
                        context: context,
                        title: "Premium",
                        price: "6000 DA / mois",
                        description: "Explore more features",
                        features: [
                          "• Lorem Ipsum",
                          "• Lorem Ipsum",
                          "• Lorem Ipsum",
                        ],
                        isCurrentPlan: currentPlan == "Premium",
                        buttonText: currentPlan == "Premium"
                            ? "Forfait actuel"
                            : "Passer à Premium",
                        onPressed: () {
                          if (currentPlan != "Premium") {
                            _processApiPayment(context, "Premium", 6000);
                          }
                        },
                        amount: 6000,
                        startDate: currentPlan == "Premium" ? startDate : null,
                        endDate: currentPlan == "Premium" ? endDate : null,
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                      ),
                      const SizedBox(height: 16),
                      _buildSubscriptionCard(
                        context: context,
                        title: "Extra",
                        price: "8000 DA / mois",
                        description: "Exclusive features, premium content and VIP service",
                        features: [
                          "• Lorem Ipsum",
                          "• Lorem Ipsum",
                          "• Lorem Ipsum",
                        ],
                        isCurrentPlan: currentPlan == "Extra",
                        buttonText: currentPlan == "Extra"
                            ? "Forfait actuel"
                            : "Passer à Extra",
                        onPressed: () {
                          if (currentPlan != "Extra") {
                            _processApiPayment(context, "Extra", 8000);
                          }
                        },
                        amount: 8000,
                        startDate: currentPlan == "Extra" ? startDate : null,
                        endDate: currentPlan == "Extra" ? endDate : null,
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required bool isCurrentPlan,
    required String buttonText,
    required VoidCallback onPressed,
    required int amount,
    required bool isDark,
    required Color primaryColorTheme,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final bgColor = isDark ? Color.fromARGB(255, 50, 30, 30) : Color.fromARGB(255, 248, 230, 230);
    final textColor = isDark ? Colors.white : Color(0xFF333333);
    final subtextColor = isDark ? Colors.white70 : Colors.grey.shade800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColorTheme.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              isCurrentPlan
                  ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Actif",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                  ),
                ),
              );
            }).toList(),
          ),

          // Afficher les dates d'abonnement si c'est le forfait actuel
          if (isCurrentPlan && startDate != null && endDate != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16,
                          color: isDark ? Colors.white70 : Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        "Date de paiement: ${dateFormat.format(startDate)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.event_available, size: 16,
                          color: isDark ? Colors.white70 : Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        "Expire le: ${dateFormat.format(endDate)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan
                    ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                    : primaryColorTheme,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isCurrentPlan ? 0 : 2,
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentPlan
                      ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processApiPayment(BuildContext context, String planName, int amount) async {
    // Vérifier si l'utilisateur est connecté
    if (userEmail == null) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Connexion requise'),
              content: const Text(
                  'Vous devez être connecté pour souscrire à un abonnement.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                      'Annuler', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Rediriger vers la page de connexion
                    Get.toNamed('/login');
                  },
                  child: const Text('Se connecter',
                      style: TextStyle(color: Color(0xFFBE3144))),
                ),
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFBE3144)),
                const SizedBox(height: 20),
                Text('Préparation du paiement pour $planName...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Obtenir le cookie de session et le token CSRF
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      String? csrfToken = prefs.getString('csrf_token');
      String? csrfCookie = prefs.getString('csrf_cookie');

      // Si le token CSRF n'est pas disponible, récupérez-le
      if (csrfCookie == null || csrfToken == null) {
        try {
          final csrfResponse = await http.get(
            Uri.parse('$apiBaseUrl/auth/get-csrf-token/'),
            headers: {
              'Cookie': sessionCookie != null ? "sessionid=$sessionCookie" : "",
            },
          );

          if (csrfResponse.statusCode == 200) {
            final csrfData = jsonDecode(csrfResponse.body);
            csrfToken = csrfData['csrfToken'];

            // Extraire le cookie CSRF de l'en-tête Set-Cookie
            if (csrfResponse.headers.containsKey('set-cookie')) {
              final cookies = csrfResponse.headers['set-cookie']!.split(',');
              for (var cookie in cookies) {
                if (cookie.contains('csrftoken=')) {
                  csrfCookie = cookie.split(';')[0].split('=')[1];
                  break;
                }
              }
            }

            // Sauvegarder les tokens CSRF
            if (csrfToken != null) {
              await prefs.setString('csrf_token', csrfToken);
            }
            if (csrfCookie != null) {
              await prefs.setString('csrf_cookie', csrfCookie);
            }
          }
        } catch (e) {
          print('Erreur lors de la récupération du token CSRF: $e');
        }
      }

      // Get user info from userData
      final String? userName = userData?['first_name'] != null &&
          userData?['last_name'] != null
          ? "${userData?['first_name']} ${userData?['last_name']}"
          : null;
      final String? userPhone = userData?['phone_number'];

      // Create checkout using your Django API
      final url = Uri.parse('$apiBaseUrl/payment/checkout/');

      // Get the app's package name for deep linking
      final String appScheme = 'ahminiapp'; // Replace with your actual app scheme

      // Préparer les en-têtes avec les cookies de session et CSRF
      final headers = {
        "Content-Type": "application/json",
      };

      if (sessionCookie != null) {
        headers['Cookie'] = "sessionid=$sessionCookie";
        if (csrfCookie != null) {
          headers['Cookie'] = "; csrftoken=$csrfCookie";
        }
      }

      if (csrfToken != null) {
        headers['X-CSRFToken'] = csrfToken;
      }

      print('En-têtes de la requête: $headers');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "amount": amount,
          "payment_method": "edahabia",
          "description": "Abonnement $planName - Ahmini App",
          "locale": "fr",
          "plan_name": planName,
          "customer_name": userName,
          "customer_email": userEmail,
          "customer_phone": userPhone,
          "app_scheme": appScheme,
        }),
      );

      // Close loading dialog
      Navigator.pop(context);

      print('Réponse du serveur: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final checkoutUrl = responseData['checkout_url'];
        final entityId = responseData['entity_id'];

        if (checkoutUrl != null) {
          // Launch the Chargily checkout URL in browser
          final Uri uri = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            // Show info dialog after launching browser
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: const Text('Redirection vers Chargily Pay'),
                      content: Text(
                        'Vous allez être redirigé vers la page de paiement sécurisée Chargily Pay pour finaliser votre abonnement $planName. Après le paiement, vous serez redirigé vers l\'application.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                              'OK', style: TextStyle(color: Color(0xFFBE3144))),
                        ),
                      ],
                    ),
              );
            }
          } else {
            throw Exception("Impossible d'ouvrir l'URL de paiement");
          }
        } else {
          throw Exception("URL de paiement non trouvée dans la réponse");
        }
      } else {
        throw Exception(
            "Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: const Text('Erreur de paiement'),
                content: Text(
                    'Une erreur est survenue lors de la préparation du paiement: ${e.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                        'Fermer', style: TextStyle(color: Color(0xFFBE3144))),
                  ),
                ],
              ),
        );
      }
    }
  }
}

// Page pour gérer le succès du paiement
class PaymentSuccessPage extends StatefulWidget {
  final String planName;
  final int amount;
  final String? checkoutId;

  const PaymentSuccessPage({
    Key? key,
    required this.planName,
    required this.amount,
    this.checkoutId
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isProcessing = true;
  bool _isSuccess = false;
  String _message = "Finalisation de votre abonnement...";
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    if (widget.checkoutId != null && widget.checkoutId!.isNotEmpty) {
      _processPayment();
    } else {
      setState(() {
        _isProcessing = false;
        _isSuccess = false;
        _message = "Erreur: ID de paiement manquant";
      });
    }
  }

  Future<void> _processPayment() async {
    try {
      // Get the API base URL
      final String apiBaseUrl = 'http://10.0.2.2:8000/api';

      // Get session cookie for authentication
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      print('Processing payment for checkout ID: ${widget.checkoutId}');

      // Process the payment
      final response = await http.post(
        Uri.parse('$apiBaseUrl/payment/process-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie != null ? "sessionid=$sessionCookie" : "",
        },
        body: jsonEncode({
          'checkout_id': widget.checkoutId,
        }),
      );

      print('Payment processing response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
          _message = "Votre abonnement ${widget.planName} est activé !";
        });
      } else {
        String errorMessage = "Une erreur est survenue";
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['error'] ?? errorMessage;
        } catch (e) {
          // Ignore JSON parsing errors
        }

        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _message = "Erreur: $errorMessage";
        });
      }
    } catch (e) {
      print('Error processing payment: $e');
      setState(() {
        _isProcessing = false;
        _isSuccess = false;
        _message = "Erreur: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          title: const Text('Paiement'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing)
                  CircularProgressIndicator(color: primaryColorTheme)
                else if (_isSuccess)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  )
                else
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 100,
                  ),
                const SizedBox(height: 30),
                Text(
                  _message,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "Montant: ${widget.amount} DA",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey.shade300 : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to main app
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorTheme,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

