import 'package:ahmini/theme.dart';
import 'package:get/get.dart';

import '../../../helper/CustomDialog/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/connected_device.dart';
import '../../../services/auth.dart';
import '../../../controllers/theme_controller.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  List<ConnectedDeviceModel>? connectedDevices;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final textColor = isDark ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: backgroundColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: Text(
            'Connected devices'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder(
            future: AuthService.getConnetedDevices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(
                  color: primaryColorTheme,
                ));
              }
              if (snapshot.hasData) {
                connectedDevices = snapshot.data;
              }
              if (connectedDevices == null) {
                return Center(
                    child: Text(
                      "Connection error. please try again later",
                      style: TextStyle(color: textColor),
                    ));
              }
              if (connectedDevices == []) {
                return Center(
                    child: Text(
                      'Aucun appareil connecté'.tr,
                      style: TextStyle(color: textColor),
                    )
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              children: [
                                TextSpan(
                                    text: connectedDevices!.length.toString(),
                                    style: TextStyle(color: Colors.green)),
                                TextSpan(text: ' appareils actifs'.tr)
                              ])),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                        child: ListView.builder(
                          itemCount: connectedDevices!.length,
                          itemBuilder: (context, index) {
                            return ConnectedDevice(
                              connectedDevice: connectedDevices![index],
                              callBack: () async {
                                final bool s = await AuthService.disconnectDevice(
                                    connectedDevices![index].id);
                                if (s) {
                                  connectedDevices!.removeAt(index);
                                  setState(() {});
                                }
                              },
                              isDark: isDark,
                              primaryColorTheme: primaryColorTheme,
                            );
                          },
                        )),
                  ],
                ),
              );
            }),
      );
    });
  }
}

class ConnectedDevice extends StatefulWidget {
  final ConnectedDeviceModel connectedDevice;
  final Function callBack;
  final bool isDark;
  final Color primaryColorTheme;

  const ConnectedDevice({
    super.key,
    required this.connectedDevice,
    required this.callBack,
    required this.isDark,
    required this.primaryColorTheme,
  });

  @override
  State<ConnectedDevice> createState() => _ConnectedDeviceState();
}

class _ConnectedDeviceState extends State<ConnectedDevice> {
  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? Colors.grey[800] : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final textColorSecondary = widget.isDark ? Colors.white70 : Colors.black54;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      color: cardColor,
      child: ExpansionTile(
          leading: Icon(
            widget.connectedDevice.os == "android"
                ? Icons.phone_android
                : widget.connectedDevice.os == "ios"
                ? Icons.phone_iphone_sharp
                : Icons.device_unknown,
            size: 32,
            color: textColor,
          ),
          title: RichText(
            text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                children: [
                  TextSpan(text: widget.connectedDevice.name),
                  if (widget.connectedDevice.mine)
                    TextSpan(
                      text: " (this device)",
                      style: TextStyle(
                          fontSize: 12,
                          color: const Color.fromARGB(255, 255, 16, 16)),
                    ),
                ]),
          ),
          subtitle: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: textColorSecondary,
                  ),
                  children: [
                    TextSpan(text: "Last active", style: TextStyle(fontSize: 16)),
                    TextSpan(
                        text:
                        '(${DateFormat.yMMMMEEEEd().format(DateTime.parse(widget.connectedDevice.lastActive))})'.tr),
                  ])),
          trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: textColor),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    showAllDeviceInformation(context);
                  },
                  child: Text("show information"),
                ),
                PopupMenuItem(
                  onTap: () {
                    widget.callBack();
                  },
                  child: Text("Disconnect"),
                ),
              ]),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        widget.connectedDevice.trusted
                            ? Icon(Icons.verified_user, color: Colors.green)
                            : Icon(Icons.warning, color: Colors.red, size: 24),
                        Text(
                          widget.connectedDevice.trusted
                              ? "Trusted device"
                              : "Untrusted device",
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              widget.callBack();
                            },
                            child: Text("Disconnect",
                                style: TextStyle(fontSize: 12))),
                        TextButton(
                          onPressed: () {
                            _showTrustDeviceAlert(
                                widget.connectedDevice.trusted);
                          },
                          child: !widget.connectedDevice.trusted
                              ? Text("Trust this device",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ))
                              : Text(
                            "Untrust this device",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ]),
    );
  }

  Future<dynamic> showAllDeviceInformation(BuildContext context) {
    final dialogBackgroundColor = widget.isDark ? Colors.grey[800] : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            widget.connectedDevice.name,
            style: TextStyle(color: textColor),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              Text(
                "-Connected at: ${DateFormat().format(DateTime.parse(widget.connectedDevice.connectedAt))}",
                style: TextStyle(color: textColor),
              ),
              Text(
                "-Last active : ${DateFormat().format(DateTime.parse(widget.connectedDevice.lastActive))}",
                style: TextStyle(color: textColor),
              ),
              Text("-IP : ${widget.connectedDevice.ip}", style: TextStyle(color: textColor)),
              Text("-last action : ${widget.connectedDevice.lastAction}", style: TextStyle(color: textColor)),
              Text(
                "-Connection Type : ${widget.connectedDevice.connectionType}",
                style: TextStyle(color: textColor),
              ),
              Text("-Device language : ${widget.connectedDevice.language}", style: TextStyle(color: textColor)),
              Text("-Device operating system : ${widget.connectedDevice.os}", style: TextStyle(color: textColor)),
              Text("-Device version : ${widget.connectedDevice.version}", style: TextStyle(color: textColor)),
              Row(
                children: [
                  Icon(
                      widget.connectedDevice.trusted
                          ? Icons.verified_user
                          : Icons.warning,
                      color: widget.connectedDevice.trusted
                          ? Colors.green
                          : Colors.red),
                  SizedBox(width: 8),
                  Text(
                    widget.connectedDevice.trusted
                        ? "Trusted"
                        : "NOT TRUSTED",
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.callBack();
              },
              child: Text('disconnect device'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showTrustDeviceAlert(bool trust) {
    final dialogBackgroundColor = widget.isDark ? Colors.grey[800] : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        final String s = !trust ? "Trust" : "Untrust";
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            "$s this device",
            style: TextStyle(color: textColor),
          ),
          content: Text(
            "Are you sure you want to $s this device?",
            style: TextStyle(color: textColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _handleTrustDevice(trust);
              },
              child: Text(s),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'.tr),
            ),
          ],
        );
      },
    );
  }

  void _handleTrustDevice(bool trust) async {
    Navigator.pop(context);
    myCustomLoadingIndicator(context);
    final success =
    await AuthService.trustDevice(widget.connectedDevice.id, !trust);
    if (mounted) {
      Navigator.pop(context);
      if (success == true) {
        widget.connectedDevice.trusted = !trust;
        setState(() {});
      } else if (success == false) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: widget.isDark ? Colors.grey[800] : Colors.white,
              title: Text(
                "Error",
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              ),
              content: Text(
                "An error occurred while trying to trust this device.",
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'.tr),
                ),
              ],
            );
          },
        );
        return;
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: widget.isDark ? Colors.grey[800] : Colors.white,
              title: Text(
                "Error",
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              ),
              content: Text(
                "An error occurred while trying to connect to the server.",
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'.tr),
                ),
              ],
            );
          },
        );
        return;
      }
    }
  }
}
