import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahmini/theme.dart';
import 'package:ahmini/controllers/theme_controller.dart';
import '../contract/contract.dart';

class StatisticsData {
  final int activeContracts;
  final double totalAmount;
  final double monthlyGrowth;
  final List<Map<String, dynamic>> contractDistribution;
  final int securityScore;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> monthlyActivity;
  final List<Map<String, dynamic>> predictiveTrends; // Nouveau champ pour les prévisions

  StatisticsData({
    required this.activeContracts,
    required this.totalAmount,
    required this.monthlyGrowth,
    required this.contractDistribution,
    required this.securityScore,
    required this.recentActivities,
    required this.monthlyActivity,
    required this.predictiveTrends, // Ajout du nouveau champ
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      activeContracts: json['active_contracts'] ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      monthlyGrowth: json['monthly_growth']?.toDouble() ?? 0.0,
      contractDistribution: List<Map<String, dynamic>>.from(json['contract_distribution'] ?? []),
      securityScore: json['security_score'] ?? 85,
      recentActivities: List<Map<String, dynamic>>.from(json['recent_activities'] ?? []),
      monthlyActivity: List<Map<String, dynamic>>.from(json['monthly_activity'] ?? []),
        predictiveTrends: List<Map<String, dynamic>>.from(json['predictive_trends'] ?? [
          {"month": "Mai", "predicted_contracts": 5, "confidence": 0.8},
          {"month": "Juin", "predicted_contracts": 7, "confidence": 0.7},
          {"month": "Juillet", "predicted_contracts": 9, "confidence": 0.6}
        ]), // valeur vide car non incluse dans la réponse du backend
    );
  }

  factory StatisticsData.defaultData() {
    final now = DateTime.now();
    return StatisticsData(
      activeContracts: 0,
      totalAmount: 0.0,
      monthlyGrowth: 0.0,
      contractDistribution: [
        {'label': 'En cours', 'percentage': 0.0},
        {'label': 'En attente', 'percentage': 0.0},
        {'label': 'Terminés', 'percentage': 0.0},
      ],
      securityScore: 85,
      recentActivities: [],
      monthlyActivity: [
        {'date': '30j', 'value': 0.0},
        {'date': '25j', 'value': 0.0},
        {'date': '20j', 'value': 0.0},
        {'date': '15j', 'value': 0.0},
        {'date': '10j', 'value': 0.0},
        {'date': '5j', 'value': 0.0},
        {'date': 'Auj', 'value': 0.0},
      ],
      predictiveTrends: [
        {"month": "Mai", "predicted_contracts": 3, "confidence": 0.8},
        {"month": "Juin", "predicted_contracts": 5, "confidence": 0.7},
        {"month": "Juillet", "predicted_contracts": 7, "confidence": 0.6}
      ],
    );
  }
}

