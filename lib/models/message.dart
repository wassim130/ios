import 'dart:convert';
import 'package:geolocator/geolocator.dart';

enum AttachmentType {
  none,
  image,
  location,
  video,
  audio,
  file,
}

AttachmentType attachmentTypeFromInt(int? value) {
  switch (value) {
    case 1:
      return AttachmentType.image;
    case 2:
      return AttachmentType.location;
    case 3:
      return AttachmentType.video;
    case 4:  // Changed from 3 to 4 to match Django model
      return AttachmentType.audio;
    case 5:
      return AttachmentType.file;
    default:
      return AttachmentType.none;
  }
}

// Helper function to handle string attachment types
AttachmentType attachmentTypeFromString(String? value) {
  if (value == null) return AttachmentType.none;

  switch (value.toLowerCase()) {
    case 'image':
      return AttachmentType.image;
    case 'location':
      return AttachmentType.location;
    case 'video':
      return AttachmentType.video;
    case 'audio':
      return AttachmentType.audio;
    case 'file':
      return AttachmentType.file;
    default:
      return AttachmentType.none;
  }
}

class MessagesModel {
  final int messageID;
  final String sender;
  final bool mine;
  final DateTime timestamp;
  AttachmentType attachmentType;
  String? attachmentUrl;
  Position? location;
  String content;
  bool isRead;
  String? reaction;
  int? replyCount;
  bool deleted;
  int? audioDuration; // Added for audio messages

  MessagesModel({
    required this.messageID,
    required this.content,
    required this.sender,
    required this.mine,
    required this.timestamp,
    this.isRead = false,
    this.attachmentType = AttachmentType.none,
    this.attachmentUrl,
    this.location,
    this.reaction,
    this.replyCount,
    this.deleted = false,
    this.audioDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageID': messageID,
      'content': content,
      'sender': sender,
      'mine': mine,
      'timestamp': timestamp.toString(),
      'isRead': isRead,
      'attachmentType': attachmentType.index,
      'attachmentUrl': attachmentUrl,
      'location': location?.toJson(),
      'reaction': reaction,
      'deleted': deleted,
      'audioDuration': audioDuration,
    };
  }

  static MessagesModel fromMap(Map<String, dynamic> map) {
    print("Processing message: $map");

    // Handle location data
    if (map['location'] != null) {
      var location = jsonDecode(map['location']);
      if (location['floor'] == "null") {
        location['floor'] = null;
      }
      map['location'] = Position.fromMap(location);
    }

    // Determine attachment type
    AttachmentType attachmentType;
    if (map['attachmentType'] is int || map['attachmentType'] is int?) {
      attachmentType = attachmentTypeFromInt(map['attachmentType']);
    } else if (map['attachmentType'] is String) {
      attachmentType = attachmentTypeFromString(map['attachmentType']);
    } else {
      attachmentType = AttachmentType.none;
    }

    print("Attachment type: $attachmentType");
    print("Attachment URL: ${map['attachmentUrl']}");
    print("Audio duration: ${map['audioDuration']}");

    return MessagesModel(
      messageID: map['messageID'],
      content: map['content'] ?? '',
      sender: map['sender'].toString(),
      mine: map['mine'] ?? false,
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
      isRead: map['isRead'] == 1 ? true : false,
      attachmentType: attachmentType,
      attachmentUrl: map['attachmentUrl'],
      location: map['location'],
      reaction: map['reaction'],
      deleted: map['deleted'] == 1 ? true : false,
      audioDuration: map['audioDuration'],
    );
  }
}
