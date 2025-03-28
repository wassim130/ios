import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models/conversations.dart';

import '../../../../services/constants.dart';
import 'card_title.dart';
import 'card_subtitle.dart';

class CustomCard extends StatefulWidget {
  final ConversationModel conversation;
  const CustomCard({super.key, required this.conversation});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    final conversationID = widget.conversation.id;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/messages/conversation'.tr,
              arguments: {
                'conversationID': widget.conversation.id,
                'otherUsername': widget.conversation.username,
                "imageURL": widget.conversation.imageURL,
              },
            );
          },
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: GestureDetector(
              onTap: _handleTap,
              child: _buildLeading(conversationID),
            ),
            title: CustomCardTitle(
              conversationID: conversationID,
              username: widget.conversation.username,
            ),
            subtitle: CustomCardSubtitle(conversation: widget.conversation),
            trailing: _buildTrailing(),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(int conversationID) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Hero(
        tag: 'hero1 $conversationID'.tr,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: secondaryColor,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ClipOval(
              child: Image.network(
                "$httpURL/$userAPI${widget.conversation.imageURL}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Material(
                  type: MaterialType.transparency,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Color.fromARGB(255, 59, 59, 59),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (widget.conversation.lastMessage == null) {
      return Text(
        "New contact",
        style: TextStyle(
            color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      );
    }
    if (widget.conversation.lastMessage!.isRead ||
        widget.conversation.lastMessage!.mine) {
      return Text(
        DateFormat.Hm().format(widget.conversation.lastMessage!.timestamp),
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 12,
        ),
      );
    } else {
      return Text(
        "New",
        style: TextStyle(
            color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      );
    }
  }

  void _handleTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            title: Hero(
              tag: 'hero 2 ${widget.conversation.id}'.tr,
              child: Text(
                widget.conversation.username,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Hero(
                tag: 'hero1 ${widget.conversation.id}'.tr,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    "$httpURL/$userAPI${widget.conversation.imageURL}",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
