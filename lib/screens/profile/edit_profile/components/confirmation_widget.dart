import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/app_controller.dart';

import '../../../../models/user.dart';

import '../../../../services/user.dart';

class ConfirmationWidget extends StatefulWidget {
  final Map<String, String> body;
  final BuildContext dialogContext;
  final Function parentSetState;
  const ConfirmationWidget({super.key, required this.body, required this.dialogContext,required this.parentSetState});

  @override
  State<ConfirmationWidget> createState() => _ConfirmationWidgetState();
}

class _ConfirmationWidgetState extends State<ConfirmationWidget> {
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordIncorrect = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirmation'.tr,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Veuillez entrer votre mot de passe pour confirmer les modifications'.tr),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: primaryColor,
                    size: 22,
                  ),
                  labelText: 'Mot de passe'.tr,
                  filled: true,
                  fillColor: secondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2,
                    ),
                  ),
                  errorText:
                      isPasswordIncorrect ? 'Mot de passe incorrect' : null,
                ),
                onChanged: (value){
                  if(isPasswordIncorrect){
                    setState(() {
                      isPasswordIncorrect = false;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(widget.dialogContext),
              child: Text(
                'Annuler'.tr,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                _handleUpdate();
              },
              child: Text('Confirmer'.tr),
            ),
          ],
        );
      },
    );
  }

  void _handleUpdate() async {
    widget.body["password"] = passwordController.text.trim();
    final data = await UserService.updateProfile(widget.body);
    if (mounted) {
      switch (data['status']) {
        case 'success':
          Get.find<AppController>().user = UserModel.fromMap(data['user']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profil mis à jour avec succès!'.tr),
              backgroundColor: Colors.green,
            ),
          );
          final UserModel user= UserModel.fromMap(data['user']);
          Get.find<AppController>().user = user;
          Get.find<AppController>().mainScreenKey!.currentState!.setState(() {
             Get.find<AppController>().mainScreenKey!.currentState!.user = user;
          });
          widget.parentSetState(user);
          break;
        case 'error':
          if (data['message'] == 'Incorrect password'.tr) {
            isPasswordIncorrect = true;
            setState(() {});
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${data['message']}'.tr),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case 'connection_error':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de connexion: ${data['message']}'.tr),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
      Navigator.pop(context);
    }
  }
}
