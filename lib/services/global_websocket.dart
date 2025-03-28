import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'constants.dart';

class GlobalWebSocketService {
  WebSocketChannel? _channel;
  Stream? _broadcastStream;

  Future<bool> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    if (sessionCookie == null) {
      return false;
    }
    _channel = IOWebSocketChannel.connect(
      'ws://$baseURL/$websocketGlobalAPI/?sessionid=$sessionCookie',
      pingInterval: Duration(seconds: 5),
      connectTimeout: Duration(seconds: 5),
    );

    _broadcastStream = _channel!.stream.asBroadcastStream();
    return _broadcastStream == null ? false : true;
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
    }
  }

  Stream? get stream => _channel?.stream;
}
