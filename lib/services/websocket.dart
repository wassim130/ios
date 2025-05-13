import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ahmini/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Stream? _broadcastStream;
  String? _roomName;

  Future<bool> connect(String roomName) async {
    try {
      _roomName = roomName;
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      _channel = IOWebSocketChannel.connect(
        'ws://$baseURL/$websocketAPI/$roomName/?sessionid=$sessionCookie',
        pingInterval: Duration(seconds: 5),
        connectTimeout: Duration(seconds: 5),
      );

      _broadcastStream = _channel!.stream.asBroadcastStream();
      return _broadcastStream == null ? false : true;
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      return false;
    }
  }

  Future<void> sendMessage(
      int roomName,
      MessagesModel message,
      String? base64File,
      String? fileName,
      ) async {
    if (_channel != null) {
      if (message.attachmentType == AttachmentType.audio) {
        // For audio messages, upload the file first
        print("Sending audio message with duration: ${message.audioDuration}");
        await _uploadAudioFile(message, base64File, fileName);
      } else {
        // For other message types, send directly through WebSocket
        _channel!.sink.add(jsonEncode({
          "type": "new_message",
          "message": {
            "roomName": roomName,
            ...message.toMap(),
            ...?base64File != null ? {"file": base64File} : null,
            ...?fileName != null ? {"filename": fileName} : null,
          },
        }));
      }
    }
  }

  Future<void> _uploadAudioFile(
      MessagesModel message,
      String? base64Data,
      String? fileName,
      ) async {
    if (base64Data == null || fileName == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');

      if (sessionCookie == null || sessionCookie.isEmpty) {
        debugPrint('Error: No session cookie found');
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$httpURL/api/chat/upload-audio/'),
      );

      // Add session cookie to headers
      request.headers['Cookie'] = 'sessionid=$sessionCookie';

      // For debugging - print the headers
      debugPrint('Request headers: ${request.headers}');

      final bytes = base64Decode(base64Data);
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          bytes,
          filename: fileName,
        ),
      );
      request.fields['conversationID'] = _roomName ?? '';
      request.fields['duration'] = message.audioDuration?.toString() ?? '0';

      print("Uploading audio file:");
      print("Conversation ID: $_roomName");
      print("Duration: ${message.audioDuration}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(responseBody);
        message.attachmentUrl = jsonData['fileUrl'];

        print("Audio upload successful. File URL: ${message.attachmentUrl}");

        _channel!.sink.add(jsonEncode({
          "type": "new_message",
          "message": {
            "roomName": int.parse(_roomName ?? '0'),
            ...message.toMap(),
            "audioDuration": message.audioDuration,
          },
        }));
      } else {
        debugPrint('Failed to upload audio: ${response.statusCode}');
        debugPrint('Error response: $responseBody');
      }
    } catch (e) {
      debugPrint('Error uploading audio: $e');
    }
  }

  void markMessageAsRead(List<int> messageIDs) {
    if (_channel != null && messageIDs.isNotEmpty) {
      _channel!.sink.add(jsonEncode({
        "type": "mark_messages_as_read",
        "messageIDs": messageIDs,
      }));
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void fetchOlder(int messageID) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "fetch_older",
        "messageID": messageID,
      }));
    }
  }

  void updateReaction(int messageID, String reaction) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "update_reaction",
        "messageID": messageID,
        "reaction": reaction,
      }));
    }
  }

  void updateMessageContent(int messageID, String content) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "update_content",
        "messageID": messageID,
        "content": content,
      }));
    }
  }

  void deleteMessage(int messageID) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "delete_message",
        "messageID": messageID,
      }));
    }
  }

  Stream? get stream => _broadcastStream;

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
    }
  }
}
