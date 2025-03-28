import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ahmini/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/constants.dart';
import '../../../services/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/app_controller.dart';
import '../../../models/user.dart';
import 'components/text_field.dart';
import 'components/confirmation_widget.dart';
import '../../../controllers/theme_controller.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late UserModel user;
  Map<String, String>? headers;
  final ThemeController themeController = Get.find<ThemeController>();

  String? _image64Base;
  String? _imageName;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _myInitState();
  }

  void _myInitState() async {
    final controller = Get.find<AppController>();
    user = controller.user!;
    headers = await _getHeaders();
    setState(() {});
  }

  void _showPasswordValidationDialog(BuildContext context) {
    final Map<String, String> body = {};
    if (_imageName != null && _image64Base != null) {
      body['filename'] = _imageName!;
      body['file'] = _image64Base!;
    }
    if (_usernameController.text.trim() != "") {
      body['username'] = _usernameController.text.trim();
    }
    if (_nameController.text.trim() != "") {
      final List<String> usernameArray = _nameController.text.trim().split(" ");
      if (usernameArray.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your first and last name.'.tr),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      body['last_name'] = usernameArray[0];
      body['first_name'] = usernameArray.sublist(1).join(" ").trim();
    }
    if (_emailController.text.trim() != "") {
      body['email'] = _emailController.text.trim();
    }
    if (_phoneNumberController.text.trim() != "") {
      body['phone_number'] = _phoneNumberController.text.trim();
    }
    if (_addressController.text.trim() != "") {
      body['address'] = _addressController.text.trim();
    }
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Veuillez remplir au moins un champ.'.tr),
        backgroundColor: Colors.red,
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmationWidget(
          body: body,
          dialogContext: dialogContext,
          parentSetState: (newUser) {
            setState(() {
              user = newUser;
            });
          },
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      File file = File(image.path);
      imageBytes = await file.readAsBytes();
      _image64Base = base64Encode(imageBytes!);
      _imageName = image.path.split('/'.tr).last;
      setState(() {});
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie'.tr);

    if (sessionCookie != null) {
      return {
        "Cookie": "sessionid=$sessionCookie",
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    print("built everything");
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
          title:  Text(
            'Modifier votre profil'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text('Aide'.tr),
                    content: Text(
                        'Besoin d\'aide pour modifier votre profil ? Contactez notre support technique NIBOU au 0549819905'.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Fermer'.tr,
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Welcome Section
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bonjour, ${user.firstName} 👋'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Personnalisez votre profil'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content in White Container
              Container(
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: _buildBody(context, primaryColorTheme, secondaryColorTheme, isDark),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Column _buildBody(BuildContext context, Color primaryColorTheme, Color secondaryColorTheme, bool isDark) {
    return Column(
      children: [
        Hero(
          tag: "profile_picture_hero",
          child: Stack(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColorTheme,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: secondaryColorTheme,
                  backgroundImage: imageBytes != null
                      ? MemoryImage(imageBytes!)
                      : user.profilePicture != null &&
                              user.profilePicture!.isNotEmpty
                          ? NetworkImage(
                              "$httpURL/$userAPI${user.profilePicture!}",
                              headers: headers,
                            )
                          : null,
                  child: user.profilePicture == null ||
                      user.profilePicture!.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 65,
                    color: primaryColorTheme,
                  )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColorTheme,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 25,
                      color: Colors.white,
                    ),
                    onPressed: () => showImagePicker(),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Profile Completion Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: secondaryColorTheme,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.white),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil complété à 80%'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColorTheme,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Form Fields
        MyTextField(
            controller: _nameController,
            placeholder: "Nom Complet",
            labelText: "${user.lastName} ${user.firstName}",
            icon: Icons.person),
        MyTextField(
            controller: _emailController,
            placeholder: "Email",
            labelText: user.email,
            icon: Icons.email),
        MyTextField(
            controller: _phoneNumberController,
            placeholder: "Téléphone",
            labelText: user.phoneNumber,
            icon: Icons.phone),
        MyTextField(
            controller: _addressController,
            placeholder: "Adresse",
            labelText: user.address,
            icon: Icons.location_on),
        MyTextField(
            controller: _usernameController,
            placeholder: "Username",
            labelText: user.username,
            icon: Icons.person_outline),

        SizedBox(height: 20),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColorTheme,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            onPressed: () => _showPasswordValidationDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: 24),
                SizedBox(width: 10),
                Text(
                  'Sauvegarder'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),

        // Cancel Button
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: primaryColorTheme,
          ),
          label: Text(
            'Annuler'.tr,
            style: TextStyle(
              color: primaryColorTheme,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  dynamic showImagePicker() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choisissez une source'.tr),
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () => _getImage(ImageSource.camera),
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () => _getImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }
}

