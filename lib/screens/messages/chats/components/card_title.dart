import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCardTitle extends StatelessWidget {
  const CustomCardTitle({
    super.key,
    required this.conversationID,
    required this.username,
  });

  final int conversationID;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Hero(
            tag: 'hero 2 $conversationID'.tr,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily:'Poppins'.tr,
              ),
              child: Text(
                username,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
