// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../../models/user.dart';
// import '../../services/auth.dart';
// import '../../services/constants.dart';

// class DocumentVerificationPage extends StatefulWidget {
//   final UserModel user;
//   const DocumentVerificationPage({Key? key, required this.user}) : super(key: key);

//   @override
//   _DocumentVerificationPageState createState() => _DocumentVerificationPageState();
// }

// class _DocumentVerificationPageState extends State<DocumentVerificationPage> {
//   File? _autoEntrepreneurCard;
//   File? _identityCard;
//   bool _isUploading = false;

//   Future<void> _pickImage(bool isAutoEntrepreneur) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         if (isAutoEntrepreneur) {
//           _autoEntrepreneurCard = File(pickedFile.path);
//         } else {
//           _identityCard = File(pickedFile.path);
//         }
//       });
//     }
//   }

//   Future<void> _uploadDocuments() async {
//     if (_autoEntrepreneurCard == null || _identityCard == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Veuillez télécharger les deux documents'.tr),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       // Prepare multipart request
//       var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('$httpURL/$authAPI/upload-freelancer-documents/')
//       );

//       // Add user ID or other necessary authentication details
//       request.fields['user_id'] = widget.user.id.toString();

//       // Add files to the request
//       request.files.add(
//           await http.MultipartFile.fromPath(
//               'auto_entrepreneur_card',
//               _autoEntrepreneurCard!.path
//           )
//       );
//       request.files.add(
//           await http.MultipartFile.fromPath(
//               'identity_card',
//               _identityCard!.path
//           )
//       );

//       // Send the request
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();
//       var parsedResponse = json.decode(responseBody);

//       if (response.statusCode == 200) {
//         // Documents uploaded successfully
//         _showVerificationPendingDialog();
//       } else {
//         // Handle upload error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(parsedResponse['message'] ?? 'Échec du téléchargement'.tr),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur de connexion'.tr),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   void _showVerificationPendingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Vérification en cours'.tr),
//           content: Text(
//               'Vos documents ont été soumis avec succès. Votre compte est en cours de vérification par l\'administrateur. '
//                   'Vous serez informé une fois que votre compte sera approuvé.'.tr
//           ),
//           actions: [
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 // Déconnexion et retour à l'écran de connexion
//                 AuthService.logout();
//                 Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 190, 49, 68),
//       appBar: AppBar(
//         title: Text('Vérification de compte'.tr),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'En tant que freelancer, vous devez soumettre deux documents pour la vérification'.tr,
//               style: TextStyle(color: Colors.white, fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),

//             // Auto-Entrepreneur Card Upload
//             _buildDocumentUploadCard(
//               title: 'Carte d\'auto-entrepreneur'.tr,
//               image: _autoEntrepreneurCard,
//               onPickImage: () => _pickImage(true),
//             ),
//             const SizedBox(height: 20),

//             // Identity Card Upload
//             _buildDocumentUploadCard(
//               title: 'Carte d\'identité'.tr,
//               image: _identityCard,
//               onPickImage: () => _pickImage(false),
//             ),
//             const SizedBox(height: 30),

//             // Upload Button
//             ElevatedButton(
//               onPressed: _isUploading ? null : _uploadDocuments,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//               ),
//               child: _isUploading
//                   ? CircularProgressIndicator(color: Color.fromARGB(255, 190, 49, 68))
//                   : Text(
//                 'Soumettre les documents'.tr,
//                 style: TextStyle(color: Color.fromARGB(255, 190, 49, 68)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDocumentUploadCard({
//     required String title,
//     required File? image,
//     required VoidCallback onPickImage,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         title: Text(title),
//         trailing: image == null
//             ? IconButton(
//           icon: Icon(Icons.camera_alt, color: Color.fromARGB(255, 190, 49, 68)),
//           onPressed: onPickImage,
//         )
//             : Image.file(image, width: 50, height: 50, fit: BoxFit.cover),
//         onTap: onPickImage,
//       ),
//     );
//   }
// }

// // Modification in AuthService to handle account verification status
// extension AuthServiceExtension on AuthService {
//   static Future<bool> isAccountVerified() async {
//     final prefs = await SharedPreferences.getInstance();
//     final sessionCookie = prefs.getString('session_cookie');

//     try {
//       final response = await http.get(
//         Uri.parse('$httpURL/$authAPI/check-verification-status/'),
//         headers: {
//           'Cookie': "sessionid=$sessionCookie",
//         },
//       ).timeout(Duration(seconds: timeout));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['is_verified'] ?? false;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }
// }