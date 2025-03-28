import 'package:ahmini/helper/CustomDialog/custom_dialog.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/theme_controller.dart';

import '../../models/company.dart';
import '../../models/job.dart';
import '../../helper/CustomDialog/loading_indicator.dart';
import 'components/drop_down.dart';

class EnterprisePage extends StatefulWidget {
  final int companyID;
  const EnterprisePage({super.key, required this.companyID});

  @override
  State<EnterprisePage> createState() => _EnterprisePageState();
}

class _EnterprisePageState extends State<EnterprisePage> {
  CompanyModel? company;
  CompanyModel? oldCompany;
  bool isEditing = false;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  void fetchCompany() async {
    isLoading = true;
    company = await CompanyModel.fetch(widget.companyID);
    if (company != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Méthode pour ouvrir le dialogue d'édition
  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    final TextEditingController controller =
    TextEditingController(text: currentValue);
    final isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? darkBackgroundColor : backgroundColor,
        title: Text(
          'Modifier $title',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Entrez la nouvelle valeur',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
          maxLines: currentValue.length > 50 ? 5 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: Text(
              'Enregistrer',
              style: TextStyle(
                color: isDark ? darkPrimaryColor : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour basculer le mode édition
  void _toggleEditMode({t = false}) async {
    if (!isEditing) {
      print("Start Editing");
      oldCompany = company!.copy();
    } else if (isEditing && t) {
      if (company != null) {
        final s = await CompanyModel.update(company!);
        myCustomDialog(context, s);
      }
    } else {
      print("Pressed the X button");
      company = oldCompany;
    }
    isEditing = !isEditing;
    setState(() {});
  }

  // Méthode pour ajouter une nouvelle offre d'emploi
  void _addNewJobOffer() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String imageUrl = "https://example.com/placeholder.jpg";
    final isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? darkBackgroundColor : backgroundColor,
        title: Text(
          'Ajouter une offre d\'emploi',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: imageUrl),
                decoration: InputDecoration(
                  labelText: 'URL de l\'image',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                onChanged: (value) => imageUrl = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                setState(() {
                  company!.productsList.add(
                    Product(
                      id: 0,
                      title: titleController.text,
                      description: descriptionController.text,
                      image: imageUrl,
                      technologies: ["Postuler"],
                      link: "",
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              'Ajouter',
              style: TextStyle(
                color: isDark ? darkPrimaryColor : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour modifier une offre d'emploi existante
  void _editJobOffer(int index) {
    final Product product = company!.productsList[index];
    final TextEditingController titleController =
    TextEditingController(text: product.title);
    final TextEditingController descriptionController =
    TextEditingController(text: product.description);
    String imageUrl = product.image;
    final isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? darkBackgroundColor : backgroundColor,
        title: Text(
          'Modifier l\'offre d\'emploi',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: imageUrl),
                decoration: InputDecoration(
                  labelText: 'URL de l\'image',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                onChanged: (value) => imageUrl = value,
              ),
              SelectDropdown(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                setState(() {
                  company!.productsList[index].title = titleController.text;
                  company!.productsList[index].description =
                      descriptionController.text;
                  company!.productsList[index].image = imageUrl;
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              'Enregistrer',
              style: TextStyle(
                color: isDark ? darkPrimaryColor : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour supprimer une offre d'emploi
  void _deleteJobOffer(int index) {
    final isDark = themeController.isDarkMode.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? darkBackgroundColor : backgroundColor,
        title: Text(
          'Supprimer l\'offre',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette offre d\'emploi ?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                company!.productsList.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour changer la photo de profil
  Future<void> _changeProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        // Dans une application réelle, vous devriez stocker l'image et mettre à jour le chemin
        // Pour cet exemple, nous simulons juste le changement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo de profil mise à jour')),
        );
      });
    }
  }

  void _handleContactTap(id) async {
    myCustomLoadingIndicator(context);
    final s = await CompanyModel.sendJobRequest(id);
    if (mounted) {
      Navigator.pop(context);
      myCustomDialog(context, s);
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
          leading: isEditing
              ? IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: backgroundColorTheme,
                      title: Text(
                        'Are you sure you want to stop editing ?',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to stop editing ? All the edits applied will be lost.",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : Colors.black,
                          ),
                          child: Text('Keep editing'),
                        ),
                        TextButton(
                          onPressed: () {
                            _toggleEditMode();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.close),
            color: Colors.white,
          )
              : IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Wrap(
            children: [
              Text(
                company?.companyName ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            // Bouton pour activer/désactiver le mode édition
            if (company != null && company!.mine)
              IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit,
                    color: Colors.white),
                onPressed: () {
                  _toggleEditMode(t: isEditing);
                },
              ),
            IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              onPressed: () async {
                final Uri url = Uri.parse('https://${company!.companyWebsite}');
                await launchUrl(url);
              },
            ),
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
                    content: Column(
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
            : company == null
            ? Center(
          child: Text(
            'Aucune entreprise trouvée',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              // Company Header Section with Animated Background
              Container(
                width: double.infinity,
                height: 300,
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
                child: Stack(
                  children: [
                    // Company Profile Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    "IS",
                                    style: TextStyle(
                                      color: primaryColorTheme,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (isEditing)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: _changeProfilePhoto,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: primaryColorTheme,
                                            width: 2),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: primaryColorTheme,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          GestureDetector(
                            onTap: isEditing
                                ? () => _showEditDialog(
                                'Nom de l\'entreprise',
                                company!.companyName,
                                    (value) => setState(() =>
                                company!.companyName = value))
                                : null,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  company!.companyName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isEditing) SizedBox(width: 5),
                                if (isEditing)
                                  Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: isEditing
                                ? () => _showEditDialog(
                                'Slogan',
                                company!.tagline,
                                    (value) => setState(
                                        () => company!.tagline = value))
                                : null,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  company!.tagline,
                                  style: TextStyle(
                                    color:
                                    Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                if (isEditing) SizedBox(width: 5),
                                if (isEditing)
                                  Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEditableStatCard(
                                  'Solutions',
                                  company!.solutionsCount,
                                      (value) => setState(() =>
                                  company!.solutionsCount = value)),
                              _buildEditableStatCard(
                                  'Clients',
                                  company!.clientsCount,
                                      (value) => setState(() =>
                                  company!.clientsCount = value)),
                              _buildEditableStatCard(
                                  'Satisfaction',
                                  company!.satisfactionRate,
                                      (value) => setState(() => company!
                                      .satisfactionRate = value)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      SizedBox(height: 10),

                      // About Company Section
                      _buildEditableSection(
                        title: 'Notre Entreprise',
                        content: company!.aboutCompany,
                        icon: Icons.business,
                        onEdit: (value) => setState(
                                () => company!.aboutCompany = value),
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                      ),

                      // Mission Section
                      _buildEditableSection(
                        title: 'Notre Mission',
                        content: company!.companyMission,
                        icon: Icons.rocket_launch,
                        onEdit: (value) => setState(
                                () => company!.companyMission = value),
                        isDark: isDark,
                        primaryColorTheme: primaryColorTheme,
                      ),

                      // Innovation Areas
                      Text(
                        'Domaines d\'Innovation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: company!.innovationAreas.length,
                        itemBuilder: (context, index) {
                          final area = company!.innovationAreas[index];
                          return _buildInnovationCard(
                            title: area.title,
                            icon: area.icon,
                            description: area.description,
                            secondaryColorTheme: secondaryColorTheme,
                            primaryColorTheme: primaryColorTheme,
                            isDark: isDark,
                          );
                        },
                      ),

                      SizedBox(height: 25),

                      // Offres d'Emploi Grid
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nos Offres d\'Emploi'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              if (isEditing)
                                IconButton(
                                  icon: Icon(Icons.add_circle,
                                      color: primaryColorTheme),
                                  onPressed: _addNewJobOffer,
                                ),
                              TextButton(
                                onPressed: () {
                                  // Voir toutes les offres
                                },
                                child: Text(
                                  'Voir tout',
                                  style: TextStyle(
                                    color: primaryColorTheme,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                        (company!.productsList.length / 2).ceil(),
                        itemBuilder: (context, rowIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                // Premier élément de la ligne
                                Expanded(
                                  child: rowIndex * 2 <
                                      company!.productsList.length
                                      ? _buildProductCard(
                                    company!.productsList[
                                    rowIndex * 2]
                                        .toMap(),
                                    rowIndex * 2,
                                    secondaryColorTheme,
                                    primaryColorTheme,
                                    isDark,
                                  )
                                      : Container(),
                                ),
                                SizedBox(width: 15),
                                // Deuxième élément de la ligne (s'il existe)
                                Expanded(
                                  child: (rowIndex * 2 + 1 <
                                      company!.productsList.length)
                                      ? _buildProductCard(
                                    company!.productsList[
                                    rowIndex * 2 + 1]
                                        .toMap(),
                                    rowIndex * 2 + 1,
                                    secondaryColorTheme,
                                    primaryColorTheme,
                                    isDark,
                                  )
                                      : Container(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 25),

                      // Testimonials Section
                      Text(
                        'Ce que disent nos clients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: company!.testimonialsList.length,
                          itemBuilder: (context, index) {
                            final testimonial =
                            company!.testimonialsList[index];
                            return _buildTestimonialCard(
                              testimonial,
                              backgroundColorTheme,
                              secondaryColorTheme,
                              isDark,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 25),

                      // Contact Information Card
                      Card(
                        elevation: 3,
                        color: secondaryColorTheme.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Contactez-nous',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  if (isEditing) SizedBox(width: 10),
                                  if (isEditing)
                                    IconButton(
                                      icon: Icon(Icons.edit, size: 18),
                                      onPressed: () {
                                        // Dialogue pour éditer toutes les informations de contact
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                backgroundColor: backgroundColorTheme,
                                                title: Text(
                                                  'Modifier les informations de contact',
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                                content:
                                                SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                        TextEditingController(
                                                            text: company!
                                                                .companyAddress),
                                                        decoration:
                                                        InputDecoration(
                                                          labelText:
                                                          'Adresse',
                                                          border:
                                                          OutlineInputBorder(),
                                                          labelStyle: TextStyle(
                                                            color: isDark ? Colors.white70 : Colors.black54,
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : Colors.black,
                                                        ),
                                                        onChanged: (value) =>
                                                        company!.companyAddress =
                                                            value,
                                                      ),
                                                      SizedBox(height: 10),
                                                      TextField(
                                                        controller:
                                                        TextEditingController(
                                                            text: company!
                                                                .companyWebsite),
                                                        decoration:
                                                        InputDecoration(
                                                          labelText:
                                                          'Site web',
                                                          border:
                                                          OutlineInputBorder(),
                                                          labelStyle: TextStyle(
                                                            color: isDark ? Colors.white70 : Colors.black54,
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : Colors.black,
                                                        ),
                                                        onChanged: (value) =>
                                                        company!.companyWebsite =
                                                            value,
                                                      ),
                                                      SizedBox(height: 10),
                                                      TextField(
                                                        controller:
                                                        TextEditingController(
                                                            text: company!
                                                                .companyEmail),
                                                        decoration:
                                                        InputDecoration(
                                                          labelText:
                                                          'Email',
                                                          border:
                                                          OutlineInputBorder(),
                                                          labelStyle: TextStyle(
                                                            color: isDark ? Colors.white70 : Colors.black54,
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : Colors.black,
                                                        ),
                                                        onChanged: (value) =>
                                                        company!.companyEmail =
                                                            value,
                                                      ),
                                                      SizedBox(height: 10),
                                                      TextField(
                                                        controller:
                                                        TextEditingController(
                                                            text: company!
                                                                .companyPhone),
                                                        decoration:
                                                        InputDecoration(
                                                          labelText:
                                                          'Téléphone',
                                                          border:
                                                          OutlineInputBorder(),
                                                          labelStyle: TextStyle(
                                                            color: isDark ? Colors.white70 : Colors.black54,
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : Colors.black,
                                                        ),
                                                        onChanged: (value) =>
                                                        company!.companyPhone =
                                                            value,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context),
                                                    child: Text(
                                                      'Annuler',
                                                      style: TextStyle(
                                                        color: isDark ? Colors.white70 : Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {});
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    child: Text(
                                                      'Enregistrer',
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
                              SizedBox(height: 15),
                              _buildContactRow(
                                Icons.location_on,
                                company!.companyAddress,
                                secondaryColorTheme,
                                isDark,
                              ),
                              SizedBox(height: 10),
                              _buildContactRow(
                                Icons.language,
                                company!.companyWebsite,
                                secondaryColorTheme,
                                isDark,
                              ),
                              SizedBox(height: 10),
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
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
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

  Widget _buildEditableStatCard(
      String label, String value, Function(String) onEdit) {
    final isDark = themeController.isDarkMode.value;

    return GestureDetector(
      onTap: isEditing ? () => _showEditDialog(label, value, onEdit) : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isEditing) SizedBox(width: 5),
                if (isEditing) Icon(Icons.edit, color: Colors.white, size: 14),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection({
    required String title,
    required String content,
    required IconData icon,
    required Function(String) onEdit,
    required bool isDark,
    required Color primaryColorTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColorTheme),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            if (isEditing) SizedBox(width: 10),
            if (isEditing)
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () => _showEditDialog(title, content, onEdit),
              ),
          ],
        ),
        SizedBox(height: 9),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color secondaryColorTheme, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColorTheme,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
      Map<String, dynamic> product,
      int index,
      Color secondaryColorTheme,
      Color primaryColorTheme,
      bool isDark,
      ) {
    return InkWell(
      onTap: () async {
        if (product['link'].isNotEmpty) {
          final Uri url = Uri.parse(product['link']);
          await launchUrl(url);
        }
      },
      child: Stack(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: secondaryColorTheme,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product['image'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: primaryColorTheme,
                        child: Center(
                          child: Icon(
                            Icons.devices,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        product['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _handleContactTap(product['id']);
                        },
                        child: Chip(
                          label: Text(
                            "Postuler",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            Positioned(
              top: 5,
              right: 5,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 20, color: primaryColorTheme),
                      onPressed: () => _editJobOffer(index),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _deleteJobOffer(index),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInnovationCard({
    required String title,
    required IconData icon,
    required String description,
    required Color secondaryColorTheme,
    required Color primaryColorTheme,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColorTheme,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: primaryColorTheme,
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(
      Testimonial testimonial,
      Color backgroundColorTheme,
      Color secondaryColorTheme,
      bool isDark,
      ) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: backgroundColorTheme,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(testimonial.image),
                  onBackgroundImageError: (e, s) {},
                  child: Icon(Icons.person),
                  backgroundColor: secondaryColorTheme,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        testimonial.company,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                    (index) => Icon(
                  index < testimonial.rating.floor()
                      ? Icons.star
                      : (index < testimonial.rating
                      ? Icons.star_half
                      : Icons.star_border),
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Text(
                testimonial.comment,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

