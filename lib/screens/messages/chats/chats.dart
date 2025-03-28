// chats.dart
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/global_websocket.dart';
import '../../../providers/global_websocket.dart';
import 'components/app_bar.dart';
import 'components/search_bar.dart';
import 'components/stream_builder.dart';
import '../../../controllers/theme_controller.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  late final GlobalWebSocketService _webSocketService;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void dispose() {
    _webSocketService.disconnect();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initWebSocket();
  }

  void initWebSocket() async {
    _webSocketService = GlobalWebSocketService();
    await _webSocketService.connect();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;

      return GlobalWebSocketProvider(
        webSocketService: _webSocketService,
        child: Scaffold(
          backgroundColor: primaryColorTheme,
          appBar: ChatAppBar(),
          body: Column(
            children: [
              // Barre de recherche
              MySearchBar(searchController: searchController),
              // Section principale avec les conversations
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColorTheme,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: MyStreamBuilder(searchController: searchController)),
              ),
            ],
          ),
        ),
      );
    });
  }
}

