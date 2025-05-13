import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class FaqAndHelpScreen extends StatelessWidget {
  const FaqAndHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

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
          title: Text(
            "Assistance".tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: backgroundColorTheme,
                    title: Text(
                      'Aide'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      'Besoin d\'aide ? Contactez notre support technique au 0540274628'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                            'Fermer'.tr,
                            style: TextStyle(color: primaryColorTheme)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nous sommes là pour vous aider avec tout sur l'application Ahmini".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Consultez nos questions fréquemment posées ou envoyez-nous un email..".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
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
                      Text(
                        "FAQ".tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: [
                            faqTile(
                              "Qu'est-ce que Ahmini ?".tr,
                              "Ahmini est une application qui permet aux freelances de trouver des entreprises pour offrir leurs services, et permet aux entreprises de trouver des freelances capables de répondre à leurs besoins, tout en sécurisant les transactions grâce à un contrat signé par les deux parties.".tr,
                              isDark,
                            ),
                            faqTile(
                              "Comment procéder au paiement ?".tr,
                              "Via compte - abonnements, choisir l'abonnement qui vous convient et procédez au paiement en toute sécurité.".tr,
                              isDark,
                            ),
                            faqTile(
                              "Comment être sûr que l'entreprise me paiera ?".tr,
                              "Grâce à un contrat signé par l'entreprise et le freelancer.".tr,
                              isDark,
                            ),
                            faqTile(
                              "Comment être sûr que le freelancer accomplira le travail demandé ?".tr,
                              "Grâce à un contrat signé par l'entreprise et le freelancer.".tr,
                              isDark,
                            ),
                            faqTile(
                              "Comment puis-je demander au freelancer le prix du service ?".tr,
                              "En expliquant le travail demandé à ce freelancer via le chat, et il pourra proposer un prix.".tr,
                              isDark,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            "Toujours bloqué ? Nous sommes à un mail près".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColorTheme,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () {

                              },
                              child: Text(
                                "Envoyer un message".tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget faqTile(String question, String answer, bool isDark) {
    return Column(
      children: [
        ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          iconColor: isDark ? Colors.white : Colors.black87,
          collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        Divider(thickness: 0.6, height: 0, color: isDark ? Colors.white24 : Colors.grey),
      ],
    );
  }
}

