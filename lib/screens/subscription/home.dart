import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
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

class Offer {
  final String id;
  final String name;
  final String description;
  final int price;
  final int durationDays;
  final List<String> features;

  Offer({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: json['price'],
      durationDays: json['duration_days'],
      features: List<String>.from(json['features']),
    );
  }
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final String apiBaseUrl = 'http://10.0.2.2:8000/api';
  final _appLinks = AppLinks();
  final ThemeController themeController = Get.find<ThemeController>();
  StreamSubscription<Uri>? _linkSubscription;

  bool isLoading = true;
  bool hasSubscription = false;
  String currentPlan = "";
  DateTime? startDate;
  DateTime? endDate;
  bool isSubscriptionActive = false;

  String? userEmail;
  Map<String, dynamic>? userData;

  List<Offer> offers = [];
  bool isLoadingOffers = true;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchCsrfToken();
      fetchUserSubscription();
      fetchOffers();
    });
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    try {
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri.toString());
        }
      });

      final appLink = await _appLinks.getInitialAppLink();
      if (appLink != null) {
        _handleDeepLink(appLink.toString());
      }
    } catch (e) {
      print('Error initializing deep links: $e');
    }
  }

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

          if (csrfToken != null) {
            await prefs.setString('csrf_token', csrfToken);
          }
          if (csrfCookie != null) {
            await prefs.setString('csrf_cookie', csrfCookie);
          }
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
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      print('voici le cookie $sessionCookie');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/payment/user-subscriptions/'),
        headers: {
          'Content-Type': 'application/json'.tr,
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Subscription data: $data');

        setState(() {
          hasSubscription = data['has_subscription'] ?? false;
          currentPlan = "";
          isSubscriptionActive = false;

          if (data['subscription'] != null) {
            currentPlan = data['subscription']['plan_type'] ?? "";
            isSubscriptionActive = data['subscription']['is_active'] ?? false;

            if (data['subscription']['start_date'] != null) {
              startDate = DateTime.parse(data['subscription']['start_date']);
            }
            if (data['subscription']['end_date'] != null) {
              endDate = DateTime.parse(data['subscription']['end_date']);
            }

            if (data['subscription']['offer_details'] != null) {
              final offerDetails = data['subscription']['offer_details'];
              final currentOffer = Offer(
                id: offerDetails['id']?.toString() ?? '', // Correction ici
                name: offerDetails['name'] ?? currentPlan,
                description: offerDetails['description'] ?? '',
                price: offerDetails['price'] ?? 0,
                durationDays: offerDetails['duration_days'] ?? 30,
                features: List<String>.from(offerDetails['features'] ?? []),
              );

              final index = offers.indexWhere((o) => o.name == currentPlan);
              if (index != -1) {
                offers[index] = currentOffer;
              } else {
                offers.insert(0, currentOffer);
              }
            }
          }

          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération de l\'abonnement: ${response.statusCode}');
        setState(() {
          isLoading = false;
          hasSubscription = false;
        });
      }
    } catch (e) {
      print('Exception lors de la récupération de l\'abonnement: $e');
      setState(() {
        isLoading = false;
        hasSubscription = false;
      });
    }
  }

  Future<void> fetchOffers() async {
    setState(() {
      isLoadingOffers = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/payment/offers/'),
        headers: {
          'Cookie': sessionCookie != null ? "sessionid=$sessionCookie" : "",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          offers = data.map((json) => Offer.fromJson(json)).toList();
          isLoadingOffers = false;
        });
      } else {
        throw Exception('Failed to load offers');
      }
    } catch (e) {
      setState(() {
        isLoadingOffers = false;
      });
      print('Error fetching offers: $e');
    }
  }

  void _handleDeepLink(String link) async {
    print('Deep link received: $link');

    Uri uri = Uri.parse(link);

    if (uri.host == 'payment-success' || uri.path.contains('/payment-success')) {
      final planName = uri.queryParameters['plan'] ?? 'Standard';
      final amount = int.tryParse(uri.queryParameters['amount'] ?? '0') ?? 0;
      final checkoutId = uri.queryParameters['checkout_id'];

      print('Deep link parameters: plan=$planName, amount=$amount, checkout_id=$checkoutId');

      if (checkoutId == null || checkoutId.isEmpty) {
        print('Warning: checkout_id is missing in the deep link');
        Get.snackbar(
          'Erreur',
          'Impossible de traiter le paiement: ID de transaction manquant',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String processedKey = 'processed_payment_$checkoutId';
      final bool alreadyProcessed = prefs.getBool(processedKey) ?? false;

      if (alreadyProcessed) {
        print('Ce paiement a déjà été traité');
        return;
      }

      await prefs.setBool(processedKey, true);

      Get.dialog(
        AlertDialog(
          title: Text('Traitement du paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Vérification du statut de votre paiement...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Annuler'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      try {
        await _verifyPaymentStatus(checkoutId);
        await fetchUserSubscription();

        Get.back();

        if (mounted) {
          Get.off(() => PaymentSuccessPage(
            planName: planName,
            amount: amount,
            checkoutId: checkoutId,
          ));
        }
      } catch (error) {
        Get.back();
        Get.snackbar(
          'Erreur',
          'Erreur lors du traitement du paiement: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } else if (uri.host == 'payment-failed' || uri.path.contains('/payment-failed')) {
      Get.offNamed('/payment-failed');
    }
  }

  Future<void> _verifyPaymentStatus(String checkoutId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/payment/process-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie != null ? "sessionid=$sessionCookie" : "",
        },
        body: jsonEncode({
          'checkout_id': checkoutId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to verify payment status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verifying payment: $e');
    }
  }

  Widget _buildOfferCards() {
    if (isLoadingOffers) {
      return Center(child: CircularProgressIndicator());
    }

    if (offers.isEmpty) {
      return Center(child: Text('No subscription offers available'));
    }

    List<Offer> displayOffers = List.from(offers);

    if (hasSubscription && currentPlan.isNotEmpty &&
        !offers.any((o) => o.name == currentPlan)) {
      displayOffers.insert(0, Offer(
        id: '', // Offre actuelle sans ID
        name: currentPlan,
        description: 'Votre forfait actuel',
        price: 0,
        durationDays: 0,
        features: ['Forfait actuellement actif'],
      ));
    }

    return Column(
      children: displayOffers.map((offer) {
        final isCurrent = currentPlan == offer.name;
        final isExpired = isCurrent && endDate != null && endDate!.isBefore(DateTime.now());

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildSubscriptionCard(
            context: context,
            offer: offer,
            isCurrentPlan: isCurrent,
            isExpired: isExpired,
            onPressed: () {
              if (offer.id.isEmpty) {
                Get.snackbar('Erreur', 'Impossible de renouveler: ID de l\'offre manquant');
              } else if (!isCurrent || isExpired) {
                _processApiPayment(context, offer);
              }
            },
            isDark: themeController.isDarkMode.value,
            primaryColorTheme: themeController.isDarkMode.value ? darkPrimaryColor : primaryColor,
            startDate: isCurrent ? startDate : null,
            endDate: isCurrent ? endDate : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required Offer offer,
    required bool isCurrentPlan,
    required bool isExpired,
    required VoidCallback onPressed,
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
        border: Border.all(
          color: isExpired
              ? Colors.red.withOpacity(0.5)
              : isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
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
                    offer.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${offer.price} DA / mois",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColorTheme.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              if (isCurrentPlan && !isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                ),
              if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Expiré",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offer.description,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: offer.features.map((feature) {
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

          if (isCurrentPlan && startDate != null && endDate != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isExpired
                      ? Colors.red.withOpacity(0.3)
                      : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
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
                        isExpired
                            ? "A expiré le: ${dateFormat.format(endDate)}"
                            : "Expire le: ${dateFormat.format(endDate)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isExpired ? Colors.red : subtextColor,
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
              onPressed: isCurrentPlan && !isExpired ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan && !isExpired
                    ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                    : primaryColorTheme,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isCurrentPlan && !isExpired ? 0 : 2,
              ),
              child: Text(
                isExpired
                    ? "Renouveler"
                    : isCurrentPlan
                    ? "Forfait actuel"
                    : "Souscrire",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentPlan && !isExpired
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

  Future<void> _processApiPayment(BuildContext context, Offer offer) async {
    if (userEmail == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connexion requise'),
          content: const Text('Vous devez être connecté pour souscrire à un abonnement.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Get.toNamed('/login');
              },
              child: const Text('Se connecter', style: TextStyle(color: Color(0xFFBE3144))),
            ),
          ],
        ),
      );
      return;
    }

    if (offer.id.isEmpty) {
      Get.snackbar('Erreur', 'ID de l\'offre manquant, impossible de procéder au paiement');
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
                Text('Préparation du paiement pour ${offer.name}...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      String? csrfToken = prefs.getString('csrf_token');
      String? csrfCookie = prefs.getString('csrf_cookie');

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

            if (csrfResponse.headers.containsKey('set-cookie')) {
              final cookies = csrfResponse.headers['set-cookie']!.split(',');
              for (var cookie in cookies) {
                if (cookie.contains('csrftoken=')) {
                  csrfCookie = cookie.split(';')[0].split('=')[1];
                  break;
                }
              }
            }

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

      final String? userName = userData?['first_name'] != null &&
          userData?['last_name'] != null
          ? "${userData?['first_name']} ${userData?['last_name']}"
          : null;
      final String? userPhone = userData?['phone_number'];

      final url = Uri.parse('$apiBaseUrl/payment/public-checkout/');
      final String appScheme = 'ahminiapp';

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

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "offer_id": offer.id,
          "amount": offer.price,
          "payment_method": "edahabia",
          "locale": "fr",
          "customer_name": userName,
          "customer_email": userEmail,
          "customer_phone": userPhone,
          "app_scheme": appScheme,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final checkoutUrl = responseData['checkout_url'];
        final entityId = responseData['entity_id'];

        if (checkoutUrl != null) {
          final Uri uri = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Redirection vers Chargily Pay'),
                  content: Text(
                    'Vous allez être redirigé vers la page de paiement sécurisée Chargily Pay pour finaliser votre abonnement ${offer.name}. Après le paiement, vous serez redirigé vers l\'application.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(color: Color(0xFFBE3144))),
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
        throw Exception("Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur de paiement'),
            content: Text('Une erreur est survenue: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer', style: TextStyle(color: Color(0xFFBE3144))),
              ),
            ],
          ),
        );
      }
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
                  builder: (context) => AlertDialog(
                    title: Text('Aide'.tr),
                    content: Text(
                        'Besoin d\'aide avec les abonnements et les payments ? Contactez notre support technique au 0540274628'.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'.tr, style: TextStyle(color: primaryColorTheme)),
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
                   Text(
                    "Gérez vos abonnements".tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choisissez votre plan d'abonnement mensuel pour accéder à toutes les fonctionnalités.".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
                child: isLoading || isLoadingOffers
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
                          "Forfaits disponibles".tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF333333),
                          ),
                        ),
                      ),
                      _buildOfferCards(),
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
}

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
  String _message = "Finalisation de votre abonnement...".tr;
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
        _message = "Erreur: ID de paiement manquant".tr;
      });
    }
  }

  Future<void> _processPayment() async {
    try {
      final String apiBaseUrl = 'http://10.0.2.2:8000/api';

      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      print('Processing payment for checkout ID: ${widget.checkoutId}');

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
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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