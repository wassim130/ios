import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';
import '../services/constants.dart';
import '../dictionary/entreprise_icons.dart';

class TechnologyModel {
  final int id;
  final String name;

  const TechnologyModel({required this.id, required this.name});

  static Future<List<TechnologyModel>> fetchAll(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final response = await http.get(
      Uri.parse("$httpURL/api/technologies/?pagination=$id"),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
      
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<TechnologyModel> list = [];
      for (var item in data['technologies']) {
        list.add(TechnologyModel.fromMap(item));
      }
      return list;
    }
    return [];
  }

  factory TechnologyModel.fromMap(map) {
    return TechnologyModel(id: map['id'], name: map['name']);
  }
  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
