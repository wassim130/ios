import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({Key? key}) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool isLoading = true;
  String planName = '';
  String amount = '';
  String checkoutId = '';
  Map<String, dynamic> subscriptionDetails = {};

  @override
  void initState() {
    super.initState();
    // Récupérer les arguments passés à cette page
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null) {
      planName = args['plan'] ?? '';
      amount = args['amount'] ?? '0';
      checkoutId = args['checkout_id'] ?? '';

      // Charger les détails de l'abonnement
      _loadSubscriptionDetails();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSubscriptionDetails() async {
    try {
      // Appel API pour obtenir les détails de l'abonnement
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/payment/subscription-details/$checkoutId'),
        headers: {
          "Content-Type": "application/json",
          // Ajoutez des en-têtes d'authentification si nécessaire
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          subscriptionDetails = data;
          isLoading = false;
        });
      } else {
        // En cas d'erreur, utiliser les données de base
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des détails: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFBE3144),
        title: const Text('Paiement réussi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE3144)))
          : _buildSuccessContent(),
    );
  }

  Widget _buildSuccessContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Votre abonnement $planName est activé !',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Merci pour votre paiement de $amount DA',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildSubscriptionDetailsCard(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page d'accueil
                Get.offAllNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE3144),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Retour à l\'accueil',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 230, 230),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails de votre abonnement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 15),
          _buildDetailRow('Plan', planName),
          _buildDetailRow('Montant', '$amount DA'),
          _buildDetailRow('Date d\'activation', _formatDate(DateTime.now())),
          _buildDetailRow('Statut', 'Actif'),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Fonctionnalités incluses:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureItem('Accès à toutes les fonctionnalités premium'),
          _buildFeatureItem('Support prioritaire'),
          _buildFeatureItem('Mises à jour exclusives'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFFBE3144),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

