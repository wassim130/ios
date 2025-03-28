import 'package:ahmini/helper/notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahmini/theme.dart';
import '../../controllers/theme_controller.dart';

class NotificationSettingsPage extends StatefulWidget {
  static const String routeName = '/notifications/settings';

  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final textColor = isDark ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          title: Text('Notifications'.tr,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.help_outline_sharp,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Notifications Settings'.tr,
                      ),
                      content: Text(
                          'Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0542794170'.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Fermer'.tr),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Geréz les notifications",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choisissez quelles notifications vous souhaitez recevoir..",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: settingsSection(isDark, primaryColorTheme, textColor),
              ),
            ),
          ],
        ),
      );
    });
  }

  SingleChildScrollView settingsSection(bool isDark, Color primaryColorTheme, Color textColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Messages", isDark),
          MyListTile(
            text: "Toute les message ",
            children: [
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "call",
                notificationSettingsKey: NotificationSetting.call,
                onTap: (value) {},
              ),
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "mentions",
                notificationSettingsKey: NotificationSetting.mentions,
                onTap: (value) {},
              ),
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "reactions",
                notificationSettingsKey: NotificationSetting.reactions,
                onTap: (value) {},
              ),
            ],
          ),
          _buildSectionHeader("Category", isDark),
          MyListTile(
            text: "Contract",
            children: [
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "Réservations",
                notificationSettingsKey: 'key'.tr,
                onTap: (value) {},
              ),
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "Commandes",
                notificationSettingsKey: 'key2'.tr,
                onTap: (value) {},
              ),
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "Livraisons",
                notificationSettingsKey: 'key3'.tr,
                onTap: (value) {},
              ),
              TileChild(
                key: GlobalKey<_TileChild>(),
                text: "Retours",
                notificationSettingsKey: 'key4'.tr,
                onTap: (value) {},
              ),
            ],
          ),
          MyListTile(
            text: "something idk",
            notificationSettingsKey: 'test'.tr,
          ),
          MyListTile(
            text: "something idk",
            notificationSettingsKey: 'test2'.tr,
          ),
          MyListTile(
            text: "something idk",
            notificationSettingsKey: 'test3'.tr,
          ),
          MyListTile(
            text: "something idk",
            notificationSettingsKey: 'test4'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MyListTile extends StatefulWidget {
  final String text;
  final List<TileChild> children;
  final GestureTapCallback? onTap;
  final String? notificationSettingsKey;

  const MyListTile({
    Key? key,
    required this.text,
    this.children = const [],
    this.onTap,
    this.notificationSettingsKey,
  }) : super(key: key);

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  late bool _isSwitched, _isExpanded;
  late String text;
  late List<TileChild> children;
  late String? notificationSettingsKey;

  @override
  void initState() {
    _isSwitched = false;
    text = widget.text;
    children = widget.children;
    _isExpanded = false;
    notificationSettingsKey = widget.notificationSettingsKey;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSwitchState();
    });
  }

  Future<void> _updateSwitchState() async {
    bool allChecked = true;
    for (var child in children) {
      if (!await child.getState()) {
        allChecked = false;
        break;
      }
    }
    if (_isSwitched != allChecked) {
      _isSwitched = allChecked;
    }
    if (children.isEmpty && notificationSettingsKey != null) {
      SharedPreferences perfs = await SharedPreferences.getInstance();
      _isSwitched = perfs.getBool(notificationSettingsKey!) ?? false;
    }
    setState(() {});
  }

  Future<void> _saveSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(notificationSettingsKey!, _isSwitched);
  }

  void _updateChildren(bool newValue) {
    _isSwitched = newValue;
    for (var child in children) {
      child.saveSetting(newValue);
      child.key.currentState?.setState(() {
        if (child.key.currentState!.localSwitchValue != newValue) {
          child.key.currentState!.localSwitchValue = newValue;
          child.onTap(newValue);
        }
      });
    }

    if (children.isEmpty && notificationSettingsKey != null) {
      _saveSetting();
    }

    setState(() {});

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSwitched ? '$text ON' : '$text OFF'.tr),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                width: 1, color: const Color.fromARGB(134, 0, 0, 0))),
      ),
      child: children.isEmpty
          ? ListTile(
        title: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.9,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 70,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: _isSwitched
                  ? primaryColor
                  : Colors.grey.withOpacity(0.4),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: Duration(milliseconds: 150),
                  left: _isSwitched ? 42 : 0,
                  top: 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isSwitched ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
          _updateChildren(!_isSwitched);
        },
      )
          : ExpansionTile(
        leading: AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0.0, // 0.5 means 180 degrees
          duration: Duration(milliseconds: 200),
          child: Icon(Icons.expand_more,
              color: _isExpanded ? primaryColor : Colors.black),
        ),
        title: Text(
          text,
          style: TextStyle(
              fontSize: 18,
              color: _isExpanded ? backgroundColor : Colors.black),
        ),
        trailing: Transform.scale(
          scale: 0.9,
          child: GestureDetector(
            onTap: () {
              _updateChildren(!_isSwitched);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 70,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: _isSwitched
                    ? primaryColor
                    : Colors.grey.withOpacity(0.4),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 150),
                    left: _isSwitched ? 42 : 0,
                    top: 2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSwitched ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        shape: Border(),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: children,
      ),
    );
  }
}

class TileChild extends StatefulWidget {
  final String text;
  final String notificationSettingsKey;
  final void Function(bool) onTap;
  final GlobalKey<_TileChild> key;

  const TileChild({
    required this.key,
    required this.text,
    required this.notificationSettingsKey,
    required this.onTap,
  });

  Future<bool> getState() async {
    SharedPreferences perfs = await SharedPreferences.getInstance();
    final bool? temp = perfs.getBool(notificationSettingsKey);
    return temp ?? false;
  }

  Future<void> saveSetting(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(notificationSettingsKey, newValue);
  }

  @override
  State<TileChild> createState() => _TileChild();
}

class _TileChild extends State<TileChild> {
  late bool localSwitchValue;

  @override
  void initState() {
    localSwitchValue = false;
    _loadSetting();
    super.initState();
  }

  void _checkChildrenState() {
    final parentState = context.findAncestorStateOfType<_MyListTileState>();
    bool allChecked = true;
    if (parentState != null) {
      for (var child in parentState.children) {
        if (!child.key.currentState!.localSwitchValue) allChecked = false;
      }
      if (parentState._isSwitched != allChecked) {
        parentState.setState(() {
          parentState._isSwitched = allChecked;
        });
      }
    }
  }

  Future<void> _saveSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.notificationSettingsKey, localSwitchValue);
  }

  Future<void> _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? temp = prefs.getBool(widget.notificationSettingsKey);
    localSwitchValue = temp ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom:
            BorderSide(width: 2, color: const Color.fromARGB(41, 0, 0, 0))),
      ),
      child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: RotatedBox(
            quarterTurns: 90,
            child: Icon(
              Icons.linear_scale_rounded,
              color: localSwitchValue
                  ? Colors.green
                  : Colors.black.withOpacity(0.3),
            ),
          ),
          title: Text(
            widget.text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(
                localSwitchValue ? 'ON' : 'OFF'.tr,
                style: TextStyle(
                  color: localSwitchValue
                      ? Colors.green
                      : Colors.grey.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          onTap: () {
            setState(() {
              localSwitchValue = !localSwitchValue;
            });
            //save locally
            _saveSetting();
            widget.onTap(localSwitchValue);
            _checkChildrenState();
          }),
    );
  }
}