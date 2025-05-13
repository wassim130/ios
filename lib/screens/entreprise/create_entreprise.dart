import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../theme.dart';
import '../../controllers/theme_controller.dart';
import '../../services/constants.dart';

class EntrepriseCreatePage extends StatefulWidget {
  final bool isFirstLogin;

  const EntrepriseCreatePage({
    Key? key,
    required this.isFirstLogin,
  }) : super(key: key);

  @override
  State<EntrepriseCreatePage> createState() =>
      _EntrepriseCreatePageState();
}

class _EntrepriseCreatePageState extends State<EntrepriseCreatePage> {
  final ThemeController themeController = Get.find<ThemeController>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Files to upload
  File? profileImageFile;
  File? cvFile;
  List<Map<String, dynamic>> projectsWithImageFiles = [];

  // Portfolio data
  Map<String, dynamic> portfolioData = {
    'name': '',
    'username': '',
    'imagePath': '',
    'aboutWorkExperience': '',
    'aboutMeSummary': '',
    'location': '',
    'website': '',
    'portfolio': '',
    'email': '',
    'resumeLink': '',
    'contactEmail': '',
    'projects': [],
  };

  // Controllers for form fields
  final Map<String, TextEditingController> controllers = {};
  final String apiBaseUrl = 'http://10.0.2.2:8000/api';

  // Steps in the onboarding process
  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Bienvenue sur votre entreprise'.tr,
      'description':
          'Créez votre entreprise professionnel pour vous démarquer auprès des clients potentiels.'.tr,
      'icon': Icons.person_outline,
    },
    {
      'title': 'Informations personnelles'.tr,
      'description':
          'Ajoutez vos informations de base pour que les clients puissent vous connaître.'.tr,
      'icon': Icons.info_outline,
    },
    {
      'title': 'Expérience professionnelle'.tr,
      'description':
          'Partagez votre parcours et vos compétences pour attirer les bons projets.'.tr,
      'icon': Icons.work_outline,
    },
    {
      'title': 'Coordonnées'.tr,
      'description':
          'Ajoutez vos coordonnées pour que les clients puissent vous contacter facilement.'.tr,
      'icon': Icons.contact_mail_outlined,
    },
    {
      'title': 'Projets'.tr,
      'description':
          'Ajoutez vos projets pour montrer votre expertise et votre expérience.'.tr,
      'icon': Icons.folder_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  void _initControllers() {
    controllers.clear();

    // Initialize controllers for text fields
    controllers['name'] = TextEditingController(text: portfolioData['name']);
    controllers['username'] =
        TextEditingController(text: portfolioData['username']);
    controllers['aboutWorkExperience'] =
        TextEditingController(text: portfolioData['aboutWorkExperience']);
    controllers['aboutMeSummary'] =
        TextEditingController(text: portfolioData['aboutMeSummary']);
    controllers['location'] =
        TextEditingController(text: portfolioData['location']);
    controllers['website'] =
        TextEditingController(text: portfolioData['website']);
    controllers['portfolio'] =
        TextEditingController(text: portfolioData['portfolio']);
    controllers['email'] = TextEditingController(text: portfolioData['email']);
    controllers['contactEmail'] =
        TextEditingController(text: portfolioData['contactEmail']);
  }

  Future<void> savePortfolioData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the model with controller values
      controllers.forEach((key, controller) {
        portfolioData[key] = controller.text;
      });

      // Get the session cookie
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      // Create multipart request for creating portfolio with all data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/portfolio/create-complete/'),
      );

      // Add the session cookie to the request headers
      request.headers['Cookie'] = "sessionid=$sessionCookie";

      // Add all text fields to the request
      request.fields['portfolio_data'] = json.encode(portfolioData);

      // Add profile image if selected
      if (profileImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          profileImageFile!.path,
        ));
      }

      // Add CV if selected
      if (cvFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cv_file',
          cvFile!.path,
        ));
      }

      // Add project images if any
      for (int i = 0; i < projectsWithImageFiles.length; i++) {
        if (projectsWithImageFiles[i]['imageFile'] != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'project_image_$i',
            projectsWithImageFiles[i]['imageFile'].path,
          ));
          request.fields['project_image_index_$i'] = i.toString();
        }
      }
      Map<String, dynamic> portfolioDataToSend = Map.from(portfolioData);