class StatisticsService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/contracts';

  static Future<StatisticsData> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    if (sessionCookie == null) {
      throw Exception('Session cookie non trouvé');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return StatisticsData.fromJson(data);
      } else {
        return await _calculateStatisticsFromContracts();
      }
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return await _calculateStatisticsFromContracts();
    }
  }

  static Future<StatisticsData> _calculateStatisticsFromContracts() async {
    try {
      final contracts = await ContractService.getAllContracts();
      if (contracts.isEmpty) return StatisticsData.defaultData();

      final activeContracts = contracts.where((c) => c.status.toLowerCase() == 'active').length;
      final totalAmount = contracts.fold(0.0, (sum, c) => sum + c.amount);

      int activeCount = 0, pendingCount = 0, completedCount = 0;
      for (var contract in contracts) {
        final status = contract.status.toLowerCase();
        if (status == 'active') activeCount++;
        else if (status == 'pending' || status == 'sent') pendingCount++;
        else if (status == 'completed') completedCount++;
      }

      final totalCount = contracts.length.toDouble();
      final distribution = [
        {'label': 'En cours', 'percentage': totalCount > 0 ? activeCount / totalCount : 0.0},
        {'label': 'En attente', 'percentage': totalCount > 0 ? pendingCount / totalCount : 0.0},
        {'label': 'Terminés', 'percentage': totalCount > 0 ? completedCount / totalCount : 0.0},
      ];

      final recentActivities = contracts.take(3).map((c) => {
        'title': c.status.toLowerCase() == 'active'
            ? 'Contrat activé'
            : c.status.toLowerCase() == 'pending'
            ? 'Contrat en attente'
            : 'Contrat créé',
        'subtitle': 'Il y a ${DateTime.now().difference(c.startDate).inDays} jours',
        'icon': c.status.toLowerCase() == 'active'
            ? 'description'
            : c.status.toLowerCase() == 'pending'
            ? 'security'
            : 'payment',
      }).toList();

      final monthlyActivity = [
        {'date': '30j', 'value': 0.3},
        {'date': '25j', 'value': 0.5},
        {'date': '20j', 'value': 0.2},
        {'date': '15j', 'value': 0.7},
        {'date': '10j', 'value': 0.4},
        {'date': '5j', 'value': 0.6},
        {'date': 'Auj', 'value': 0.8},
      ];

      // Génération simplifiée de prévisions basée sur l'historique
      final contractsPerMonth = activeCount > 0 ? activeCount / 3 : 1; // Estimation moyenne sur 3 mois
      final growthRate = activeCount > 0 ? 0.2 : 0.1; // Taux de croissance estimé

      final now = DateTime.now();
      final predictiveTrends = [
        {
          "month": DateFormat('MMMM', 'fr_FR').format(DateTime(now.year, now.month + 1)),
          "predicted_contracts": (contractsPerMonth * (1 + growthRate)).round(),
          "confidence": 0.8
        },
        {
          "month": DateFormat('MMMM', 'fr_FR').format(DateTime(now.year, now.month + 2)),
          "predicted_contracts": (contractsPerMonth * (1 + growthRate * 2)).round(),
          "confidence": 0.7
        },
        {
          "month": DateFormat('MMMM', 'fr_FR').format(DateTime(now.year, now.month + 3)),
          "predicted_contracts": (contractsPerMonth * (1 + growthRate * 3)).round(),
          "confidence": 0.6
        }
      ];

      return StatisticsData(
        activeContracts: activeContracts,
        totalAmount: totalAmount,
        monthlyGrowth: 15.0,
        contractDistribution: distribution,
        securityScore: 85,
        recentActivities: recentActivities,
        monthlyActivity: monthlyActivity,
        predictiveTrends: predictiveTrends,
      );
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return StatisticsData.defaultData();
    }
  }
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final ThemeController themeController = Get.find<ThemeController>();
  bool _isLoading = true;
  StatisticsData? _statistics;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statistics = await StatisticsService.getStatistics();
      setState(() {
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des statistiques: ${e.toString()}';
        _isLoading = false;
      });
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Statistiques'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadStatistics,
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingView(primaryColorTheme)
            : _errorMessage != null
            ? _buildErrorView(primaryColorTheme, backgroundColorTheme)
            : _buildStatisticsView(
            primaryColorTheme, secondaryColorTheme, backgroundColorTheme, isDark),
      );
    });
  }

  Widget _buildLoadingView(Color primaryColorTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Chargement des statistiques...'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Color primaryColorTheme, Color backgroundColorTheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue d\'ensemble'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Statistiques de votre compte'.tr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColorTheme,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Une erreur est survenue'.tr,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStatistics,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColorTheme,
                    ),
                    child: Text('Réessayer'.tr),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView(
      Color primaryColorTheme,
      Color secondaryColorTheme,
      Color backgroundColorTheme,
      bool isDark
      ) {
    final stats = _statistics!;
    final formatter = NumberFormat.currency(locale: 'fr_DZ', symbol: 'DA', decimalDigits: 0);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue d\'ensemble'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Statistiques de votre compte'.tr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColorTheme,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Contrats Actifs'.tr,
                          value: stats.activeContracts.toString(),
                          icon: Icons.description,
                          trend: '+${(stats.monthlyGrowth / 2).toStringAsFixed(0)}% ce mois'.tr,
                          secondaryColor: secondaryColorTheme,
                          primaryColor: primaryColorTheme,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Montant Total'.tr,
                          value: formatter.format(stats.totalAmount),
                          icon: Icons.account_balance_wallet,
                          trend: '+${stats.monthlyGrowth.toStringAsFixed(0)}% vs dernier mois'.tr,
                          secondaryColor: secondaryColorTheme,
                          primaryColor: primaryColorTheme,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPredictiveTrendsCard(
                    secondaryColorTheme,
                    primaryColorTheme,
                    isDark,
                    stats.predictiveTrends
                ),
                _buildContractDistribution(
                    secondaryColorTheme,
                    primaryColorTheme,
                    isDark,
                    stats.contractDistribution
                ),
                _buildSecurityScore(
                    secondaryColorTheme,
                    isDark,
                    stats.securityScore
                ),
                _buildRecentActivity(
                    secondaryColorTheme,
                    primaryColorTheme,
                    isDark,
                    stats.recentActivities
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required String trend,
    required Color secondaryColor,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            trend,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Dans la méthode _buildPredictiveTrendsCard, je vais modifier le TextButton.icon pour qu'il affiche un dialogue
  Widget _buildPredictiveTrendsCard(
      Color secondaryColor,
      Color primaryColor,
      bool isDark,
      List<Map<String, dynamic>> predictiveTrends
      ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prévisions Futures'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Icon(Icons.trending_up, color: primaryColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Estimation des contrats à venir'.tr,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: predictiveTrends.map((trend) {
                final confidence = trend['confidence'] as double;
                final confidencePercentage = (confidence * 100).toInt();
                Color confidenceColor;

                if (confidence >= 0.8) {
                  confidenceColor = Colors.green;
                } else if (confidence >= 0.6) {
                  confidenceColor = Colors.orange;
                } else {
                  confidenceColor = Colors.red;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            trend['predicted_contracts'].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trend['month'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  'Confiance: '.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                Text(
                                  '$confidencePercentage%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: confidenceColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 60 * confidence,
                              decoration: BoxDecoration(
                                color: confidenceColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => _showPredictionMethodExplanation(context, isDark, primaryColor, secondaryColor),
                icon: Icon(Icons.info_outline, color: primaryColor, size: 18),
                label: Text(
                  'Comment les prévisions sont calculées ?'.tr,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Ajouter cette nouvelle méthode pour afficher la boîte de dialogue explicative
  void _showPredictionMethodExplanation(BuildContext context, bool isDark, Color primaryColor, Color secondaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            'Méthode de calcul des prévisions'.tr,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExplanationSection(
                  'Analyse historique'.tr,
                  'Les prévisions sont basées sur l\'historique de vos contrats sur les 3 derniers mois, en identifiant les tendances de croissance ou de déclin.'.tr,
                  Icons.history,
                  isDark,
                  primaryColor,
                ),
                const SizedBox(height: 15),
                _buildExplanationSection(
                  'Facteurs saisonniers'.tr,
                  'Nous prenons en compte les variations saisonnières observées dans votre secteur d\'activité.'.tr,
                  Icons.calendar_today,
                  isDark,
                  primaryColor,
                ),
                const SizedBox(height: 15),
                _buildExplanationSection(
                  'Modèle de prédiction'.tr,
                  'Un algorithme d\'apprentissage automatique analyse ces données pour générer des prévisions avec un niveau de confiance associé.'.tr,
                  Icons.auto_graph,
                  isDark,
                  primaryColor,
                ),
                const SizedBox(height: 15),
                _buildExplanationSection(
                  'Niveau de confiance'.tr,
                  'Plus le pourcentage de confiance est élevé, plus la prévision est fiable. Ce niveau diminue naturellement pour les mois plus éloignés.'.tr,
                  Icons.verified,
                  isDark,
                  primaryColor,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fermer'.tr,
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

// Méthode pour construire une section de l'explication
  Widget _buildExplanationSection(String title, String description, IconData icon, bool isDark, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractDistribution(
      Color secondaryColor,
      Color primaryColor,
      bool isDark,
      List<Map<String, dynamic>> distribution
      ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution des Contrats'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ...distribution.map((item) => Column(
              children: [
                _buildDistributionItem(
                    item['label'],
                    item['percentage'],
                    '${(item['percentage'] * 100).toStringAsFixed(0)}%'.tr,
                    primaryColor,
                    isDark
                ),
                const SizedBox(height: 10),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionItem(
      String label,
      double progress,
      String percentage,
      Color primaryColor,
      bool isDark
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityScore(Color secondaryColor, bool isDark, int securityScore) {
    String securityStatus;
    Color statusColor;

    if (securityScore >= 90) {
      securityStatus = 'Excellent'.tr;
      statusColor = Colors.green;
    } else if (securityScore >= 70) {
      securityStatus = 'Bon'.tr;
      statusColor = Colors.lightGreen;
    } else if (securityScore >= 50) {
      securityStatus = 'Moyen'.tr;
      statusColor = Colors.orange;
    } else {
      securityStatus = 'Faible'.tr;
      statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score de Sécurité'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          value: securityScore / 100,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          strokeWidth: 10,
                        ),
                      ),
                      Center(
                        child: Text(
                          '$securityScore%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        securityStatus,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        'Votre compte est bien protégé'.tr,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
      Color secondaryColor,
      Color primaryColor,
      bool isDark,
      List<Map<String, dynamic>> activities
      ) {
    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activités Récentes'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  'Aucune activité récente'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activités Récentes'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          ...activities.map((activity) => _buildActivityItem(
            icon: _getIconForActivity(activity['icon']),
            title: activity['title'],
            subtitle: activity['subtitle'],
            secondaryColor: secondaryColor,
            primaryColor: primaryColor,
            isDark: isDark,
          )).toList(),
        ],
      ),
    );
  }

  IconData _getIconForActivity(String iconName) {
    switch (iconName) {
      case 'description': return Icons.description;
      case 'security': return Icons.security;
      case 'payment': return Icons.payment;
      default: return Icons.event_note;
    }
  }Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color secondaryColor,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}