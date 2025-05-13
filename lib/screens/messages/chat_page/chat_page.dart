import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/websocket.dart';
import '../../../controllers/theme_controller.dart';
import 'components/recording_overlay.dart';
import 'components/message.dart';
import 'components/bottom_sheet.dart';
import 'components/app_bar.dart';
import '../../../providers/chat_websocket.dart';
import 'components/sheet.dart';

class ChatPage extends StatefulWidget {
  final int conversationID;
  final String otherUsername, imageURL;

  const ChatPage(
      this.conversationID, {
        super.key,
        required this.otherUsername,
        required this.imageURL,
      });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final WebSocketService _webSocketService;
  bool isRecording = false;
  final GlobalKey<RecordingOverlayState> recordingOverlayKey =
  GlobalKey<RecordingOverlayState>();
  final GlobalKey<MessagesListState> messageListKey =
  GlobalKey<MessagesListState>();
  final GlobalKey<SheetState> sheetKey =
  GlobalKey<SheetState>();
  final TextEditingController _messageController = TextEditingController();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    _initializeSocket();
    super.initState();
  }

  Future<void> _initializeSocket() async {
    _webSocketService = WebSocketService();
    final String roomName = '${widget.conversationID}';
    await _webSocketService.connect(roomName);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _handleRecordingComplete(String audioPath, int duration) {
    // Process the recorded audio
    sheetKey.currentState?.setState(() {
      sheetKey.currentState!.processAudioRecording(audioPath, duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;

      return WebSocketProvider(
        webSocketService: _webSocketService,
        sheetKey: sheetKey,
        child: Scaffold(
          backgroundColor: primaryColorTheme,
          appBar: ChatPageAppBar(
            otherUsername: widget.otherUsername,
            imageURL: widget.imageURL,
            conversationID: widget.conversationID,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? darkSecondaryColor : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _webSocketService.stream == null
                          ? Center(child: CircularProgressIndicator(color: primaryColorTheme))
                          : MessagesList(
                        key: messageListKey,
                        conversationID: widget.conversationID,
                      ),
                    ),
                  ),
                  MessageInputBottomSheet(
                    sheetKey: sheetKey,
                    conversationID: widget.conversationID,
                    messageController: _messageController,
                    onRecordingStateChanged: (bool recording) {
                      if (recording) {
                        recordingOverlayKey.currentState?.startRecording();
                      }
                    },
                  ),
                ],
              ),
              RecordingOverlay(
                key: recordingOverlayKey,
                onRecordingComplete: _handleRecordingComplete,
              ),
            ],
          ),
        ),
      );
    });
  }
}
