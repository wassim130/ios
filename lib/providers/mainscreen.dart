import 'package:flutter/material.dart';

import '../models/user.dart';

class MainScreenProvider extends InheritedWidget {
  final UserModel? user;

  const MainScreenProvider({
    super.key,
    required this.user,
    required super.child,
  });

  static MainScreenProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainScreenProvider>();
  }

  @override
  bool updateShouldNotify(MainScreenProvider oldWidget) {
    return oldWidget.user!= user;
  }
}