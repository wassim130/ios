import 'dart:io';
import 'dart:ui';

import 'package:ahmini/models/user.dart';
import 'package:ahmini/services/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/connected_device.dart';

String? extractCookie(String setCookieHeader, String cookieName) {
  final cookies = setCookieHeader.split(',');
  print(cookies);
  for (var cookie in cookies) {
    cookie = cookie;

    if (cookie.startsWith('$cookieName=')) {
      final sessionId = cookie.split(';')[0].split('=')[1];
      return sessionId;
    }
  }
  return null;
}

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  }
  return "Unknown Device";
}

Future<String> getConnectionType() async {
  List<ConnectivityResult> results = await Connectivity().checkConnectivity();
  if (results.contains(ConnectivityResult.wifi)) {
    return "Wi-Fi";
  }
  if (results.contains(ConnectivityResult.mobile)) {
    return "Mobile Data";
  }
  if (results.contains(ConnectivityResult.ethernet)) {
    return "Ethernet";
  }
  if (results.isEmpty) {
    return "No Connection";
  }
  return "Unknown";
}

Future<String> getDeviceUniqueID() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }
  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? "unknown";
  }
  return "Unknown Device";
}

class AuthService {
  static Future<void> _saveCredentials(dynamic response, dynamic data,
      {bool saveUser = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final String sessionID =
    extractCookie(response.headers['set-cookie']!, "sessionid")!;
    final String csrfCookie =
    extractCookie(response.headers['set-cookie']!, "csrftoken")!;
    final String csrfToken = data['csrfToken'];
    await prefs.setString('session_cookie', sessionID);
    await prefs.setString('csrf_cookie', csrfCookie);
    await prefs.setString('csrf_token', csrfToken);
    if (saveUser) await prefs.setString('user', jsonEncode(data['user']));
  }

  // Dans la méthode register, assurez-vous que la réponse inclut l'information sur le type d'utilisateur
  static Future<dynamic> register(
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String address,
      String password,
      bool isFreelancer,
      bool useLocation,
      bool useFingerprint,
      String domain,
      ) async {
    try {
      final String deviceName = await getDeviceName();
      final String connectionType = await getConnectionType();
      final response = await http
          .post(
        Uri.parse('$httpURL/$authAPI/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          'address': address,
          'password': password,
          'is_entreprise': !isFreelancer,
          'use_location': useLocation,
          'use_fingerprint': useFingerprint,
          'domain': domain,
          'connection_type': connectionType,
          'device_name': deviceName,
          'device_language':
          PlatformDispatcher.instance.locale.languageCode,
          'device_os': Platform.operatingSystem,
          'device_version': Platform.version,
          'unique_id': await getDeviceUniqueID(),
        }),
      )
          .timeout(Duration(seconds: timeout));
      final dynamic data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _saveCredentials(response, data);
        return {
          'status': 'success',
          'user': UserModel.fromMap(data['user']),
          'isFreelancer': isFreelancer, // Ajout de cette information dans la réponse
        };
      } else {
        return data;
      }
    } catch (e) {
      return {
        'status': 'error',
        'type': 'error',
        'message': 'Connection error',
      };
    }
  }

  static Future<dynamic> login(String email, String password) async {
    try {
      final String deviceName = await getDeviceName();
      final String connectionType = await getConnectionType();
      final response = await http
          .post(Uri.parse('$httpURL/$authAPI/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'connection_type': connectionType,
            'device_name': deviceName,
            'device_language':
            PlatformDispatcher.instance.locale.languageCode,
            'device_os': Platform.operatingSystem,
            'device_version': Platform.version,
            'unique_id': await getDeviceUniqueID(),
          }))
          .timeout(Duration(seconds: timeout));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Vérifier si l'authentification à deux facteurs est requise
        if (data['status'] == 'two_factor_required') {
          return {
            'status': 'two_factor_required',
            'message': data['message'],
            'two_factor_id': data['two_factor_id'],
          };
        }

        // Sinon, connexion normale
        await _saveCredentials(response, data);
        return {
          'status': 'success',
          'user': UserModel.fromMap(data['user']),
        };
      } else {
        return data;
      }
    } catch (e) {
      return {
        'status': 'error',
        'type': 'error',
        'message': 'Connection error',
      };
    }
  }

  static Future<dynamic> verifyTwoFactor(
      String code, String twoFactorId) async {
    try {
      // Afficher le code pour le débogage
      print('Code envoyé: $code');
      print('TwoFactorId envoyé: $twoFactorId');

      final response = await http
          .post(
        Uri.parse('$httpURL/$authAPI/verify-two-factor/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'two_factor_id': twoFactorId,
        }),
      )
          .timeout(Duration(seconds: timeout));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveCredentials(response, data);
        return {
          'status': 'success',
          'user': UserModel.fromMap(data['user']),
        };
      } else {
        return data;
      }
    } catch (e) {
      print('Erreur lors de la vérification du code: $e');
      return {
        'status': 'error',
        'type': 'error',
        'message': 'Connection error',
      };
    }
  }

  static Future<dynamic> toggleTwoFactor(bool enable) async {
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
        Uri.parse('$httpURL/$authAPI/toggle-two-factor/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
          'X-CSRFToken': csrfToken!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'enable': enable,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'type': 'error',
        'message': 'Connection error',
      };
    }
  }

  static Future<dynamic> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');

    if (sessionCookie == null) {
      return {
        'status': 'success',
        'type': 'success',
        'message': 'You are already logged out',
      };
    }
    try {
      final response = await http.get(
        Uri.parse('$httpURL/$authAPI/logout/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      ).timeout(Duration(seconds: timeout));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await prefs.remove('session_cookie');
        await prefs.remove('user');
      }
      return data;
    } catch (e) {
      return {
        'status': 'failed',
        'type': 'error',
        'message':
        'Error while trying to reach the server . Please try again later',
      };
    }
  }

  static Future<bool?> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    if (sessionCookie == null) return false;
    try {
      final response = await http.get(
        Uri.parse('$httpURL/$authAPI/check-session/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      ).timeout(Duration(seconds: timeout));
      print("is Logged in : ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    // if (sessionCookie == null) {
    //   return null;
    // }
    final response = await http.get(
      Uri.parse('$httpURL/$authAPI/user/'),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
    ).timeout(Duration(seconds: timeout));
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromMap(data['content']);
    } else {
      return null;
    }
  }

  static Future<dynamic> getCsrf() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    final response = await http.get(
      Uri.parse('$httpURL/$authAPI/get-csrf-token/'),
      headers: {
        'Cookie': "sessionid=$sessionCookie",
      },
    );
    final csrfToken = jsonDecode(response.body)['csrfToken'];
    final csrfCookie =
    extractCookie(response.headers['set-cookie']!, 'csrftoken');
    return {
      'csrf_token': csrfToken,
      'csrf_cookie': csrfCookie,
    };
  }

  static Future<dynamic> changePassword(Map<String, String> body) async {
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
        Uri.parse('$httpURL/$authAPI/change-password/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
          'X-CSRFToken': csrfToken!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  static Future<List<ConnectedDeviceModel>?> getConnetedDevices(
      {bool onlyActive = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    try {
      final response = await http.get(
        Uri.parse(
            '$httpURL/$authAPI/connected-devices/${!onlyActive ? "?active=false" : ""}'),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      ).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        List<ConnectedDeviceModel> list = [];
        final data = jsonDecode(response.body);
        for (var d in data['devices']) {
          list.add(ConnectedDeviceModel.fromMap(d));
        }
        return list;
      }
      return [];
    } catch (e) {
      return null;
    }
  }

  static Future<bool> disconnectDevice(id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    String? csrfToken = prefs.getString('csrf_token');
    String? csrfCookie = prefs.getString('csrf_cookie');

    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    final response = await http.put(
      Uri.parse('$httpURL/$authAPI/disconnect-device/'),
      headers: {
        'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
        'X-CSRFToken': csrfToken!,
      },
      body: {
        "id": '$id',
      },
    ).timeout(Duration(seconds: timeout));
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool?> trustDevice(id, trust) async {
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
        Uri.parse('$httpURL/$authAPI/trust-device/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
          'X-CSRFToken': csrfToken!,
        },
        body: {
          "id": '$id',
          "trusted": trust.toString(),
        },
      ).timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> confidentialite() async {
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
      final response = await http.get(
        Uri.parse('$httpURL/$authAPI/security-conf/'),
        headers: {
          'Cookie': "sessionid=$sessionCookie;csrftoken=$csrfCookie",
          'X-CSRFToken': csrfToken!,
        },
      ).timeout(Duration(seconds: timeout));
      final body = jsonDecode(response.body);
      print(body);
      if (response.statusCode == 200) {
        return body['content'];
      }
      return body;
    } catch (e) {
      return null;
    }
  }
}

