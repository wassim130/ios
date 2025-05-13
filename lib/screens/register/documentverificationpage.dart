import 'dart:io';
import 'package:ahmini/screens/explore/components/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user.dart';
import '../../services/auth.dart';
import '../../services/constants.dart';

class DocumentVerificationPage extends StatefulWidget {
  final UserModel user;
  const DocumentVerificationPage({super.key, required this.user});

  @override
  _DocumentVerificationPageState createState() =>
      _DocumentVerificationPageState();
}

class _DocumentVerificationPageState extends State<DocumentVerificationPage> {
  final TextEditingController _NIFController = TextEditingController();

  File? _autoEntrepreneurCard;
  File? _identityCard;
  bool _isUploading = false;

  Future<void> _pickImage(bool isAutoEntrepreneur, bool isGallery) async {
    final picker = ImagePicker();
    late final pickedFile;
    if (isGallery) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    }

    if (pickedFile != null) {
      setState(() {
        if (isAutoEntrepreneur) {
          _autoEntrepreneurCard = File(pickedFile.path);
        } else {
          _identityCard = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (widget.user.isEnterprise && _NIFController.text.length != 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un numéro de NIF valide'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }
    if (_identityCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez télécharger la carte d\'identity'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }
    if (!widget.user.isEnterprise && _autoEntrepreneurCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez télécharger l\'auto-entrepreneur carte'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      String? csrfToken = prefs.getString('csrf_token');
      String? csrfCookie = prefs.getString('csrf_cookie');

      if (csrfCookie == null || csrfToken == null) {
        final temp = await AuthService.getCsrf();
        csrfToken = temp['csrf_token'];
        csrfCookie = temp['csrf_cookie'];
      }
      // Prepare multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('$httpURL/$authAPI/freelancer-documents/'));
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
        'X-CSRFToken': csrfToken!,
      });
      // Add files to the request
      if (!widget.user.isEnterprise) {
        request.files.add(await http.MultipartFile.fromPath(
            'auto_entrepreneur_card', _autoEntrepreneurCard!.path));
      } else {
        request.fields['NIF'] = _NIFController.text;
      }
      request.files.add(await http.MultipartFile.fromPath(
          'identity_card', _identityCard!.path));

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var parsedResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        // Documents uploaded successfully
        _showVerificationPendingDialog();
      } else {
        // Handle upload error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(parsedResponse['message'] ?? 'Échec du téléchargement'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion'.tr),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showVerificationPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vérification en cours'.tr),
          content: Text(
              'Vos documents ont été soumis avec succès. Votre compte est en cours de vérification par l\'administrateur. '
                      'Vous serez informé une fois que votre compte sera approuvé.'
                  .tr),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                // Déconnexion et retour à l'écran de connexion
                // AuthService.logout();
                // Navigator.of(context)
                // .pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Vérification de compte'.tr,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.user.isEnterprise
                        ? 'En tant que entreprise, vous devez soumettre votre NIF et la carte d\'identité de votre représentant pour la vérification'
                            .tr
                        : 'En tant que freelancer, vous devez soumettre deux documents pour la vérification'
                            .tr,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Auto-Entrepreneur Card Upload
                  Column(
                    children: [
                      widget.user.isEnterprise
                          ? _buildTextField()
                          : _buildDocumentUploadCard(
                              title: 'Carte d\'auto-entrepreneur'.tr,
                              image: _autoEntrepreneurCard,
                              onPickImage: ({bool isGallery = false}) =>
                                  _pickImage(true, isGallery),
                            ),
                      const SizedBox(height: 20),
                      _buildDocumentUploadCard(
                        title: 'Carte d\'identité'.tr,
                        image: _identityCard,
                        onPickImage: ({bool isGallery = false}) =>
                            _pickImage(false, isGallery),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),

                  // Upload Button
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadDocuments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Soumettre les documents'.tr,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MovingLineIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required File? image,
    required Function onPickImage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: image != null
            ? Image.file(image, width: 50, height: 50, fit: BoxFit.cover)
            : SizedBox(width: 50, height: 50),
        title: Text(title),
        trailing: Wrap(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => onPickImage(),
            ),
            IconButton(
              icon: Icon(Icons.image,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                onPickImage(isGallery: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _NIFController,
        obscureText: false,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez fournir la carte d\'auto-entrepreneur'.tr;
          }
          return null;
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'NIF',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _NIFController.clear();
                });
              },
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.primary,
              ),
            )),
      ),
    );
  }
}
