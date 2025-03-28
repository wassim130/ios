import 'package:ahmini/services/constants.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';

class Product {
  int id;
  String title;
  String description;
  String image;
  List<String> technologies;
  String link;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.technologies,
    required this.link,
  });

  static Future<List<Map<String, dynamic>>?> fetchAll({pagination}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final response = await http.get(
      Uri.parse('$httpURL/api/entreprise/job/${pagination ?? ""}'),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['jobs'] is List) {
        return (data['jobs'] as List)
            .map((job) => job as Map<String, dynamic>)
            .toList();
      }
    }
    return null;
  }

  static Future<bool?> updateStatus(jobRequestID, status) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    String? csrfToken = prefs.getString('csrf_token');
    String? csrfCookie = prefs.getString('csrf_cookie');
    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    try{

    final response = await http.put(
      Uri.parse('$httpURL/api/entreprise/job/'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
        'X-CSRFToken': csrfToken!,
      },
      body: json.encode({
        "status": status,
        "job_id": jobRequestID,
      }),
    ).timeout(Duration(seconds: 15));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
    }catch(e){
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'technologies': technologies,
      'link': link,
    };
  }

  factory Product.fromMap(map) {
    return Product(
      id: map['id'] as int,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      technologies: (map['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      link: map['link'] ?? '',
    );
  }

  static List<Product> fromList(List<dynamic> list) {
    return list
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
