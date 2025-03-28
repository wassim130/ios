import 'package:flutter/material.dart';

import '../../../../models/conversations.dart';
import '../../../../models/message.dart';

class CustomCardSubtitle extends StatelessWidget {
  const CustomCardSubtitle({
    super.key,
    required this.conversation,
  });

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        conversation.lastMessage?.mine ?? false
            ? Icon(
                conversation.lastMessage?.isRead ?? false
                    ? Icons.done_all
                    : Icons.done,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 18,
              )
            : SizedBox(),
        SizedBox(width: 3),
        Expanded(
          child: Row(
            children: [
              conversation.lastMessage != null &&
                      conversation.lastMessage?.attachmentType !=
                          AttachmentType.none
                  ? Row(
                      children: [
                        Icon(
                          conversation.lastMessage?.attachmentType ==
                                  AttachmentType.image
                              ? Icons.image
                              : conversation.lastMessage?.attachmentType ==
                                      AttachmentType.location
                                  ? Icons.location_on
                                  : Icons.place,
                          color: conversation.lastMessage?.mine == true ||
                                  conversation.lastMessage?.mine == true
                              ? const Color.fromARGB(255, 243, 33, 33)
                              : const Color.fromARGB(255, 161, 2, 2),
                          size: 18,
                        ),
                        Text(
                          "${conversation.lastMessage!.mine ? "you" : conversation.lastMessage!.sender} sent an attachement",
                          style: conversation.lastMessage?.isRead == true ||
                                  conversation.lastMessage?.mine == true
                              ? TextStyle(
                                  fontSize: 13,
                                  color: Colors.black45,
                                )
                              : TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                      ],
                    )
                  : Text(
                      conversation.lastMessage?.content ?? "Say Hi !",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: conversation.lastMessage?.isRead == true ||
                              conversation.lastMessage?.mine == true
                          ? TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                            )
                          : TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
