import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/app_controller.dart';
import '../../../../services/websocket.dart';

import '../../../../models/message.dart';
import '../../../../models/user.dart';

import 'app_bar.dart';
import 'message_bubble.dart';
import 'date_seperator.dart';
import 'group_header.dart';
import '../../../../providers/chat_websocket.dart';

bool isSameDay(DateTime date1, {DateTime? date2}) {
  date2 = date2 ?? DateTime.now();
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool isWithinLastWeek(DateTime timestamp) {
  DateTime lastWeek = DateTime.now().subtract(Duration(days: 6));
  lastWeek = DateTime(lastWeek.year, lastWeek.month, lastWeek.day);

  return timestamp.isAfter(lastWeek);
}

class MessagesList extends StatefulWidget {
  final int conversationID;
  const MessagesList({
    super.key,
    required this.conversationID,
  });

  @override
  State<MessagesList> createState() => MessagesListState();
}

class MessagesListState extends State<MessagesList>
    with TickerProviderStateMixin {
  List<MessagesModel> messages = [];
  late WebSocketService? webSocketService;
  final ScrollController _scrollController = ScrollController();
  late UserModel user;
  bool isFetching = false;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    user = Get.find<AppController>().user!;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    webSocketService = WebSocketProvider.of(context)?.webSocketService;
    super.didChangeDependencies();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 250 &&
        !isFetching) {
      isFetching = true;
      webSocketService?.fetchOlder(messages.first.messageID);
    }
  }

  Future<bool?> reconnect() async {
    final provider = WebSocketProvider.of(context)?.webSocketService;
    return await provider?.connect(widget.conversationID.toString());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: webSocketService?.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              messages.isEmpty) {
            return Center(child: CircularProgressIndicator(color: Colors.pink));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Future.delayed(Duration(seconds: 5), () async {
              final success = await reconnect();
              if (success ?? false) {
                setState(() {
                  webSocketService =
                      WebSocketProvider.of(context)?.webSocketService;
                });
              } else {
                setState(() {
                  messages = [];
                });
              }
            });
            if (messages.isEmpty) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.pink));
            }
          }
          if (snapshot.hasData) {
            final data = jsonDecode(snapshot.data);
            _processMessages(data);
          }
          return GroupedListView<MessagesModel, DateTime>(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            reverse: true,
            order: GroupedListOrder.DESC,
            elements: messages,
            groupBy: (message) => _groupItems(message),
            groupHeaderBuilder: (message) => GroupHeader(message: message),
            itemBuilder: (context, MessagesModel message) => MessageBubble(
                key: ValueKey(message.messageID), message: message),
            groupSeparatorBuilder: (date) => DateSeperator(date: date),
          );
        });
  }

  DateTime _groupItems(MessagesModel message) {
    return DateTime.now().difference(message.timestamp) < Duration(days: 1)
        ? DateTime(
            message.timestamp.year,
            message.timestamp.month,
            message.timestamp.day,
            message.timestamp.hour,
            message.timestamp.minute,
          )
        : isWithinLastWeek(message.timestamp)
            ? DateTime(
                message.timestamp.year,
                message.timestamp.month,
                message.timestamp.day,
                message.timestamp.hour,
              )
            : DateTime(
                message.timestamp.year,
                message.timestamp.month,
                message.timestamp.day,
              );
  }

  void _processMessages(dynamic data) {
    print(data);
    switch (data["type"]) {
      case 'initial_data' || 'older_messages':
        final newMessages = (data['messages'] as List)
            .map((m) => MessagesModel.fromMap(m))
            .toList();

        List<int> ids = [];
        _setOnlineStatus(data);
        for (var message in newMessages) {
          if (!messages.any((existingMessage) =>
              existingMessage.messageID == message.messageID)) {
            messages.add(message);
            if (!message.isRead && !message.mine) {
              ids.add(message.messageID);
            }
          }
        }
        webSocketService?.markMessageAsRead(ids);
        isFetching = false;
        break;

      case 'chat_message':
        if (!messages.any((existingMessage) =>
            existingMessage.messageID == data['message']['messageID'])) {
          final MessagesModel message = MessagesModel.fromMap(data['message']);
          messages.add(message);
          if (!message.mine && !message.isRead) {
            webSocketService?.markMessageAsRead([data['message']['messageID']]);
          }
        }
        break;

      case 'update_status':
        for (var message in data['messages'] as List<dynamic>) {
          int index =
              messages.indexWhere((m) => m.messageID == message['messageID']);
          if (index != -1) {
            messages[index].isRead = message['isRead'] == 1 ? true : false;
          }
        }
        break;

      case 'delete_message':
        int index =
            messages.indexWhere((m) => m.messageID == data['messageID']);
        if (index != -1) {
          messages[index].deleted = true;
          messages[index].content = "";
          messages[index].location = null;
          messages[index].attachmentUrl = null;
          messages[index].attachmentType = AttachmentType.none;
        }

      case 'update_message':
        final information = data['message'];
        int index =
            messages.indexWhere((m) => m.messageID == information['messageID']);
        if (index != -1) {
          switch (information["type"]) {
            case "update_reaction":
              messages[index].reaction = information['reaction'];
              break;

            case "update_content":
              messages[index].content = information['content'];
              break;

            default:
              break;
          }
        }
        break;

      case 'update_online_status':
        _setOnlineStatus(data);

      default:
        break;
    }

    messages = messages.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _setOnlineStatus(dynamic data) {
    final chatAppBarKey = Get.find<AppController>().chatAppBarKey!;
    Future.delayed(Duration(seconds: 1), () {
      chatAppBarKey.currentState?.setState(() {
        chatAppBarKey.currentState!.online = data["online"] == 1;
        if(data["last_online"] != null){
          chatAppBarKey.currentState!.lastOnline = data["last_online"];
        }
      });
    });
  }
}
