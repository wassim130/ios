import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../services/websocket.dart';

import '../../../../models/message.dart';

import '../../../../providers/chat_websocket.dart';

class Sheet extends StatefulWidget {
  final TextEditingController messageController;
  final int conversationID;
  final Function(bool) onRecordingStateChanged;
  final Function(dynamic, dynamic) onAttachmentStateChanged;
  final bool isEditing;

  const Sheet({
    required this.conversationID,
    required this.onRecordingStateChanged,
    required this.onAttachmentStateChanged,
    required this.messageController,
    required this.isEditing,
    super.key,
  });

  @override
  State<Sheet> createState() => SheetState();
}

class SheetState extends State<Sheet> {
  bool _showEmoji = false;
  bool _isTyping = false;
  bool isEditing = false;
  bool _isAttachement = false;
  AttachmentType _attachmentType = AttachmentType.none;
  Position? _position;
  String? image64Base;
  String? imageName;
  List<int> imageBytes = [];

  int? messageUpdatingID;

  final FocusNode focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController messageController;
  late final WebSocketService? _webSocketService;

  @override
  void initState() {
    messageController = widget.messageController;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _webSocketService = WebSocketProvider.of(context)?.webSocketService;
    super.didChangeDependencies();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    _attachmentType = AttachmentType.location;
    _isAttachement = true;
    setState(() {});
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _position = position;
    });
    widget.onAttachmentStateChanged(_attachmentType, _position);
  }

  Future<void> _getImage(ImageSource source) async {
    _attachmentType = AttachmentType.image;
    _isAttachement = true;
    XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      File file = File(image.path);
      imageBytes = await file.readAsBytes();
      image64Base = base64Encode(imageBytes);
      imageName = image.path.split('/'.tr).last;
    } else {
      _attachmentType = AttachmentType.none;
      _isAttachement = false;
    }
    setState(() {});
    widget.onAttachmentStateChanged(_attachmentType, imageBytes);
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(Icons.image, 'Photo'.tr, Colors.purple,
                    function: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                }),
                _buildAttachmentOption(
                  Icons.location_on,
                  'Location'.tr,
                  Colors.green,
                  function: () {
                    Navigator.pop(context);
                    _getLocation();
                  },
                ),
                _buildAttachmentOption(
                    Icons.contact_page, 'Contact'.tr, Colors.blue),
                _buildAttachmentOption(
                    Icons.file_copy, 'Document'.tr, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color,
      {Function? function = null}) {
    return TextButton(
      onPressed: () {
        if (function != null) {
          function();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _sendMessage() {
    final String messageText = messageController.text.trim();
    if (messageText.isEmpty && !_isAttachement) return;

    _isTyping = false;
    if (messageUpdatingID != null) {
      _webSocketService?.send({
        "type": "update_content",
        "messageID": messageUpdatingID,
        "content": messageText,
      });
      messageController.clear();
    } else {
      if ((_attachmentType == AttachmentType.location && _position != null) ||
          (_attachmentType == AttachmentType.image && image64Base != null) ||
          !_isAttachement) {
        final MessagesModel message = MessagesModel(
          messageID: 10,
          content: messageText,
          sender: '1'.tr,
          location: _position,
          mine: true,
          attachmentType: _attachmentType,
          timestamp: DateTime.now().toUtc(),
        );

        _webSocketService?.sendMessage(
            widget.conversationID, message, image64Base, imageName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please wait for attachement to load...'.tr),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    setState(() {
      _removeAttachment();
    });
  }

  void _startRecording() {
    widget.onRecordingStateChanged(true);
  }

  void _removeAttachment() {
    messageController.text = "";
    _isAttachement = false;
    isEditing = false;
    _attachmentType = AttachmentType.none;
    messageUpdatingID = null;
    _position = null;
    image64Base = null;
    imageBytes = [];
    imageName = null;
    widget.onAttachmentStateChanged(_attachmentType, null);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isEditing || _isAttachement
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _removeAttachment();
                  });
                },
              )
            : IconButton(
                icon: Icon(_showEmoji
                    ? Icons.keyboard
                    : Icons.emoji_emotions_outlined),
                onPressed: () {
                  setState(() {
                    _showEmoji = !_showEmoji;
                  });
                },
              ),
        Expanded(
          child: Column(
            children: [
              if (isEditing)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text("Editing",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 105, 105, 105),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: TextField(
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: messageController,
                          focusNode: focusNode,
                          onChanged: (value) {
                            setState(() {
                              _isTyping = value.isNotEmpty;
                            });
                          },
                          decoration:  InputDecoration(
                            hintText: 'Message...'.tr,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _showAttachmentOptions,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => _getImage(ImageSource.camera),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor:  primaryColor,
          child: IconButton(
            icon: Icon(
              isEditing
                  ? Icons.update
                  : _isTyping || _isAttachement
                      ? Icons.send
                      : Icons.mic,
              color: Colors.white,
            ),
            onPressed:
                _isTyping || _isAttachement ? _sendMessage : _startRecording,
          ),
        ),
      ],
    );
  }
}
