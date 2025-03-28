import 'dart:convert';

import 'package:geolocator/geolocator.dart';

enum AttachmentType {
  none,
  image,
  location,
}

AttachmentType attachmentTypeFromInt(int? value) {
  switch (value) {
    case 1:
      return AttachmentType.image;
    case 2:
      return AttachmentType.location;
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
    };
  }

  static MessagesModel fromMap(Map<String, dynamic> map) {
    if (map['location'] != null) {
      var location = jsonDecode(map['location']);
      if (location['floor'] == "null") {
        location['floor'] = null;
      }
      map['location'] = Position.fromMap(location);
    }
    return MessagesModel(
      messageID: map['messageID'],
      content: map['content'],
      sender: map['sender'].toString(),
      mine: map['mine'],
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
      isRead: map['isRead'] == 1 ? true : false,
      attachmentType: attachmentTypeFromInt(map['attachmentType']),
      attachmentUrl: map['attachmentUrl'],
      location: map['location'],
      reaction: map['reaction'],
      deleted: map['deleted'] == 1 ? true : false,
    );
  }
}
