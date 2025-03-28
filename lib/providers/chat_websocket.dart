import 'package:flutter/material.dart';

import '../screens/messages/chat_page/components/sheet.dart';
import '../services/websocket.dart';
import '../screens/messages/chat_page/components/bottom_sheet.dart';

class WebSocketProvider extends InheritedWidget {
  final WebSocketService webSocketService;
  final GlobalKey<SheetState> sheetKey;

  const WebSocketProvider({
    super.key,
    required this.webSocketService,
    required this.sheetKey,
    required Widget child,
  }) : super(child: child);

  static WebSocketProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WebSocketProvider>();
  }

  @override
  bool updateShouldNotify(WebSocketProvider oldWidget) {
    return oldWidget.webSocketService != webSocketService;
  }
}
