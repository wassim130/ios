import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../helper/CustomDialog/loading_indicator.dart';
import '../../../models/connected_device.dart';
import '../../../services/auth.dart';

class LoginHistoryPage extends StatefulWidget {
  const LoginHistoryPage({super.key});

  @override
  State<LoginHistoryPage> createState() => _LoginHistoryPageState();
}

class _LoginHistoryPageState extends State<LoginHistoryPage> {
  List<ConnectedDeviceModel>? connectedDevices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title:  Text(
          'Login History'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
          future: AuthService.getConnetedDevices(onlyActive: false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              connectedDevices = snapshot.data;
            }
            if (connectedDevices == null) {
              return Center(
                  child: Text("Connection error. please try again later"));
            }
            if (connectedDevices == []) {
              return Center(child: Text('Aucun appareil connecté'.tr));
            }
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemCount: connectedDevices!.length,
                itemBuilder: (context, index) {
                  return ConnectedDevice(
                      connectedDevice: connectedDevices![index]);
                },
              ),
            );
          }),
    );
  }
}

class ConnectedDevice extends StatefulWidget {
  final ConnectedDeviceModel connectedDevice;

  const ConnectedDevice({
    super.key,
    required this.connectedDevice,
  });

  @override
  State<ConnectedDevice> createState() => _ConnectedDeviceState();
}

class _ConnectedDeviceState extends State<ConnectedDevice> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          widget.connectedDevice.os == "android"
              ? Icons.phone_android
              : widget.connectedDevice.os == "ios"
                  ? Icons.phone_iphone_sharp
                  : Icons.device_unknown,
          size: 32,
        ),
        title: Row(
          children: [
            widget.connectedDevice.trusted
                ? Icon(Icons.verified_user, color: Colors.green)
                : Icon(Icons.warning, color: Colors.red, size: 24),
            RichText(
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
          ],
        ),
        subtitle: RichText(
                text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                    TextSpan(
                        text: "Logged in at : ", style: TextStyle(fontSize: 16)),
                    TextSpan(
                        text:
                            '(${DateFormat("yMMMMEEEEd").format(DateTime.parse(widget.connectedDevice.connectedAt))} At ${DateFormat("HH:MM").format(DateTime.parse(widget.connectedDevice.connectedAt))})'.tr),
                  ])),
        trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      showAllDeviceInformation(context);
                    },
                    child: Text("show information"),
                  ),
                ]),
      ),
    );
  }

  Future<dynamic> showAllDeviceInformation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.connectedDevice.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              Text(
                  "-Connected at: ${DateFormat().format(DateTime.parse(widget.connectedDevice.connectedAt))}"),
              Text(
                  "-Last active : ${DateFormat().format(DateTime.parse(widget.connectedDevice.lastActive))}"),
              Text("-IP : ${widget.connectedDevice.ip}"),
              Text("-last action : ${widget.connectedDevice.lastAction}"),
              Text(
                  "-Connection Type : ${widget.connectedDevice.connectionType}"),
              Text("-Device language : ${widget.connectedDevice.language}"),
              Text("-Device operating system : ${widget.connectedDevice.os}"),
              Text("-Device version : ${widget.connectedDevice.version}"),
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
                  Text(widget.connectedDevice.trusted
                      ? "Trusted"
                      : "NOT TRUSTED"),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
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
  }


}
