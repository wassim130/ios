import 'package:ahmini/models/message.dart';
import 'package:flutter/material.dart';

class FileAttachment extends StatelessWidget {
  final MessagesModel message;
  const FileAttachment({super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text("Document"),
        ],
      ),
    );
  }
}