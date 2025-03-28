import 'dart:convert';

import 'package:ahmini/services/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../services/auth.dart';

class NotificationModel {
  final int id;
  final String title, content, type;
  final DateTime createdAt;

  NotificationModel(
      {required this.id,
      required this.title,
      required this.content,
      required this.type,
      required this.createdAt});

  static Future<List<NotificationModel>> fetchAll() async {
    late final List<NotificationModel> notifications;
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie'.tr);
    // if (sessionCookie == null) {
    //   return null;
    // }
    final response = await http.get(
      Uri.parse('$httpURL/$notificationAPI/notifications/'.tr),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
    ).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<NotificationModel> temp = [];
      for (var e in data['content']) {
        temp.add(NotificationModel.fromMap(e));
      }
      return temp;
    }
    return [
      NotificationModel(
        id: 1,
        title: 'Sample '.tr,
        content: 'nothing'.tr,
        type: "alert",
        createdAt: DateTime.now().add(Duration(minutes: 5)),
      ),
    ];
  }

  static Future<NotificationModel> fetchById(int id) async {
    final List<NotificationModel> notifications =
        await NotificationModel.fetchAll();

    return notifications.firstWhere((n) => n.id == id,
        orElse: () => NotificationModel(
            id: 1,
            title: '1'.tr,
            content: '1'.tr,
            type: '1'.tr,
            createdAt: DateTime.now()));
  }

  static Future<bool> delete(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie'.tr);
    if (sessionCookie == null) {
      return false;
    }
    String? csrfToken = prefs.getString('csrf_token'.tr)!;
    String? csrfCookie = prefs.getString('csrf_cookie'.tr);

    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    final response = await http
        .delete(
          Uri.parse('$httpURL/$notificationAPI/notifications/'.tr),
          headers: {
            'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
            'X-CSRFToken': csrfToken!,
          },
          body: json.encode({
            'ids': ids.toList(),
          }),
        )
        .timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  String toString() =>
      'Notification{id: $id, title: $title, content: $content, type: $type}';

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as int,
        title: map['title'] as String,
        content: map['content'] as String,
        type: map['type'] as String,
        createdAt: DateTime.parse(map['createdAt']),
      );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'createdAt': createdAt,
    };
  }
}
