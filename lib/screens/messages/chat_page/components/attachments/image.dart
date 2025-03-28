import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../services/constants.dart';
import '../../../../../models/message.dart';

class ImageAttachment extends StatelessWidget {
  final MessagesModel message;
  const ImageAttachment({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondAnimation) => Scaffold(
                backgroundColor: const Color.fromARGB(129, 0, 0, 0),
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                  title: Text(
                    'Image'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share, size: 18),
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert, size: 18),
                      color: Colors.white,
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Hero(
                      tag: 'hero ${message.messageID}'.tr,
                      child: Image.network(
                        "$httpURL/api/chat${message.attachmentUrl ?? "unknown"}",
                        errorBuilder: (context, error, stacktrace) =>
                            Image.asset(
                          message.attachmentUrl ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image non disponible'.tr,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Hero(
            tag: 'hero ${message.messageID}'.tr,
            child: AuthenticatedImage(
              url: "$httpURL/api/chat${message.attachmentUrl}",
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticatedImage extends StatelessWidget {
  final String url;

  const AuthenticatedImage({super.key, required this.url});

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
    return FutureBuilder<Map<String, String>>(
      future: _getHeaders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final headers = snapshot.data ?? {};

        // return CachedNetworkImage(
        //   imageUrl: url,
        //   httpHeaders: headers,
        //   fit: BoxFit.cover,
        //   errorWidget: (context, url, error) {
        //     return Container(
        //       color: Colors.grey.shade200,
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(
        //             Icons.image_not_supported,
        //             size: 48,
        //             color: Colors.grey.shade400,
        //           ),
        //           const SizedBox(height: 8),
        //           Text(
        //             'Image non disponible'.tr,
        //             style: TextStyle(
        //               color: Colors.grey.shade600,
        //               fontSize: 12,
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        //   placeholder: (context, url) =>
        //       Center(child: CircularProgressIndicator()),
        //   imageBuilder: (context, imageProvider) {
        //     return Image(
        //       image: imageProvider,
        //       fit: BoxFit.cover,
        //     );
        //   },
        // );
        return Image.network(
          url,
          headers: headers,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stacktrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image non disponible'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
