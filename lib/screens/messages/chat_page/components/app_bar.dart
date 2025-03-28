import 'package:ahmini/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../controllers/app_controller.dart';
import '../../../../services/constants.dart';

class ChatPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherUsername, imageURL;
  final int conversationID;
  final GlobalKey<OnlineStatusState> onlineStatusKey = GlobalKey<OnlineStatusState>();
  ChatPageAppBar({
    super.key,
    required this.otherUsername,
    required this.imageURL,
    required this.conversationID,
  });


  @override
  AppBar build(BuildContext context) {
    Get.find<AppController>().chatAppBarKey = onlineStatusKey;
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Hero(
            tag: "hero1 $conversationID",
            child: CircleAvatar(
              radius: 20,
              backgroundColor: secondaryColor,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ClipOval(
                  child: Image.network(
                    "$httpURL/$userAPI${imageURL != "" ? imageURL : "/"}",
                    fit: BoxFit.fill,
                    errorBuilder: (context, url, error) {
                      return Center(
                        child: Material(
                          type: MaterialType.transparency,
                          child: Icon(
                            Icons.person,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: "hero 2 $conversationID",
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  child: Text(
                    otherUsername,
                  ),
                ),
              ),
              OnlineStatus(key:onlineStatusKey),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            // Implement audio call
          },
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
             PopupMenuItem(
              value: 'profile'.tr,
              child: Text('Voir le profil'.tr),
            ),
             PopupMenuItem(
              value: 'search'.tr,
              child: Text('Rechercher'.tr),
            ),
             PopupMenuItem(
              value: 'media'.tr,
              child: Text('Médias partagés'.tr),
            ),
             PopupMenuItem(
              value: 'block'.tr,
              child: Text('Bloquer'.tr),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class OnlineStatus extends StatefulWidget {
  const OnlineStatus({
    super.key,
  });

  @override
  State<OnlineStatus> createState() => OnlineStatusState();
}

class OnlineStatusState extends State<OnlineStatus> {
  bool? online;
  String? lastOnline;
  @override
  Widget build(BuildContext context) {
    print("rebuilt online status state");
    return SafeArea(
      child: Text(
        online == null ? "" : online! ? 'En ligne' :
        lastOnline != null ?  "$lastOnline":'Hors ligne'.tr,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }
}
