import 'package:flutter/material.dart';
import 'package:get/get.dart';

void myCustomDialog(BuildContext context, Map<String, dynamic> map) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(map['type'] ?? "unknown"),
        content: Text(map['message'] ?? "unknown"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Fermer'.tr),
          ),
        ],
      );
    },
  );
}

