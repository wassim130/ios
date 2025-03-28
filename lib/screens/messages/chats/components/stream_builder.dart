import 'dart:convert';

import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/conversations.dart';
import '../../../../models/message.dart';

import '../../../../providers/global_websocket.dart';

import '../../../../services/global_websocket.dart';

import 'chat_card.dart';

class MyStreamBuilder extends StatefulWidget {
  final TextEditingController searchController;

  const MyStreamBuilder({
    super.key,
    required this.searchController,
  });

  @override
  State<MyStreamBuilder> createState() => _MyStreamBuilderState();
}

class _MyStreamBuilderState extends State<MyStreamBuilder> {
  List<ConversationModel> conversations = [];
  List<ConversationModel> filteredConversations = [];
  late GlobalWebSocketService webSocketService;

  @override
  void initState() {
    super.initState();
    // Add listener to search controller
    widget.searchController.addListener(_filterConversations);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterConversations);
    super.dispose();
  }

  void _filterConversations() {
    if (mounted) {
      if (widget.searchController.text.isEmpty) {
        setState(() {
          filteredConversations = List.from(conversations);
        });
      } else {
        setState(() {
          filteredConversations = conversations
              .where((conversation) => conversation.username
              .toLowerCase()
              .contains(widget.searchController.text.toLowerCase()))
              .toList();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    webSocketService = GlobalWebSocketProvider.of(context)!.webSocketService;
    // Initialize filtered conversations
    filteredConversations = List.from(conversations);
    super.didChangeDependencies();
  }

  Future<bool?> reconnect() async {
    return await webSocketService.connect();
  }

  Future<void> disconnect() async {
    final provider = GlobalWebSocketProvider.of(context)!.webSocketService;
    provider.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: webSocketService.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              conversations.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Future.delayed(Duration(seconds: 5), () async {
              final success = await reconnect();
              if (success ?? false && mounted) {
                setState(() {
                  webSocketService =
                      GlobalWebSocketProvider.of(context)!.webSocketService;
                });
              }
            });
            if (conversations.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }
          }
          if (snapshot.hasData) {
            final data = jsonDecode(snapshot.data);
            // Process data outside of build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _processConversations(data);
            });
          }
          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              if (mounted) {
                setState(() {
                  conversations = [];
                  filteredConversations = [];
                });
              }
              await disconnect();
              await reconnect();
            },
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 16),
              children: [
                // En-tête des messages récents
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    'Messages Récents'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                filteredConversations.isEmpty && widget.searchController.text.isNotEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Aucune conversation trouvée'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                    : Column(
                  children: filteredConversations.map(
                        (conversation) => CustomCard(conversation: conversation),
                  ).toList(),
                ),
                SizedBox(height: 100),
              ],
            ),
          );
        });
  }

  void _processConversations(dynamic data) {
    if (!mounted) return;

    bool needsUpdate = false;

    switch (data["type"]) {
      case "initial_data":
        final newConversations = (data['content'] as List).map((c) {
          return ConversationModel(
            id: c['room'],
            lastMessage: c['last_message'] != null
                ? MessagesModel.fromMap(c['last_message'])
                : null,
            username: c['username'],
            imageURL: c['imageURL'],
          );
        }).toList();

        // Add only new conversation to the set
        for (var conversation in newConversations) {
          if (!conversations.any(
                  (existingMessage) => existingMessage.id == conversation.id)) {
            conversations.add(conversation);
            needsUpdate = true;
          }
        }
        break;

      case 'chat_message':
        final newMessage = MessagesModel.fromMap(data['message']);
        for (var conversation in conversations) {
          if ('${conversation.id}' == data['message']['room']) {
            conversation.lastMessage = newMessage;
            needsUpdate = true;
            break;
          }
        }
        break;

      case 'update_status':
        final newStatus = data['messages'];
        int index = conversations.indexWhere(
                (e) => e.lastMessage?.messageID == newStatus.last['messageID']);
        if (index != -1) {
          conversations[index].lastMessage!.isRead = true;
          needsUpdate = true;
        }
        break;

      case 'delete_message':
        int index = conversations
            .indexWhere((e) => e.lastMessage?.messageID == data['messageID']);
        if (index != -1) {
          conversations[index].lastMessage?.content = "User unsent a message.";
          needsUpdate = true;
        }
        break;

      case 'update_message':
        final information = data['message'];
        int index = conversations.indexWhere(
                (e) => e.lastMessage?.messageID == information['messageID']);
        if (index != -1) {
          switch (information["type"]) {
            case "update_reaction":
              conversations[index].lastMessage?.content =
              '${information['reaction']} Reacted to your message';
              needsUpdate = true;
              break;

            case "update_content":
              conversations[index].lastMessage?.content =
              information['content'];
              needsUpdate = true;
              break;

            default:
              break;
          }
        }
        break;

      default:
        break;
    }

    if (needsUpdate) {
      conversations = conversations.toList()
        ..sort((a, b) {
          final aTimestamp = a.lastMessage?.timestamp ?? DateTime(0);
          final bTimestamp = b.lastMessage?.timestamp ?? DateTime(0);
          return bTimestamp.compareTo(aTimestamp);
        });

      // Update filtered conversations
      _filterConversations();
    }
  }
}

