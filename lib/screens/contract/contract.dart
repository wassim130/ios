import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:ahmini/theme.dart';
import 'package:ahmini/controllers/theme_controller.dart';

class Contract {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String clientName;
  final String freelancerName;
  final String documentUrl;
  final bool signedByClient;
  final bool signedByFreelancer;
  final bool canSign;
  final String? signingUrl;

  Contract({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.clientName,
    required this.freelancerName,
    required this.documentUrl,
    required this.signedByClient,
    required this.signedByFreelancer,
    required this.canSign,
    this.signingUrl,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      clientName: json['client_name'] ?? 'Non spécifié',
      freelancerName: json['freelancer_name'] ?? 'Non spécifié',
      documentUrl: json['document_url'] ?? '',
      signedByClient: json['signed_by_client'] ?? false,
      signedByFreelancer: json['signed_by_freelancer'] ?? false,
      canSign: json['can_sign'] ?? false,
      signingUrl: json['signing_url'],
    );
  }
}

class ContractService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/contracts';

  static Future<List<Contract>> getActiveContracts() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    if (sessionCookie == null) {
      throw Exception('Session cookie non trouvé');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/active/'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': "sessionid=$sessionCookie",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> contractsJson = json.decode(response.body);
      return contractsJson.map((json) => Contract.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des contrats: ${response.statusCode}');
    }
  }

  static Future<List<Contract>> getAllContracts() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    if (sessionCookie == null) {
      throw Exception('Session cookie non trouvé');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/all/'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': "sessionid=$sessionCookie",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> contractsJson = json.decode(response.body);
      return contractsJson.map((json) => Contract.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des contrats: ${response.statusCode}');
    }
  }

  static Future<Contract> signContract(int contractId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final csrfToken = prefs.getString('csrf_token');

    if (sessionCookie == null || csrfToken == null) {
      throw Exception('Session cookie ou CSRF token non trouvé');
    }

    try {
      // Print debug information
      print('Sending POST request to sign contract $contractId');
      print('Headers: sessionid=$sessionCookie; csrftoken=$csrfToken');

      final response = await http.post(
        Uri.parse('$baseUrl/$contractId/sign/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': "sessionid=$sessionCookie; csrftoken=$csrfToken",
          'X-CSRFToken': csrfToken,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final contract = Contract.fromJson(responseData);

        // Check if there's a signing URL to redirect to
        if (contract.signingUrl != null && contract.signingUrl!.isNotEmpty) {
          // Launch the signing URL in browser
          final signingUrl = contract.signingUrl!;

          // Add a delay before launching the URL to ensure the backend has time to prepare the session
          await Future.delayed(Duration(milliseconds: 500));

          if (await canLaunchUrl(Uri.parse(signingUrl))) {
            await launchUrl(
              Uri.parse(signingUrl),
              mode: LaunchMode.externalApplication,
              webViewConfiguration: WebViewConfiguration(
                enableJavaScript: true,
                enableDomStorage: true,
              ),
            );
          } else {
            throw Exception('Impossible d\'ouvrir l\'URL de signature: $signingUrl');
          }
        }

        return contract;
      } else if (response.statusCode == 405) {
        // Handle Method Not Allowed error
        throw Exception('Méthode non autorisée. Vérifiez la configuration du serveur.');
      } else if (response.statusCode == 401) {
        // Handle authentication error
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        // Parse error message from response if available
        String errorMessage = 'Échec de la signature';
        try {
          final errorData = json.decode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (e) {
          // If parsing fails, use the status code
          errorMessage = 'Échec de la signature: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error in signContract: $e');
      // Rethrow the exception to be handled by the UI
      rethrow;
    }
  }



  static Future<void> downloadContract(String documentUrl) async {
    if (documentUrl.isEmpty) {
      throw Exception('URL du document non disponible');
    }

    if (await canLaunchUrl(Uri.parse(documentUrl))) {
      await launchUrl(Uri.parse(documentUrl), mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir $documentUrl');
    }
  }
}

class ContractsPage extends StatefulWidget {
  const ContractsPage({Key? key}) : super(key: key);

  @override
  _ContractsPageState createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> with SingleTickerProviderStateMixin {
  late Future<List<Contract>> _contractsFuture;
  final ThemeController themeController = Get.find<ThemeController>();
  late TabController _tabController;
  bool _showAllContracts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _refreshContracts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _showAllContracts = _tabController.index == 1;
        _refreshContracts();
      });
    }
  }

  void _refreshContracts() {
    setState(() {
      _contractsFuture = _showAllContracts
          ? ContractService.getAllContracts()
          : ContractService.getActiveContracts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black;
      final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          title: const Text('Mes Contrats', style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColorTheme,
          iconTheme: IconThemeData(color: Colors.white), // Ceci affectera l'icône de retour
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white), // Icône de rechargement en blanc
              onPressed: _refreshContracts,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Actifs'),
              Tab(text: 'Tous'),
            ],
          ),
        ),
        body: FutureBuilder<List<Contract>>(
          future: _contractsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryColorTheme),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Erreur: ${snapshot.error}',
                      style: TextStyle(fontSize: 16, color: textColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshContracts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorTheme,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 60, color: subTextColor),
                    SizedBox(height: 16),
                    Text(
                      _showAllContracts ? 'Aucun contrat trouvé' : 'Aucun contrat actif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _showAllContracts
                          ? 'Vous n\'avez pas encore de contrats'
                          : 'Vous n\'avez pas de contrats actifs pour le moment',
                      style: TextStyle(
                        fontSize: 16,
                        color: subTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final contract = snapshot.data![index];
                return ContractCard(
                  contract: contract,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContractDetailPage(contract: contract),
                      ),
                    ).then((_) => _refreshContracts());
                  },
                  isDark: isDark,
                  primaryColorTheme: primaryColorTheme,
                );
              },
            );
          },
        ),
      );
    });
  }
}

