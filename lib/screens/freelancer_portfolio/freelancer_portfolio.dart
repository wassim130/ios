import 'package:ahmini/services/constants.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/theme_controller.dart';

class MPortfolioPage extends StatefulWidget {
  final int? id;
  const MPortfolioPage({super.key, this.id});

  @override
  State<MPortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<MPortfolioPage> {
  final ThemeController themeController = Get.find<ThemeController>();
  // Data from API with null safety
  Map<String, dynamic> portfolioData = {
    'name': 'Chargement...'.tr,
    'username': 'utilisateur'.tr,
    'imagePath': 'assets/images/profile.jpg'.tr,
    'aboutWorkExperience': 'Chargement...'.tr,
    'aboutMeSummary': 'Chargement...'.tr,
    'location': 'Chargement...'.tr,
    'website': 'Chargement...'.tr,
    'portfolio': 'Chargement...'.tr,
    'email': 'Chargement...'.tr,
    'resumeLink': ''.tr,
    'contactEmail': ''.tr,
    'projects': [],
    'stats': {'projects': '0'.tr, 'clients': '0'.tr, 'rating': '0'},
  };
  bool showEditButton = false;
  bool isLoading = true;
  bool isEditing = false;
  final String apiBaseUrl = '$httpURL/api'; // Changez selon votre configuration
  final String apiBaseUrll = '$httpURL/api/user'; // Changez selon votre configuration

  // Controllers pour l'édition
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    fetchPortfolioData();
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchPortfolioData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      // Construire l'URL de l'API
      // Si widget.id est null, cela affichera le portfolio de l'utilisateur connecté
      // Si widget.id est fourni, cela affichera le portfolio de l'utilisateur spécifié
      final String apiUrl = '$apiBaseUrl/portefolio/${widget.id == null ? "?id=0" : "?id=${widget.id}"}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ensure stats exists and has required fields
        if (data['stats'] == null) {
          data['stats'] = {'projects': '0', 'clients': '0', 'rating': '0'};
        } else {
          data['stats']['projects'] ??= '0';
          data['stats']['clients'] ??= '0';
          data['stats']['rating'] ??= '0';
          showEditButton = data['mine'] ?? false;
        }

        // Ensure projects is not null
        data['projects'] ??= [];

        // Set default values for null fields
        data['name'] ??= 'Nom non défini';
        data['username'] ??= 'utilisateur';
        data['imagePath'] ??= 'assets/images/profile.jpg';
        data['aboutWorkExperience'] ??= 'Aucune expérience fournie';
        data['aboutMeSummary'] ??= 'Aucune information fournie';
        data['location'] ??= 'Non spécifié';
        data['website'] ??= 'Non spécifié';
        data['portfolio'] ??= 'Non spécifié';
        data['email'] ??= 'Non spécifié';
        data['resumeLink'] ??= '';
        data['contactEmail'] ??= '';

        setState(() {
          portfolioData = data;
          isLoading = false;
          _initControllers();
        });
      } else {
        print('Erreur de chargement: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception lors du chargement: $e');
      setState(() {
        isLoading = false;
      });
    }
  }



  void _initControllers() {
    controllers.clear();
    portfolioData.forEach((key, value) {
      if (value is String) {
        controllers[key] = TextEditingController(text: value);
      }
    });

    // Ajout des contrôleurs pour les statistiques
    final stats = portfolioData['stats'] as Map<String, dynamic>;
    controllers['projects'] =
        TextEditingController(text: stats['projects']?.toString() ?? '0'.tr);
    controllers['clients'] =
        TextEditingController(text: stats['clients']?.toString() ?? '0'.tr);
    controllers['rating'] =
        TextEditingController(text: stats['rating']?.toString() ?? '0'.tr);
  }

  Future<void> savePortfolioData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Update the model with controller values
      controllers.forEach((key, controller) {
        if (key == 'projects' || key == 'clients' || key == 'rating'.tr) {
          portfolioData['stats'][key] = controller.text;
        } else {
          portfolioData[key] = controller.text;
        }
      });

      // Get the session cookie
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie'.tr);

      final response = await http.put(
        Uri.parse('$apiBaseUrl/portefolio/update/'.tr),
        headers: {
          'Content-Type': 'application/json'.tr,
          'Cookie': "sessionid=$sessionCookie",
        },
        body: json.encode(portfolioData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Portfolio mis à jour avec succès'.tr)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: ${response.statusCode}'.tr)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      setState(() {
        isLoading = false;
        isEditing = false;
      });
    }
  }

  Future<void> uploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'.tr, 'doc'.tr, 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Get the session cookie
        final prefs = await SharedPreferences.getInstance();
        final sessionCookie = prefs.getString('session_cookie'.tr);

        var request = http.MultipartRequest(
          'POST'.tr,
          Uri.parse('$apiBaseUrl/portfolio/upload-cv/'.tr),
        );

        // Add the session cookie to the request headers
        request.headers['Cookie'] = "sessionid=$sessionCookie";

        request.files.add(await http.MultipartFile.fromPath(
          'cv'.tr,
          result.files.single.path!,
        ));

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        if (response.statusCode == 200 && responseData['resumeLink'] != null) {
          setState(() {
            portfolioData['resumeLink'] = responseData['resumeLink'];
            controllers['resumeLink']?.text = responseData['resumeLink'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CV téléchargé avec succès'.tr)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors du téléchargement du CV'.tr)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'.tr)),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  Future<void> uploadProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Get the session cookie
        final prefs = await SharedPreferences.getInstance();
        final sessionCookie = prefs.getString('session_cookie'.tr);

        var request = http.MultipartRequest(
          'POST'.tr,
          Uri.parse('$apiBaseUrl/portefolio/upload-image/'.tr),
        );

        // Add the session cookie to the request headers
        request.headers['Cookie'] = "sessionid=$sessionCookie";

        request.files.add(await http.MultipartFile.fromPath(
          'image'.tr,
          result.files.single.path!,
        ));

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        if (response.statusCode == 200 && responseData['imagePath'] != null) {
          setState(() {
            portfolioData['imagePath'] = responseData['imagePath'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image téléchargée avec succès'.tr)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors du téléchargement de l\'image'.tr)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'.tr)),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title:  Text(
            'Portfolio'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (!isEditing && showEditButton)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isEditing = true;
                    _initControllers();
                  });
                },
              ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: savePortfolioData,
              ),
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title:  Text('Aide'.tr),
                        content:  Text(
                            'Besoin d\'aide avec votre portfolio ? Contactez notre support technique.'.tr),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child:  Text('Fermer'.tr),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Section
              Container(
                width: double.infinity,
                height: 330,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      primaryColorTheme,
                      primaryColorTheme,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: isEditing ? uploadProfileImage : null,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: (portfolioData['imagePath'] != null)
                                    ? CachedNetworkImage(
                                  imageUrl: "$apiBaseUrl${portfolioData['imagePath']}"
                                      .toString(),
                                  fit: BoxFit.cover,
                                  placeholder: (context,
                                      url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                        'assets/images/profile.jpg'.tr,
                                        fit: BoxFit.cover,
                                      ),
                                )
                                    : Image.asset(
                                  portfolioData['imagePath']?.toString() ??
                                      'assets/images/profile.jpg'.tr,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16,
                                    color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      isEditing
                          ? SizedBox(
                        width: 200,
                        child: TextField(
                          controller: controllers['name'],
                          style: const TextStyle(color: Colors.white,
                              fontSize: 24),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      )
                          : Text(
                        portfolioData['name']?.toString() ?? 'Nom non défini'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      isEditing
                          ? SizedBox(
                        width: 200,
                        child: TextField(
                          controller: controllers['username'],
                          style: const TextStyle(color: Colors.white,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            prefixText: "@",
                          ),
                        ),
                      )
                          : Text(
                        "@${portfolioData['username']?.toString() ??
                            'utilisateur'}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatCard('Projets'.tr,
                              portfolioData['stats']?['projects']?.toString() ??
                                  '0'.tr,
                              isEditing,
                              controllers['projects']
                          ),
                          _buildStatCard('Clients'.tr,
                              portfolioData['stats']?['clients']?.toString() ??
                                  '0'.tr,
                              isEditing,
                              controllers['clients']
                          ),
                          _buildStatCard('Rating'.tr,
                              portfolioData['stats']?['rating']?.toString() ??
                                  '0'.tr,
                              isEditing,
                              controllers['rating']
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Container(
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.description_outlined,
                            label: 'CV'.tr,
                            onTap: isEditing ? uploadCV : () async {
                              final resumeLink = "$apiBaseUrll${portfolioData['resumeLink']}";
                              if (resumeLink != null && resumeLink
                                  .toString()
                                  .isNotEmpty) {
                                final Uri url = Uri.parse(resumeLink.toString());
                                await launchUrl(url).catchError((e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(
                                        'Erreur d\'ouverture du lien: $e'.tr)),
                                  );
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Aucun CV disponible'.tr)),
                                );
                              }
                            },
                            secondaryColor: secondaryColorTheme,
                          ),
                          _buildActionButton(
                            icon: Icons.mail_outline,
                            label: 'Contact'.tr,
                            onTap: () async {
                              final contactEmail = portfolioData['contactEmail'];
                              if (contactEmail != null && contactEmail
                                  .toString()
                                  .isNotEmpty) {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto'.tr,
                                  path: contactEmail.toString(),
                                );
                                await launchUrl(emailLaunchUri).catchError((e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(
                                        'Erreur d\'ouverture du mail: $e'.tr)),
                                  );
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(
                                      'Aucune adresse email de contact disponible'.tr)),
                                );
                              }
                            },
                            secondaryColor: secondaryColorTheme,
                          ),
                          _buildActionButton(
                            icon: Icons.work_outline,
                            label: 'Projets'.tr,
                            onTap: () {
                              // Scroll to projects section
                            },
                            secondaryColor: secondaryColorTheme,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Experience Section
                      _buildSection(
                        title: 'Experience'.tr,
                        content: portfolioData['aboutWorkExperience']
                            ?.toString() ?? 'Aucune expérience fournie'.tr,
                        icon: Icons.work,
                        isEditing: isEditing,
                        controller: controllers['aboutWorkExperience'],
                        primaryColor: primaryColorTheme,
                        isDark: isDark,
                      ),

                      // About Me Section
                      _buildSection(
                        title: 'À propos de moi'.tr,
                        content: portfolioData['aboutMeSummary']?.toString() ??
                            'Aucune information fournie'.tr,
                        icon: Icons.person,
                        isEditing: isEditing,
                        controller: controllers['aboutMeSummary'],
                        primaryColor: primaryColorTheme,
                        isDark: isDark,
                      ),

                      // Contact Information Card
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildContactRow(
                                Icons.location_on,
                                portfolioData['location']?.toString() ??
                                    'Non spécifié'.tr,
                                isEditing,
                                controllers['location'],
                                secondaryColorTheme,
                              ),
                              const SizedBox(height: 10),
                              _buildContactRow(
                                Icons.language,
                                portfolioData['website']?.toString() ??
                                    'Non spécifié'.tr,
                                isEditing,
                                controllers['website'],
                                secondaryColorTheme,
                              ),
                              const SizedBox(height: 10),
                              _buildContactRow(
                                Icons.work,
                                portfolioData['portfolio']?.toString() ??
                                    'Non spécifié'.tr,
                                isEditing,
                                controllers['portfolio'],
                                secondaryColorTheme,
                              ),
                              const SizedBox(height: 10),
                              _buildContactRow(
                                Icons.email,
                                portfolioData['email']?.toString() ??
                                    'Non spécifié'.tr,
                                isEditing,
                                controllers['email'],
                                secondaryColorTheme,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Projects Header with Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Projets Récents'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          if (isEditing)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, color: Colors.white),
                              label:  Text('Ajouter'.tr),
                              onPressed: () {
                                _showAddProjectDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColorTheme,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Projects Grid
                      portfolioData['projects'] == null ||
                          (portfolioData['projects'] as List).isEmpty
                          ?  Center(
                        child: Text(
                          'Aucun projet pour le moment'.tr,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: (portfolioData['projects'] as List).length,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(
                            (portfolioData['projects'] as List)[index],
                            index,
                            isEditing,
                            secondaryColorTheme,
                            primaryColorTheme,
                            isDark,
                          );
                        },
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

  Widget _buildStatCard(String label, String value, bool isEditing,
      TextEditingController? controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          isEditing
              ? SizedBox(
            width: 50,
            height: 30,
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 8, vertical: 0),
                border: OutlineInputBorder(),
              ),
            ),
          )
              : Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color secondaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required bool isEditing,
    required TextEditingController? controller,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        isEditing
            ? TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Entrez votre $title'.tr,
          ),
        )
            : Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text, bool isEditing,
      TextEditingController? controller, Color secondaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: isEditing
              ? TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          )
              : Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index,
      bool isEditing, Color secondaryColor, Color primaryColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isEditing ? () => _uploadProjectImage(index) : null,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15)),
                        child: CachedNetworkImage(
                          imageUrl: project['image'],
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder.jpg'.tr,
                              height: 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        project['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 40,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (project['technologies'] as List<dynamic>)
                              .take(3)
                              .map((tech) =>
                              Chip(
                                label: Text(
                                  tech.toString(),
                                  style: TextStyle(fontSize: 9, color: Colors.white),
                                ),
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProject(index),
              ),
            ),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editProject(index),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadProjectImage(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Get the session cookie
        final prefs = await SharedPreferences.getInstance();
        final sessionCookie = prefs.getString('session_cookie'.tr);

        var request = http.MultipartRequest(
          'POST'.tr,
          Uri.parse('$apiBaseUrl/portefolio/upload-project-image/'.tr),
        );

        // Add the session cookie to the request headers
        request.headers['Cookie'] = "sessionid=$sessionCookie";

        request.files.add(await http.MultipartFile.fromPath(
          'image'.tr,
          result.files.single.path!,
        ));

        request.fields['project_index'] = index.toString();

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        if (response.statusCode == 200) {
          setState(() {
            portfolioData['projects'][index]['image'] = responseData['imagePath'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image du projet téléchargée avec succès'.tr)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors du téléchargement de l\'image'.tr)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'.tr)),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  void _showAddProjectDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController techController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un projet'.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: techController,
                  decoration: InputDecoration(
                    labelText: 'Technologies (séparées par des virgules)'.tr,
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
                'Annuler'.tr,
                style: TextStyle(
                    color: Colors.red), // Couleur du texte en rouge
              ),
            ),
            ElevatedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: Colors.white, // Couleur de l'icône en blanc
                ),
                label: Text(
                  'Ajouter'.tr,
                  style: TextStyle(
                      color: Colors.white), // Couleur du texte en blanc
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 190, 49, 68), // Couleur de fond du bouton
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty || descController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'.tr)),
                    );
                    return;
                  }

                  List<String> technologies = techController.text
                      .split('.tr,'.tr)
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  Map<String, dynamic> newProject = {
                    'title': titleController.text,
                    'description': descController.text,
                    'technologies': technologies,
                    'image': 'https://via.placeholder.com/150'.tr,
                  };

                  try {
                    // Get the session cookie
                    final prefs = await SharedPreferences.getInstance();
                    final sessionCookie = prefs.getString('session_cookie'.tr);

                    final response = await http.post(
                      Uri.parse('$apiBaseUrl/portefolio/add-project/'.tr),
                      headers: {
                        'Content-Type': 'application/json'.tr,
                        'Cookie': "sessionid=$sessionCookie",
                      },
                      body: json.encode(newProject),
                    );

                    if (response.statusCode == 200) {
                      var responseData = json.decode(response.body);
                      setState(() {
                        portfolioData['projects'].add(responseData['project']);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Projet ajouté avec succès'.tr)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de l\'ajout du projet'.tr)),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'.tr)),
                    );
                  }
                }
            ),
          ],
        );
      },
    );
  }

  void _editProject(int index) {
    Map<String, dynamic> project = portfolioData['projects'][index];
    TextEditingController titleController = TextEditingController(
        text: project['title']);
    TextEditingController descController = TextEditingController(
        text: project['description']);
    TextEditingController techController = TextEditingController(
      text: (project['technologies'] as List<dynamic>).join('.tr, '.tr),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le projet'.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: techController,
                  decoration: InputDecoration(
                    labelText: 'Technologies (séparées par des virgules)'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () async {
                if (titleController.text.isEmpty || descController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'.tr)),
                  );
                  return;
                }

                List<String> technologies = techController.text
                    .split('.tr,'.tr)
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                Map<String, dynamic> updatedProject = {
                  'title': titleController.text,
                  'description': descController.text,
                  'technologies': technologies,
                  'image': project['image'],
                };

                try {
                  // Get the session cookie
                  final prefs = await SharedPreferences.getInstance();
                  final sessionCookie = prefs.getString('session_cookie'.tr);

                  final response = await http.put(
                    Uri.parse('$apiBaseUrl/portefolio/update-project/$index/'.tr),
                    headers: {
                      'Content-Type': 'application/json'.tr,
                      'Cookie': "sessionid=$sessionCookie",
                    },
                    body: json.encode(updatedProject),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      portfolioData['projects'][index] = updatedProject;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Projet mis à jour avec succès'.tr)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la mise à jour du projet'.tr)),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'.tr)),
                  );
                }
              },
              child: Text('Mettre à jour'.tr),
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'.tr),
          content: Text('Voulez-vous vraiment supprimer ce projet ?'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                try {
                  // Get the session cookie
                  final prefs = await SharedPreferences.getInstance();
                  final sessionCookie = prefs.getString('session_cookie'.tr);

                  final response = await http.delete(
                    Uri.parse('$apiBaseUrl/portefolio/delete-project/$index/'.tr),
                    headers: {
                      'Cookie': "sessionid=$sessionCookie",
                      // Add the session cookie here
                    },
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      portfolioData['projects'].removeAt(index);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Projet supprimé avec succès'.tr)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          'Erreur lors de la suppression du projet'.tr)),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'.tr)),
                  );
                }
              },
              child: Text('Supprimer'.tr),
            ),
          ],
        );
      },
    );
  }
}

