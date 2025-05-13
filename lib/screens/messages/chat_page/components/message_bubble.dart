import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../models/message.dart';

import '../../../../services/websocket.dart';

import '../../../../providers/chat_websocket.dart';
import 'attachments/file.dart';
import 'attachments/image.dart';
import 'attachments/location.dart';
import 'attachments/audio.dart';
import 'bottom_sheet.dart';
import 'sheet.dart';

class MessageBubble extends StatefulWidget {
  final MessagesModel message;
  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late WebSocketService? _webSocketService;
  late TextEditingController? _messageController;
  late GlobalKey<SheetState>? sheetKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _webSocketService = WebSocketProvider.of(context)?.webSocketService;
    sheetKey = WebSocketProvider.of(context)?.sheetKey;
    _messageController = sheetKey?.currentState?.messageController;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to see message details
    print("Building message bubble for message ID: ${widget.message.messageID}");
    print("Attachment type: ${widget.message.attachmentType}");
    print("Attachment URL: ${widget.message.attachmentUrl}");
    print("Audio duration: ${widget.message.audioDuration}");

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onDoubleTap: () => widget.message.mine || widget.message.deleted
            ? null
            : _showReactionPicker(widget.message),
        onLongPress: () =>
        widget.message.deleted ? null : _showMessageOptions(widget.message),
        child: Align(
          alignment: widget.message.mine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: widget.message.mine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageCard(),
                if (widget.message.replyCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${widget.message.replyCount} réponses'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card _buildMessageCard() {
    return Card(
      elevation: 1,
      color: widget.message.mine
          ? primaryColor
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: widget.message.mine
            ? BorderSide.none
            : BorderSide(color: Colors.grey.shade200),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: widget.message.mine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (widget.message.attachmentType != AttachmentType.none)
                  _buildAttachment(widget.message),
                if (widget.message.deleted ||
                    (!widget.message.deleted &&
                        widget.message.content.isNotEmpty))
                  Text(
                    widget.message.deleted
                        ? "${widget.message.sender} unsent a message"
                        : widget.message.content,
                    style: TextStyle(
                      color:
                      widget.message.mine ? Colors.white : Colors.black87,
                    ),
                  ),
                if (!widget.message.deleted &&
                    widget.message.content.isNotEmpty)
                  const SizedBox(height: 4),
                _buildMessageTimestamp(),
              ],
            ),
          ),
          if (widget.message.reaction != null)
            Positioned(
              bottom: -10,
              right: widget.message.mine ? null : -10,
              left: widget.message.mine ? -10 : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  widget.message.reaction!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Row _buildMessageTimestamp() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('HH:mm'.tr).format(widget.message.timestamp),
          style: TextStyle(
            fontSize: 11,
            color: widget.message.mine
                ? Colors.white.withOpacity(0.7)
                : Colors.black54,
          ),
        ),
        if (widget.message.mine) ...[
          const SizedBox(width: 4),
          Icon(
            widget.message.isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: widget.message.mine
                ? Colors.white.withOpacity(0.7)
                : Colors.black54,
          ),
        ],
      ],
    );
  }

  void _showReactionPicker(MessagesModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: ['❤️'.tr, '👍'.tr, '😊'.tr, '😮'.tr, '😢'.tr, '😡'].map((emoji) {
            return InkWell(
              onTap: () {
                _webSocketService?.send({
                  'type': 'update_reaction'.tr,
                  'messageID': message.messageID,
                  'reaction': emoji,
                });
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMessageOptions(MessagesModel message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.reply, color: Colors.blue.shade700),
              title:  Text('Répondre'.tr),
              onTap: () {
                Navigator.pop(context);
                // Implémenter la réponse
              },
            ),
            ListTile(
              leading: Icon(Icons.forward, color: Colors.green.shade700),
              title:  Text('Transférer'.tr),
              onTap: () {
                Navigator.pop(context);
                // Implémenter le transfert
              },
            ),
            if (message.mine)
              ListTile(
                leading: Icon(Icons.edit, color: Colors.orange.shade700),
                title:  Text('Modifier'.tr),
                onTap: () {
                  sheetKey!.currentState!.setState(() {
                    _messageController!.text = message.content;
                    sheetKey!.currentState!.messageUpdatingID =
                        message.messageID;
                    sheetKey!.currentState!.isEditing = true;
                    Navigator.pop(context);
                    Future.delayed(Duration(milliseconds: 500), () {
                      sheetKey!.currentState!.focusNode.requestFocus();
                    });
                  });
                },
              ),
            if (message.mine)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title:  Text('Supprimer'.tr),
                onTap: () {
                  _webSocketService?.send({
                    'type': 'delete_message'.tr,
                    'messageID': message.messageID,
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(MessagesModel message) {
    print("Building attachment for type: ${message.attachmentType}");

    switch (message.attachmentType) {
      case AttachmentType.image:
        return ImageAttachment(message: message);
      case AttachmentType.location:
        if (message.location != null) {
          return LocationAttachement(
            latitude: message.location!.latitude,
            longitude: message.location!.longitude,
          );
        }
        return Text("Location unavailable", style: TextStyle(color: Colors.red));
      case AttachmentType.file:
        return FileAttachment(message: message);
      case AttachmentType.audio:
        print("Rendering audio attachment with URL: ${message.attachmentUrl}");
        return AudioAttachment(message: message);
      default:
        print("Unknown attachment type: ${message.attachmentType}");
        return const SizedBox.shrink();
    }
  }
}
