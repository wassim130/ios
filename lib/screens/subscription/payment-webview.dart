import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

// Cette approche utilise un widget personnalisé qui simule une WebView
// sans dépendre de plugins externes qui pourraient causer des problèmes de compilation
class AlternativePaymentScreen extends StatefulWidget {
  final String url;
  final String planName;
  final int amount;

  const AlternativePaymentScreen({
    Key? key,
    required this.url,
    required this.planName,
    required this.amount,
  }) : super(key: key);

  @override
  State<AlternativePaymentScreen> createState() => _AlternativePaymentScreenState();
}

class _AlternativePaymentScreenState extends State<AlternativePaymentScreen> {
  bool isLoading = true;
  Timer? _timer;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    // Simuler un chargement
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    // Simuler une vérification périodique du statut de paiement
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Dans une implémentation réelle, vous feriez un appel API ici
      // pour vérifier le statut du paiement
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkPaymentStatus() {
    // Ceci est une simulation. Dans une implémentation réelle,
    // vous feriez un appel API pour vérifier le statut du paiement
    // et naviguer en conséquence.
  }

  void _completePayment(bool success) {
    if (_paymentCompleted) return;
    _paymentCompleted = true;

    if (success) {
      Navigator.pop(context);
      Get.toNamed('/payment-success', parameters: {
        'plan': widget.planName,
        'amount': widget.amount.toString(),
      });
    } else {
      Navigator.pop(context);
      Get.toNamed('/payment-failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBE3144),
        title: const Text('Paiement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Finaliser votre paiement",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Vous allez souscrire à l'abonnement ${widget.planName} pour ${widget.amount} DA par mois.",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Pour continuer, veuillez cliquer sur le bouton ci-dessous pour ouvrir la page de paiement sécurisée.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Ouvrir l'URL dans le navigateur externe
                        // mais avec une meilleure expérience utilisateur
                        _launchPaymentUrl();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE3144),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Procéder au paiement",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      "Une fois le paiement effectué, revenez à cette page et cliquez sur l'un des boutons ci-dessous:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _completePayment(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Paiement réussi"),
                      ),
                      ElevatedButton(
                        onPressed: () => _completePayment(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Paiement échoué"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFBE3144),
              ),
            ),
        ],
      ),
    );
  }

  void _launchPaymentUrl() async {
    final Uri uri = Uri.parse(widget.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Afficher un dialogue pour informer l'utilisateur
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Paiement en cours'),
            content: const Text(
              'Une fois le paiement terminé, revenez à cette application et indiquez si le paiement a réussi ou échoué.',
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
    } catch (e) {
      // Gérer l'erreur
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: Text('Impossible d\'ouvrir l\'URL de paiement: ${e.toString()}'),
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
}

