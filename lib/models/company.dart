import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';
import '../services/constants.dart';
import '../dictionary/entreprise_icons.dart';
import 'job.dart';

// Modèle pour les témoignages clients
class Testimonial {
  final String name;
  final String company;
  final String comment;
  final String image;
  final double rating;

  Testimonial({
    required this.name,
    required this.company,
    required this.comment,
    required this.image,
    required this.rating,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'comment': comment,
      'image': image,
      'rating': rating,
    };
  }

  Testimonial copy() {
    return Testimonial(
      name: name,
      company: company,
      comment: comment,
      image: image,
      rating: rating,
    );
  }
}

class InnovationsModel {
  int id;
  String title, description;
  IconData icon;
  InnovationsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory InnovationsModel.fromMap(map) {
    return InnovationsModel(
      id: map['id'],
      title: map['title'] as String,
      description: map['description'] as String,
      icon: icons[map['icon']] as IconData,
    );
  }
  static List<InnovationsModel> fromList(List<dynamic> list) {
    return list
        .map((item) => InnovationsModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> fromList2(List<dynamic> list) {
    return list
        .map((item) => InnovationsModel.toMap(
            InnovationsModel.fromMap(item as Map<String, dynamic>)))
        .toList();
  }

  static Map<String, dynamic> toMap(InnovationsModel inovation) {
    return {
      'id': inovation.id,
      'title': inovation.title,
      'description': inovation.description,
      'icon':
          icons.entries.firstWhere((icon) => icon.value == inovation.icon).key,
    };
  }

  InnovationsModel copy() {
    return InnovationsModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
    );
  }
}

class CompanyModel {
  int id;
  String companyName;
  String tagline;
  String logoPath;
  String companyEmail;
  String companyPhone;
  String companyAddress;
  String companyWebsite;
  String companyLinkedIn;
  String aboutCompany;
  String companyMission;
  List<Product> productsList;
  List<Testimonial> testimonialsList;
  List<InnovationsModel> innovationAreas;
  String solutionsCount;
  String clientsCount;
  String satisfactionRate;
  bool mine;

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.tagline,
    required this.logoPath,
    required this.companyEmail,
    required this.companyPhone,
    required this.companyAddress,
    required this.companyWebsite,
    required this.companyLinkedIn,
    required this.aboutCompany,
    required this.companyMission,
    required this.productsList,
    required this.testimonialsList,
    required this.innovationAreas,
    this.solutionsCount = "3",
    this.clientsCount = "120",
    this.satisfactionRate = "4.9",
    this.mine = false,
  });

  static Future<CompanyModel?> fetch(id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final response = await http.get(
      Uri.parse("$httpURL/api/entreprise/?id=$id"),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CompanyModel.fromMap(data['entreprise'][0]);
    }
    return null;
  }

  static Future<List<CompanyModel>?> fetchAll(
      {id, filter, pagination, search}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final response = await http.get(
      Uri.parse("$httpURL/api/entreprise/").replace(queryParameters: {
        if (id != null) "id": id.toString(),
        if (filter != null) "filter": filter.toString(),
        if (pagination != null) "pagination": pagination.toString(),
        if (search != null) "search": search.toString(),
      }),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
    );
    if (response.statusCode == 200) {
      // print(response.body);
      final data = json.decode(response.body);
      List<CompanyModel> list = [];
      for (var item in data['entreprise']) {
        list.add(CompanyModel.fromMap(item));
      }
      return list;
    }
    return null;
  }

  static Future<dynamic> update(
    CompanyModel company,
    List<int> removedJobs,
    List<int> removedInnovations,
    Uint8List? imageBytes,
    String? imageName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    String? csrfToken = prefs.getString('csrf_token');
    String? csrfCookie = prefs.getString('csrf_cookie');
    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    try {
      final response = await http.put(
        Uri.parse("$httpURL/api/entreprise/"),
        headers: {
          'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
          'X-CSRFToken': csrfToken!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "removed_jobs": removedJobs,
          "removed_innovations": removedInnovations,
          if (imageBytes != null && imageName != null) "image": base64Encode(imageBytes),
          if (imageBytes != null && imageName != null) "image_name": imageName,
          "entreprise": {...company.toMap()},
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {
        "type": "Connection error",
        "message": "Connection Error. Please try again later."
      };
    }
  }

  static Future<dynamic> sendJobRequest(int jobID) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    String? csrfToken = prefs.getString('csrf_token');
    String? csrfCookie = prefs.getString('csrf_cookie');
    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    try {
      final response = await http.post(
        Uri.parse("$httpURL/api/entreprise/job/"),
        headers: {
          'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
          'X-CSRFToken': csrfToken!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'job_id': jobID,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {
        "type": "Connection error",
        "content": "Connection error. Please check your internet connection"
      };
    }
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] ?? 0,
      companyName: map['name'] ?? '',
      aboutCompany: map['description'] ?? '',
      companyAddress: map['address'] ?? '',
      companyPhone: map['phone'] ?? '',
      companyEmail: map['email'] ?? '',
      companyWebsite: map['website'] ?? '',
      companyLinkedIn: map['linkedin'] ?? '',
      companyMission: map['mission'] ?? '',
      logoPath: map['logo'] ?? '',
      tagline: map['tagline'] ?? "",
      mine: map['mine'] ?? false,

      // Ensure jobs is a list before mapping
      productsList: map['jobs'] is List ? Product.fromList(map['jobs']) : [],

      // Ensure reviews is a list and map each item to a Testimonial object
      testimonialsList: map['reviews'] is List
          ? (map['reviews'] as List)
              .map((item) => Testimonial(
                    name: item['name'] ?? '',
                    company: item['company'] ?? '',
                    comment: item['comment'] ?? '',
                    image: item['image'] ?? '',
                    rating: (item['rating'] ?? 0).toDouble(),
                  ))
              .toList()
          : [],

      // Ensure innovationAreas is a list before assigning
      innovationAreas: map['innovation_areas'] is List
          ? InnovationsModel.fromList(map['innovation_areas'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': companyName,
      'description': aboutCompany,
      'address': companyAddress,
      'phone': companyPhone,
      'email': companyEmail,
      'website': companyWebsite,
      'linkedin': companyLinkedIn,
      'mission': companyMission,
      'logo': logoPath,
      'tagline': tagline,
      'mine': mine,
      'jobs': productsList.map((product) => product.toMap()).toList(),
      'reviews':
          testimonialsList.map((testimonial) => testimonial.toMap()).toList(),
      'innovation_areas': innovationAreas
          .map((innovation) => InnovationsModel.toMap(innovation))
          .toList(),
      'solutions_count': solutionsCount,
      'clients_count': clientsCount,
      'satisfaction_rate': satisfactionRate,
    };
  }

  CompanyModel copy() {
    return CompanyModel(
      id: id,
      companyName: companyName,
      tagline: tagline,
      logoPath: logoPath,
      companyEmail: companyEmail,
      companyPhone: companyPhone,
      companyAddress: companyAddress,
      companyWebsite: companyWebsite,
      companyLinkedIn: companyLinkedIn,
      aboutCompany: aboutCompany,
      companyMission: companyMission,
      productsList: productsList.map((item) => item.copy()).toList(),
      testimonialsList: testimonialsList.map((item) => item.copy()).toList(),
      innovationAreas: innovationAreas.map((item) => item.copy()).toList(),
      solutionsCount: solutionsCount,
      clientsCount: clientsCount,
      satisfactionRate: satisfactionRate,
      mine: mine,
    );
  }
}
