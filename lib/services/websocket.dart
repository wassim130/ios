import 'dart:async';
import 'dart:convert';

import 'package:ahmini/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Stream? _broadcastStream;

  Future<bool> connect(String roomName) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    _channel = IOWebSocketChannel.connect(
      'ws://$baseURL/$websocketAPI/$roomName/?sessionid=$sessionCookie',
      pingInterval: Duration(seconds: 5),
      connectTimeout: Duration(seconds: 5),
    );

    _broadcastStream = _channel!.stream.asBroadcastStream();
    return _broadcastStream == null ? false : true;
  }

  void sendMessage(int roomName, MessagesModel message,String? base64Image,String? imageName ) {
    // _channel!.sink.add();
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "new_message",
        "message": {
          "roomName": roomName,
          ...message.toMap(),
          ...?base64Image != null ? {"file": base64Image} : null,
          ...?imageName != null ? {"filename": imageName} : null,
        },
      }));
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

  void send(data) {
    _channel!.sink.add(jsonEncode(data));
  }

  void fetchOlder(int messageID) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        "type": "fetch_older",
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
