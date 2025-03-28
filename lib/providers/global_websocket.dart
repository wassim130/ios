import 'package:flutter/material.dart';

import '../services/global_websocket.dart';

class GlobalWebSocketProvider extends InheritedWidget {
  final GlobalWebSocketService webSocketService;

  const GlobalWebSocketProvider({
    super.key,
    required this.webSocketService,
    required super.child,
  });

  static GlobalWebSocketProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlobalWebSocketProvider>();
  }

  @override
  bool updateShouldNotify(GlobalWebSocketProvider oldWidget) {
    return oldWidget.webSocketService != webSocketService;
  }
}
