import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../models/message.dart';
import 'sheet.dart';

class MessageInputBottomSheet extends StatefulWidget {
  final int conversationID;
  final Function(bool) onRecordingStateChanged;
  final TextEditingController messageController;
  final GlobalKey<SheetState> sheetKey;

  const MessageInputBottomSheet({
    required this.conversationID,
    required this.onRecordingStateChanged,
    required this.messageController,
    required this.sheetKey,
    super.key,
  });

  @override
  MessageInputBottomSheetState createState() => MessageInputBottomSheetState();
}

class MessageInputBottomSheetState extends State<MessageInputBottomSheet> {
  bool isEditing = false;
  bool _isAttachement = false;
  AttachmentType _attachmentType = AttachmentType.none;
  Position? _position;
  List<int> imageBytes = [];

  int? messageUpdatingID;
  String filename = "";
  final FocusNode focusNode = FocusNode();
  late final TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = widget.messageController;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color.fromARGB(34, 255, 131, 131),
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          if (isEditing)
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 52.0, vertical: 4),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Updating message'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (_isAttachement)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_attachmentType == AttachmentType.image
                      ? Icons.image
                      : _attachmentType == AttachmentType.file
                          ? Icons.file_copy
                          : Icons.location_on),
                  onPressed: () async {},
                  tooltip: 'Attach Image'.tr,
                ),
                _position != null
                    ? Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 243, 33, 33),
                        ),
                        child: Text(
                          'Location: ${_position!.latitude.toStringAsFixed(2)}, ${_position!.longitude.toStringAsFixed(2)}'
                              .tr,
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    : imageBytes.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Image.memory(
                              Uint8List.fromList(imageBytes),
                              height: 60,
                            ),
                          )
                        : _attachmentType == AttachmentType.file
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'File: $filename',
                                  style: TextStyle(fontSize: 14),
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
              ],
            ),
          Sheet(
            key: widget.sheetKey,
            messageController: messageController,
            onRecordingStateChanged: widget.onRecordingStateChanged,
            isEditing: isEditing,
            onAttachmentStateChanged: (type, value,{String name = ""}) {
              setState(() {
                switch (type) {
                  case AttachmentType.none:
                    _isAttachement = false;
                    break;
                  case AttachmentType.image:
                    _isAttachement = true;
                    _attachmentType = AttachmentType.image;
                    imageBytes = value;
                    filename = name;
                    break;
                  case AttachmentType.location:
                    _isAttachement = true;
                    _attachmentType = AttachmentType.location;
                    _position = value;
                  case AttachmentType.file:
                    _isAttachement = true;
                    _attachmentType = AttachmentType.file;
                    filename = name;
                    break;
                }
              });
            },
            conversationID: widget.conversationID,
          ),
        ],
      ),
    );
  }
}
