import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

void myCustomLoadingIndicator(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    },
  );
}