class ContractCard extends StatelessWidget {
  final Contract contract;
  final VoidCallback onTap;
  final bool isDark;
  final Color primaryColorTheme;

  const ContractCard({
    Key? key,
    required this.contract,
    required this.onTap,
    required this.isDark,
    required this.primaryColorTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      contract.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(contract.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(contract.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: subTextColor),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Client: ${contract.clientName}',
                      style: TextStyle(fontSize: 14, color: subTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.work_outline, size: 16, color: subTextColor),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Freelancer: ${contract.freelancerName}',
                      style: TextStyle(fontSize: 14, color: subTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: subTextColor),
                  SizedBox(width: 4),
                  Text(
                    'Du ${DateFormat('dd/MM/yyyy').format(contract.startDate)} au ${DateFormat('dd/MM/yyyy').format(contract.endDate)}',
                    style: TextStyle(fontSize: 14, color: subTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${contract.amount.toStringAsFixed(2)} DA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColorTheme,
                    ),
                  ),
                  TextButton(
                    onPressed: onTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Voir plus', style: TextStyle(color: primaryColorTheme)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: primaryColorTheme),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
      case 'active':
        return Colors.green;
      case 'en attente':
      case 'pending':
      case 'sent':
        return Colors.orange;
      case 'terminé':
      case 'completed':
        return Colors.blue;
      case 'annulé':
      case 'cancelled':
        return Colors.red;
      case 'draft':
        return Colors.grey;
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
      case 'sent':
        return 'Envoyé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      case 'draft':
        return 'Brouillon';
      default:
        return status;
    }
  }
}

class ContractDetailPage extends StatefulWidget {
  final Contract contract;

  const ContractDetailPage({
    Key? key,
    required this.contract,
  }) : super(key: key);

  @override
  _ContractDetailPageState createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<ContractDetailPage> {
  late Contract _contract;
  bool _isSigning = false;
  bool _isDownloading = false;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
  }

  Future<void> _signContract() async {
    setState(() {
      _isSigning = true;
    });

    try {
      final updatedContract = await ContractService.signContract(_contract.id);
      setState(() {
        _contract = updatedContract;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redirection vers la page de signature...'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la signature: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }

  Future<void> _downloadContract() async {
    if (_contract.documentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun document disponible pour ce contrat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      await ContractService.downloadContract(_contract.documentUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : Colors.white;
      final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black;
      final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          title: const Text('Détails du Contrat'),
          backgroundColor: primaryColorTheme,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _contract.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_contract.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(_contract.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_contract.amount.toStringAsFixed(2)} DA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColorTheme,
                        ),
                      ),
                      const Divider(height: 32),
                      _buildInfoRow('Client', _contract.clientName, Icons.business, textColor, subTextColor),
                      const SizedBox(height: 12),
                      _buildInfoRow('Freelancer', _contract.freelancerName, Icons.person, textColor, subTextColor),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Date de début',
                        DateFormat('dd MMMM yyyy').format(_contract.startDate),
                        Icons.calendar_today,
                        textColor,
                        subTextColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Date de fin',
                        DateFormat('dd MMMM yyyy').format(_contract.endDate),
                        Icons.event,
                        textColor,
                        subTextColor,
                      ),
                      const SizedBox(height: 12),
                      _buildSignatureStatus(textColor, subTextColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _contract.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadContract,
                  icon: _isDownloading
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(Icons.download, color: Colors.white),
                  label: Text(
                    _isDownloading ? 'Téléchargement...' : 'Télécharger le contrat',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColorTheme,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_contract.canSign) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSigning ? null : _signContract,
                    icon: _isSigning
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Icon(Icons.edit, color: Colors.white),
                    label: Text(
                      _isSigning ? 'Signature en cours...' : 'Signer le contrat',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: subTextColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureStatus(Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut de signature',
          style: TextStyle(
            fontSize: 14,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              _contract.signedByClient ? Icons.check_circle : Icons.circle,
              color: _contract.signedByClient ? Colors.green : subTextColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text('Client', style: TextStyle(color: textColor)),
            const Spacer(),
            Icon(
              _contract.signedByFreelancer ? Icons.check_circle : Icons.circle,
              color: _contract.signedByFreelancer ? Colors.green : subTextColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text('Freelancer', style: TextStyle(color: textColor)),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
      case 'active':
        return Colors.green;
      case 'en attente':
      case 'pending':
      case 'sent':
        return Colors.orange;
      case 'terminé':
      case 'completed':
        return Colors.blue;
      case 'annulé':
      case 'cancelled':
        return Colors.red;
      case 'draft':
        return Colors.grey;
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
      case 'sent':
        return 'Envoyé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      case 'draft':
        return 'Brouillon';
      default:
        return status;
    }
  }
}
