import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth.dart';
import 'constants.dart';

class UserService{
  static Future<Map<String, dynamic>> updateProfile(Map<String,dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    String? csrfToken = prefs.getString('csrf_token');
    String? csrfCookie = prefs.getString('csrf_cookie');
    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    final String apiUrl =
        "$httpURL/$userAPI/update_private_mode/"; // Remplacez par l'URL de votre API Django
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
      'X-CSRFToken': csrfToken!,
    };
    try {
      final response = await http
          .put(
            Uri.parse(apiUrl),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(Duration(seconds: 5));
      print(response.body);
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'status': 'connection_error',
        'message': 'Erreur de connection',
      };
    }
  }

}