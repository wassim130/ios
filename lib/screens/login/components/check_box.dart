import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

class MyCheckBox extends StatefulWidget {
  final bool rememberMe;
  final VoidCallback callBack;
  const MyCheckBox({super.key, required this.rememberMe,required this.callBack});

  @override
  State<MyCheckBox> createState() => _MyCheckBoxState();
}

class _MyCheckBoxState extends State<MyCheckBox> {
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _rememberMe = widget.rememberMe;
  }

  @override
  Widget build(BuildContext context) {
    print("Built check box");
    return Checkbox(
      value: _rememberMe,
      onChanged: (value) {
        setState(() {
          _rememberMe = value!;
        });
        widget.callBack();
      },
      activeColor: primaryColor,
    );
  }
}