import 'package:ahmini/helper/CustomDialog/custom_dialog.dart';
import 'package:ahmini/helper/CustomDialog/loading_indicator.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/job.dart';
import '../../services/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Données temporaires pour les offres d'emploi et les candidats
  List<Map<String, dynamic>> jobOffers = [];
  int totalCandidats = 0;
  int totalPendingOffers = 0;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  void _fetchJobs() async {
    final result = await Product.fetchAll();
    isLoading = false;
    setState(() {
      if (result != null) {
        jobOffers = result;
      }
    });
  }

  // Fonction pour mettre à jour le statut d'un candidat
  void _updateApplicantStatus(
      int jobId, int jobRequestID, String status) async {
    myCustomLoadingIndicator(context);
    final s = await Product.updateStatus(jobRequestID, status);
    if (mounted) {
      Navigator.pop(context);
    }
    if (s == true) {
      setState(() {
        var job = jobOffers.firstWhere((job) => job['id'] == jobId);
        var applicant =
            job['applicants'].firstWhere((app) => app['id'] == jobRequestID);
        applicant['status'] = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Candidature ${status == 'accepted' ? 'acceptée' : 'refusée'}'.tr,
          ),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (mounted) {
      myCustomDialog(context, {
        'type': "Failed".tr,
        "message": "failed to update the job request. please try again later".tr
      });
    }
  }

  // Couleurs thématiques de l'application
  final Color accentColor = secondaryColor;
  final Color textColor = Colors.white;
  final Color cardBgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (jobOffers.isNotEmpty) {
      totalPendingOffers = 0;
      totalCandidats = 0;
      for (var job in jobOffers) {
        for (var applicant in job['applicants']) {
          if (applicant['status'] == 'pending') {
            totalPendingOffers++;
          }
          totalCandidats++;
        }
      }
    }
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Modifier Portefeuille'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Aide'.tr),
                  content: Text(
                      'Besoin d\'aide avec votre portefeuille? Contactez notre support technique au 0549819905'
                          .tr),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer'.tr,
                          style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Votre Portefeuille Professionnel'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Gérez vos offres d\'emploi et les candidatures reçues'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : RefreshIndicator(
                      color: primaryColor,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        _fetchJobs();
                      },
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(top: 20),
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats bar
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  _buildStatCard(
                                    icon: Icons.work_outline,
                                    title: 'Offres'.tr,
                                    value: '${jobOffers.length}'.tr,
                                  ),
                                  SizedBox(width: 10),
                                  _buildStatCard(
                                    icon: Icons.people_outline,
                                    title: 'Candidats'.tr,
                                    value: '$totalCandidats'.tr,
                                  ),
                                  SizedBox(width: 10),
                                  _buildStatCard(
                                    icon: Icons.check_circle_outline,
                                    title: 'En attente'.tr,
                                    value: '$totalPendingOffers'.tr,
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Offres d\'emploi'.tr,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ...jobOffers
                                .map((offer) => _buildJobOfferCard(offer))
                                .toList(),

                            SizedBox(height: 20),

                            // Add job button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOfferCard(Map<String, dynamic> offer) {
    return Card(
      color: accentColor.withValues(
        alpha: .6,
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.work, color: primaryColor),
        ),
        title: Text(
          offer['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text('${offer['applicants'].length} candidature(s)'.tr),
        children: [
          Divider(height: 2, thickness: 1, indent: 20, endIndent: 20),
          if (offer['applicants'].isEmpty)
            Padding(
                padding: const EdgeInsets.all(15),
                child: Text("Aucun candidat")),
          ...offer['applicants']
              .map<Widget>(
                  (applicant) => _buildApplicantTile(offer['id'], applicant))
              .toList(),
          if (offer['applicants'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(15),
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Ajoutez la navigation vers la page détaillée de l'offre
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Voir plus de candidatures'.tr),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicantTile(int jobId, Map<String, dynamic> applicant) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty;

    if (applicant['status'] == 'accepted'.tr) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (applicant['status'] == 'rejected'.tr) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return ListTile(
      leading: CircleAvatar(
          backgroundColor: accentColor,
          child: Image.network(
            "$httpURL${applicant['image']}",
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) => Text(
              applicant['name'][0],
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          )),
      title: Text(
        applicant['name'],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Postulé le ${applicant['appliedDate']}'.tr),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              SizedBox(width: 4),
              Text(
                'Statut: ${applicant['status']}'.tr,
                style: TextStyle(color: statusColor),
              ),
            ],
          ),
        ],
      ),
      trailing: Container(
        width: 100,
        child: applicant['status'] == 'pending' ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _handleApplicantDecision(
                  jobId, applicant['id'], 'accepted'.tr),
            ),
            IconButton(
              icon: Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () => _handleApplicantDecision(
                  jobId, applicant['id'], 'rejected'.tr),
            ),
          ],
        ) : null,
      ),
      onTap: () {
        Navigator.pushNamed(context, '/freelancer_portfolio'.tr,
            arguments: {"portfolioID": applicant['portfolio_id']});
      },
    );
  }

  void _handleApplicantDecision(int jobId, int applicantId, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              status == 'accepted' ? Icons.check_circle : Icons.cancel,
              color: status == 'accepted' ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8), // Ajoute un espace entre l'icône et le texte
            Expanded(
              child: Text(
                status == 'accepted'
                    ? 'Accepter la candidature'.tr
                    : 'Refuser la candidature'.tr,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18, // Taille de police personnalisée pour le titre
                  // Optionnel : ajoutez du gras
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir ${status == 'accepted' ? 'accepter' : 'refuser'} cette candidature ?'
              .tr,
          style: TextStyle(
              fontSize: 18 // Taille de police personnalisée pour le contenu
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler'.tr,
              style: TextStyle(
                color: Colors.grey,
                fontSize:
                    16, // Taille de police personnalisée pour le bouton Annuler
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateApplicantStatus(jobId, applicantId, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Confirmer'.tr,
              style: TextStyle(
                fontSize:
                    16, // Taille de police personnalisée pour le bouton Confirmer
              ),
            ),
          ),
        ],
      ),
    );
  }
}
