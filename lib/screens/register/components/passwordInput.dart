import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueNotifier<String?>? errorNotifier;
  final Function(String)? onChanged;

  const InputField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType,
    this.errorNotifier,
    this.onChanged,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool obscureText = false;

  @override
  void initState() {
    obscureText = widget.obscureText;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.errorNotifier ?? ValueNotifier(null),
      builder: (context, hasError, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? obscureText : false,
            keyboardType: widget.keyboardType,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: hasError != null
                  ? widget.errorNotifier!.value
                  : null, // Show custom error if needed
              prefixIcon:
                  Icon(widget.icon, color: primaryColor),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed: !widget.isPassword
                          ? null
                          : () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            onChanged: (text) {
              if (hasError != null) {
                widget.errorNotifier?.value = null;
              }
              if (widget.onChanged != null) {
                widget.onChanged!(text);
              }
            },
          ),
        );
      },
    );
  }
}
