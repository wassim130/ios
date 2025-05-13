import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../services/auth.dart';
import '../../services/constants.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final PageController _pageController = PageController();
  final Duration _animationDuration = Duration(milliseconds: 300);
  final Cubic _animationCurve = Curves.easeInOut;

  List freelancers = [];
  List entreprises = [];

  String? _sessionCookie;
  SharedPreferences? _prefs;

  bool isEnterpriseActive = true;

  @override
  void initState() {
    super.initState();
    _myInitState();
  }

  Future<void> _myInitState() async {
    _prefs = await SharedPreferences.getInstance();
    _sessionCookie = _prefs!.getString('session_cookie');
    _fetchData();
  }

  void _fetchData() async {
    final response = await http.get(
      Uri.parse('$httpURL/$authAPI/freelancer-documents/'),
      headers: {
        'Cookie': "sessionid=$_sessionCookie",
      },
    ).timeout(Duration(seconds: timeout));
    print("is Logged in : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      freelancers = data['content']['freelancers'];
      entreprises = data['content']['entreprises'];
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showImage(String imageUrl) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            //full height
            insetPadding: EdgeInsets.zero,
            //full width
            clipBehavior: Clip.none,
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              httpHeaders: {
                'Cookie': "sessionid=$_sessionCookie",
              },
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
            ),
          );
        });
  }

  void _handlePressTap(int id, bool state) async {
    String? csrfToken = _prefs!.getString('csrf_token');
    String? csrfCookie = _prefs!.getString('csrf_cookie');

    if (csrfCookie == null || csrfToken == null) {
      final temp = await AuthService.getCsrf();
      csrfToken = temp['csrf_token'];
      csrfCookie = temp['csrf_cookie'];
    }
    final response = await http.put(
      Uri.parse('$httpURL/$authAPI/freelancer-documents/'),
      headers: {
        'Cookie': "sessionid=$_sessionCookie;csrftoken=$csrfCookie",
        'X-CSRFToken': csrfToken!,
      },
      body: jsonEncode({
        "id": '$id',
        "state": '$state',
      }),
    ).timeout(Duration(seconds: timeout));
    print("is Logged in : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Admin Panel'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildEntrepriseList(),
                _buildFreelancersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isEnterpriseActive = true;
                      _pageController.previousPage(
                        duration: _animationDuration,
                        curve: _animationCurve,
                      );
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Entreprises',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEnterpriseActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isEnterpriseActive = false;
                      _pageController.nextPage(
                        duration: _animationDuration,
                        curve: _animationCurve,
                      );
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Freelancers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !isEnterpriseActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              AnimatedAlign(
                duration: _animationDuration,
                curve: _animationCurve,
                alignment: !isEnterpriseActive
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 3,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntrepriseList() {
    return ListView.builder(
        itemCount: entreprises.length,
        itemBuilder: (context, index) => ExpansionTile(
              title: Text(entreprises[index]['name']),
              subtitle: Text(entreprises[index]['email']),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    GestureDetector(
                      onTap: () => _showImage(
                          "$httpURL${entreprises[index]['identity_card']}"),
                      child: CachedNetworkImage(
                        imageUrl:
                            "$httpURL${entreprises[index]['identity_card']}",
                        httpHeaders: {
                          'Cookie': "sessionid=$_sessionCookie",
                        },
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        height: 150,
                        width: 200,
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            children: [
                          TextSpan(text: "NIF: ".tr),
                          TextSpan(
                            text: entreprises[index]['NIF'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                        ])),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                _handlePressTap(entreprises[index]['id'], true);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.green),
                              ),
                              child: Text(
                                "Accepter".tr,
                                style: TextStyle(color: Colors.white),
                              )),
                          TextButton(
                              onPressed: () {
                                _handlePressTap(
                                    entreprises[index]['id'], false);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.red),
                              ),
                              child: Text(
                                "Refuser".tr,
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }

  Widget _buildFreelancersList() {
    return ListView.builder(
        itemCount: freelancers.length,
        itemBuilder: (context, index) => ExpansionTile(
              title: Text(freelancers[index]['name']),
              subtitle: Text(freelancers[index]['email']),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  children: [
                    GestureDetector(
                      onTap: () => _showImage(
                          "$httpURL${freelancers[index]['identity_card']}"),
                      child: CachedNetworkImage(
                        imageUrl:
                            "$httpURL${freelancers[index]['identity_card']}",
                        httpHeaders: {
                          'Cookie': "sessionid=$_sessionCookie",
                        },
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        height: 250,
                        width: 400,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () => _showImage(
                          "$httpURL${freelancers[index]['second_card']}"),
                      child: CachedNetworkImage(
                        imageUrl:
                            "$httpURL${freelancers[index]['second_card']}",
                        httpHeaders: {
                          'Cookie': "sessionid=$_sessionCookie",
                        },
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        height: 250,
                        width: 400,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            _handlePressTap(freelancers[index]['id'], true);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green),
                          ),
                          child: Text(
                            "Accepter".tr,
                            style: TextStyle(color: Colors.white),
                          )),
                      TextButton(
                          onPressed: () {
                            _handlePressTap(freelancers[index]['id'], false);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.red),
                          ),
                          child: Text(
                            "Refuser".tr,
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ),
              ],
            ));
  }
}
