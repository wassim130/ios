import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText, placeholder;
  final IconData icon;
  final bool obscureText;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.icon,
      required this.placeholder,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          obscureText: obscureText,
          controller: controller,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            prefixIcon: Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 45),
            labelText: labelText,
            labelStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }
}