// If you have projects with image files, create a clean version for JSON
      if (portfolioDataToSend['projects'] != null) {
        List<Map<String, dynamic>> cleanProjects = [];
        for (var project in portfolioDataToSend['projects']) {
          Map<String, dynamic> cleanProject = Map.from(project);
          // Remove the File object if it exists
          cleanProject.remove('imageFile');
          cleanProjects.add(cleanProject);
        }
        portfolioDataToSend['projects'] = cleanProjects;
      }

// Now encode the clean data
      request.fields['portfolio_data'] = json.encode(portfolioDataToSend);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Portfolio créé avec succès')),
        );

        // Navigate to home page
        Navigator.pushReplacementNamed(context, '/',
            arguments: {'newUser': true});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erreur lors de la création: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> selectProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        profileImageFile = File(result.files.single.path!);
        // Store a temporary local path for UI display
        portfolioData['imagePath'] = result.files.single.path!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image sélectionnée avec succès')),
      );
    }
  }

  Future<void> selectCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        cvFile = File(result.files.single.path!);
        // Store filename for UI display
        portfolioData['resumeLink'] = result.files.single.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CV sélectionné avec succès')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < steps.length - 1) {
      setState(() {
        _currentStep++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Save portfolio data on the last step
      savePortfolioData();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // If on first step, allow going back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            'Créez votre entreprise'.tr,
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / steps.length,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 5,
                    ),
                  ),

                  // Step indicator
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(steps[_currentStep]['icon'],
                            color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          steps[_currentStep]['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      steps[_currentStep]['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Main content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColorTheme,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildWelcomeStep(
                              primaryColorTheme, secondaryColorTheme, isDark),
                          _buildPersonalInfoStep(
                              primaryColorTheme, secondaryColorTheme, isDark),
                          _buildExperienceStep(
                              primaryColorTheme, secondaryColorTheme, isDark),
                          _buildContactStep(
                              primaryColorTheme, secondaryColorTheme, isDark),
                          _buildProjectsStep(
                              primaryColorTheme, secondaryColorTheme, isDark),
                        ],
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    color: backgroundColorTheme,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _previousStep,
                            child: Text(
                              'Précédent',
                              style: TextStyle(
                                color: primaryColorTheme,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          SizedBox(width: 80),
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColorTheme,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _currentStep == steps.length - 1
                                ? 'Terminer'
                                : 'Suivant',
                            style: TextStyle(
                              color: Colors.white,
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

  Widget _buildWelcomeStep(
      Color primaryColor, Color secondaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),

          // Profile image
          Stack(
            children: [
              GestureDetector(
                onTap: selectProfileImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 3),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: profileImageFile != null
                      ? ClipOval(
                          child: Image.file(
                            profileImageFile!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          // Name field
          TextField(
            controller: controllers['name'],
            decoration: InputDecoration(
              labelText: 'Nom de l\'entreprise'.tr,
              hintText: 'Ex: Ahmini'.tr,
              prefixIcon: Icon(Icons.person_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Username field
          // TextField(
          //   controller: controllers['username'],
          //   decoration: InputDecoration(
          //     labelText: 'Nom d\'utilisateur',
          //     hintText: 'Ex: jean_dupont',
          //     prefixIcon: Icon(Icons.alternate_email, color: primaryColor),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //   ),
          // ),

          SizedBox(height: 30),

          // Instructions
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: primaryColor),
                    SizedBox(width: 10),
                    Text(
                      'Conseils'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Votre portfolio est votre vitrine professionnelle. Commencez par ajouter une photo professionnelle et votre nom complet pour vous présenter aux clients potentiels.'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep(
      Color primaryColor, Color secondaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos de vous'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 20),

          // About me summary
          TextField(
            controller: controllers['aboutMeSummary'],
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Résumé personnel',
              hintText: 'Présentez-vous en quelques phrases...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 30),

          // Instructions
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: primaryColor),
                    SizedBox(width: 10),
                    Text(
                      'Conseils'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Votre résumé personnel est souvent la première chose que les clients lisent. Soyez concis et mettez en avant vos points forts.'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep(
      Color primaryColor, Color secondaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expérience professionnelle'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 20),

          // Work experience
          TextField(
            controller: controllers['aboutWorkExperience'],
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Expérience professionnelle',
              hintText:
                  'Décrivez votre parcours, vos compétences et votre expertise...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 30),

          // CV upload
          GestureDetector(
            onTap: selectCV,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_file, color: primaryColor, size: 30),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Télécharger votre CV'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          cvFile != null
                              ? 'CV sélectionné: ${portfolioData['resumeLink']}'
                              : 'Formats acceptés: PDF, DOC, DOCX'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    cvFile != null
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // Instructions
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: primaryColor),
                    SizedBox(width: 10),
                    Text(
                      'Conseils'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Détaillez votre expérience professionnelle en mettant l\'accent sur les compétences pertinentes pour les projets que vous souhaitez obtenir. Un CV bien structuré augmente vos chances d\'être sélectionné.'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep(
      Color primaryColor, Color secondaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coordonnées'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 20),

          // Location
          TextField(
            controller: controllers['location'],
            decoration: InputDecoration(
              labelText: 'Localisation',
              hintText: 'Ex: Paris, France',
              prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 15),

          // Email
          TextField(
            controller: controllers['email'],
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Ex: contact@example.com',
              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 15),

          // Contact Email
          TextField(
            controller: controllers['contactEmail'],
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email de contact (public)',
              hintText: 'Ex: contact@example.com',
              prefixIcon: Icon(Icons.alternate_email, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 15),

          // Website
          TextField(
            controller: controllers['website'],
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Site web',
              hintText: 'Ex: www.monsite.com',
              prefixIcon: Icon(Icons.language, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 15),

          // Portfolio link
          TextField(
            controller: controllers['portfolio'],
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Lien portfolio externe',
              hintText: 'Ex: www.behance.net/monprofil',
              prefixIcon: Icon(Icons.work_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          SizedBox(height: 30),

          // Instructions
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: primaryColor),
                    SizedBox(width: 10),
                    Text(
                      'Conseils'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Assurez-vous que vos coordonnées sont à jour pour que les clients puissent vous contacter facilement. L\'email de contact sera visible publiquement, alors utilisez une adresse professionnelle.'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsStep(
      Color primaryColor, Color secondaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projets'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Ajouter'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showAddProjectDialog(
                    context, primaryColor, secondaryColor, isDark),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Projects list
          portfolioData['projects'] == null ||
                  (portfolioData['projects'] as List).isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Aucun projet pour le moment'.tr,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Ajoutez vos projets pour montrer votre expertise'.tr,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: (portfolioData['projects'] as List).length,
                  itemBuilder: (context, index) {
                    final project = (portfolioData['projects'] as List)[index];
                    return _buildProjectItem(
                      project,
                      index,
                      primaryColor,
                      secondaryColor,
                      isDark,
                    );
                  },
                ),

          SizedBox(height: 30),

          // Instructions
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: primaryColor),
                    SizedBox(width: 10),
                    Text(
                      'Conseils'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Ajoutez vos meilleurs projets pour montrer votre expertise. Incluez une description claire et les technologies utilisées. Des images de qualité augmenteront l\'attractivité de votre portfolio.'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(
    Map<String, dynamic> project,
    int index,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              children: [
                project['imageFile'] != null
                    ? Image.file(
                        project['imageFile'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 150,
                        color: Colors.grey.withOpacity(0.3),
                        child: Center(
                          child:
                              Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _selectProjectImage(index),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.edit, size: 20, color: primaryColor),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _deleteProject(index),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.delete, size: 20, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Project details
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['title'] ?? 'Sans titre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  project['description'] ?? 'Aucune description',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (project['technologies'] as List<dynamic>?)
                          ?.map((tech) => Chip(
                                label: Text(
                                  tech.toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList() ??
                      [],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Modifier'),
                    onPressed: () => _editProject(index),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProjectImage(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        File imageFile = File(result.files.single.path!);

        // Update the project with the image file
        if (index < portfolioData['projects'].length) {
          portfolioData['projects'][index]['imageFile'] = imageFile;

          // Also update the project in our tracking list
          bool found = false;
          for (int i = 0; i < projectsWithImageFiles.length; i++) {
            if (projectsWithImageFiles[i]['index'] == index) {
              projectsWithImageFiles[i]['imageFile'] = imageFile;
              found = true;
              break;
            }
          }

          if (!found) {
            projectsWithImageFiles.add({
              'index': index,
              'imageFile': imageFile,
            });
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image du projet sélectionnée avec succès')),
      );
    }
  }

  void _showAddProjectDialog(BuildContext context, Color primaryColor,
      Color secondaryColor, bool isDark) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController techController = TextEditingController();
    File? projectImageFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Ajouter un projet'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Project image
                  GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );

                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          projectImageFile = File(result.files.single.path!);
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.5)),
                      ),
                      child: projectImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                projectImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 40, color: primaryColor),
                                SizedBox(height: 8),
                                Text(
                                  'Ajouter une image',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: techController,
                    decoration: InputDecoration(
                      labelText: 'Technologies (séparées par des virgules)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Ajouter', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Veuillez remplir tous les champs obligatoires')),
                    );
                    return;
                  }

                  List<String> technologies = techController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  Map<String, dynamic> newProject = {
                    'title': titleController.text,
                    'description': descController.text,
                    'technologies': technologies,
                    // Don't include the File object in the JSON data
                    // Instead, just store a placeholder or temporary ID
                    'image':
                        'pending_upload', // This will be replaced with the actual URL after upload
                  };

                  if (projectImageFile != null) {
                    projectsWithImageFiles.add({
                      'index': portfolioData['projects'].length,
                      'imageFile': projectImageFile,
                    });
                  }

                  portfolioData['projects'].add(newProject);

                  // Add to our tracking list if there's an image
                  if (projectImageFile != null) {
                    projectsWithImageFiles.add({
                      'index': portfolioData['projects'].length - 1,
                      'imageFile': projectImageFile,
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Projet ajouté avec succès')),
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _editProject(int index) {
    Map<String, dynamic> project = portfolioData['projects'][index];
    TextEditingController titleController =
        TextEditingController(text: project['title']);
    TextEditingController descController =
        TextEditingController(text: project['description']);
    TextEditingController techController = TextEditingController(
      text: (project['technologies'] as List<dynamic>).join(', '),
    );
    File? projectImageFile = project['imageFile'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Modifier le projet'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Project image
                  GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );

                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          projectImageFile = File(result.files.single.path!);
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.5)),
                      ),
                      child: projectImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                projectImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 40, color: primaryColor),
                                SizedBox(height: 8),
                                Text(
                                  'Modifier l\'image',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: techController,
                    decoration: InputDecoration(
                      labelText: 'Technologies (séparées par des virgules)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Veuillez remplir tous les champs obligatoires')),
                    );
                    return;
                  }

                  List<String> technologies = techController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  setState(() {
                    portfolioData['projects'][index] = {
                      'title': titleController.text,
                      'description': descController.text,
                      'technologies': technologies,
                      'imageFile': projectImageFile,
                    };

                    // Update our tracking list if there's an image
                    if (projectImageFile != null) {
                      bool found = false;
                      for (int i = 0; i < projectsWithImageFiles.length; i++) {
                        if (projectsWithImageFiles[i]['index'] == index) {
                          projectsWithImageFiles[i]['imageFile'] =
                              projectImageFile;
                          found = true;
                          break;
                        }
                      }

                      if (!found) {
                        projectsWithImageFiles.add({
                          'index': index,
                          'imageFile': projectImageFile,
                        });
                      }
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Projet mis à jour avec succès')),
                  );
                },
                child: Text('Mettre à jour'),
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteProject(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce projet ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  portfolioData['projects'].removeAt(index);

                  // Remove from our tracking list
                  projectsWithImageFiles
                      .removeWhere((item) => item['index'] == index);

                  // Update indices for remaining projects
                  for (int i = 0; i < projectsWithImageFiles.length; i++) {
                    if (projectsWithImageFiles[i]['index'] > index) {
                      projectsWithImageFiles[i]['index'] -= 1;
                    }
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Projet supprimé avec succès')),
                );
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
