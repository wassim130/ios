import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ahmini/controllers/theme_controller.dart';
import 'package:ahmini/models/job.dart';
import 'package:ahmini/models/company.dart';
import 'package:ahmini/theme.dart';
import 'package:ahmini/helper/CustomDialog/custom_dialog.dart';
import 'package:ahmini/helper/CustomDialog/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailPage extends StatefulWidget {
  final Product job;
  final int companyID;

  const JobDetailPage({
    Key? key,
    required this.job,
    required this.companyID,
  }) : super(key: key);

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final ThemeController themeController = Get.find<ThemeController>();
  CompanyModel? company;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  void fetchCompany() async {
    setState(() {
      isLoading = true;
    });
    company = await CompanyModel.fetch(widget.companyID);
    if (company != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleApply() async {
    myCustomLoadingIndicator(context);
    final response = await CompanyModel.sendJobRequest(widget.job.id);
    if (mounted) {
      Navigator.pop(context); // Close loading indicator

      // Check if the application was successful or if user already applied
      if (response['type'] == 'success') {
        // Show success dialog with more details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeController.isDarkMode.value ? darkBackgroundColor : backgroundColor,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text(
                  'Candidature envoyée !',
                  style: TextStyle(
                    color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre candidature pour le poste "${widget.job.title}" a été envoyée avec succès.',
                    style: TextStyle(
                      color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'L\'entreprise examinera votre profil et vous contactera si votre candidature est retenue.',
                    style: TextStyle(
                      color: themeController.isDarkMode.value ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    color: themeController.isDarkMode.value ? darkPrimaryColor : primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (response['message'] == 'You have already applied to this job' ||
          response['content'] == 'You have already applied to this job') {
        // Show already applied dialog with more details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeController.isDarkMode.value ? darkBackgroundColor : backgroundColor,
            title: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 28),
                SizedBox(width: 8),
                Text(
                  'Candidature existante',
                  style: TextStyle(
                    color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vous avez déjà postulé pour cette offre d\'emploi.',
                    style: TextStyle(
                      color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Votre candidature est en cours d\'examen.',
                    style: TextStyle(
                      color: themeController.isDarkMode.value ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    color: themeController.isDarkMode.value ? darkPrimaryColor : primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // For other error messages, use the default dialog
        myCustomDialog(context, response);
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
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Text(
            widget.job.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (company != null)
              IconButton(
                icon: const Icon(Icons.contact_support, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: backgroundColorTheme,
                      title: Text(
                        'Contactez-nous'.tr,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactRow(
                              Icons.email,
                              company!.companyEmail,
                              secondaryColorTheme,
                              isDark,
                            ),
                            SizedBox(height: 10),
                            _buildContactRow(
                              Icons.phone,
                              company!.companyPhone,
                              secondaryColorTheme,
                              isDark,
                            ),
                            SizedBox(height: 10),
                            _buildContactRow(
                              Icons.location_on,
                              company!.companyAddress,
                              secondaryColorTheme,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Fermer'.tr,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto'.tr,
                              path: company!.companyEmail,
                            );
                            await launchUrl(emailLaunchUri);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Envoyer un Email'.tr,
                            style: TextStyle(
                              color: primaryColorTheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColorTheme,
                ),
                child: widget.job.image.isNotEmpty
                    ? Image.network(
                  widget.job.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.work,
                        color: Colors.white,
                        size: 80,
                      ),
                    );
                  },
                )
                    : Center(
                  child: Icon(
                    Icons.work,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),

              // Job Details
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Title
                    Text(
                      widget.job.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Company Info
                    if (company != null)
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: primaryColorTheme,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              company!.companyName,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 5),

                    // Location
                    if (company != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: primaryColorTheme,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              company!.companyAddress,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 20),

                    // Description Title
                    Text(
                      'Description du poste',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Description Content
                    Text(
                      widget.job.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 30),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColorTheme,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Postuler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Company Section
                    if (company != null) ...[
                      Divider(color: isDark ? Colors.white30 : Colors.black12),
                      SizedBox(height: 20),

                      Text(
                        'À propos de l\'entreprise',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),

                      Text(
                        company!.aboutCompany,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Contact Card
                      Card(
                        elevation: 3,
                        color: secondaryColorTheme.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contactez-nous',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildContactRow(
                                Icons.email,
                                company!.companyEmail,
                                secondaryColorTheme,
                                isDark,
                              ),
                              SizedBox(height: 8),
                              _buildContactRow(
                                Icons.phone,
                                company!.companyPhone,
                                secondaryColorTheme,
                                isDark,
                              ),
                              SizedBox(height: 8),
                              _buildContactRow(
                                Icons.language,
                                company!.companyWebsite,
                                secondaryColorTheme,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContactRow(
      IconData icon,
      String text,
      Color secondaryColorTheme,
      bool isDark,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColorTheme,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}