import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../services/websocket.dart';
import '../../../../services/audio_recorder.dart';

import '../../../../models/message.dart';

import '../../../../providers/chat_websocket.dart';

class Sheet extends StatefulWidget {
  final TextEditingController messageController;
  final int conversationID;
  final Function(bool) onRecordingStateChanged;
  final Function onAttachmentStateChanged;
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
  String? file64Base;
  String? fileName;
  List<int> fileBytes = [];
  String? _audioPath;
  int? _audioDuration;

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

  Future<void> _getFile() async {
    _attachmentType = AttachmentType.file;
    _isAttachement = true;
    XFile? file = await _picker.pickMedia();
    _proccessFile(file);
  }

  Future<void> _getImage(ImageSource source) async {
    _attachmentType = AttachmentType.image;
    _isAttachement = true;
    XFile? image = await _picker.pickImage(source: source);
    _proccessFile(image);
  }

  Future<void> _proccessFile(XFile? file) async {
    if (file != null) {
      fileBytes = await file.readAsBytes();
      file64Base = base64Encode(fileBytes);
      print("bytes $file64Base");
      fileName = file.path.split('/').last;
    } else {
      _attachmentType = AttachmentType.none;
      _isAttachement = false;
    }
    setState(() {});
    widget.onAttachmentStateChanged(_attachmentType, fileBytes, name: fileName);
  }

  void processAudioRecording(String path, int duration) {
    setState(() {
      _attachmentType = AttachmentType.audio;
      _isAttachement = true;
      _audioPath = path;
      _audioDuration = duration;

      // Read file and convert to base64
      final file = File(path);
      fileBytes = file.readAsBytesSync();
      file64Base = base64Encode(fileBytes);
      fileName = path.split('/').last;
    });

    widget.onAttachmentStateChanged(_attachmentType, fileBytes, name: fileName);

    // Auto-send the audio message
    _sendMessage();
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
                    Icons.file_copy, 'Document'.tr, Colors.orange,
                    function: () {
                      _getFile();
                    }),
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
          ((_attachmentType == AttachmentType.image ||
              _attachmentType == AttachmentType.file ||
              _attachmentType == AttachmentType.audio) &&
              file64Base != null) ||
          !_isAttachement) {
        final MessagesModel message = MessagesModel(
          messageID: 10,
          content: messageText,
          sender: '1'.tr,
          location: _position,
          mine: true,
          attachmentType: _attachmentType,
          timestamp: DateTime.now().toUtc(),
          audioDuration: _audioDuration,
        );

        _webSocketService?.sendMessage(
            widget.conversationID, message, file64Base, fileName);
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
    file64Base = null;
    fileBytes = [];
    fileName = null;
    _audioPath = null;
    _audioDuration = null;
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
                          decoration: InputDecoration(
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
          backgroundColor: primaryColor,
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
