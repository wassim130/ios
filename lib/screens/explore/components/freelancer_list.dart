import 'dart:convert';

import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

import '../../../models/freelancer.dart';
import 'package:http/http.dart' as http;

import '../../../services/constants.dart';

class FreeLancerList extends StatefulWidget {
  const FreeLancerList({super.key});

  @override
  State<FreeLancerList> createState() => FreelancerListState();
}

class FreelancerListState extends State<FreeLancerList> {
  List<FreelancerModel?> freelancers = [];
  int lastFilter = 0;

  @override
  void initState() {
    super.initState();
    fetchFreeLancers();
  }

  void fetchFreeLancers({filter = 0}) async {
    try {
      lastFilter = filter;
      freelancers = [];
      final response = await http
          .get(Uri.parse('$httpURL/api/portfolio/freelancers/?filter=$filter'));
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)['portfolios'];
        for (var item in jsonResponse) {
          final freelancer = FreelancerModel.fromMap(item);
          freelancers.add(freelancer);
        }
        print(freelancers);
        setState(() {});
      }
    } catch (e) {
      print('exception lors de la recuperation des freelancers: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        fetchFreeLancers(filter: lastFilter);
      },
      child: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: freelancers.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: secondaryColor,
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                ),
              ),
              title: Text(
                // 'Freelancer ${index + 1}',
                freelancers[index]!.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(freelancers[index]!.technologies.isNotEmpty
                      ? freelancers[index]!.technologies.first.name
                      : ""),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      Text(' 4.8 (156 avis)'),
                    ],
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    children: [
                      Chip(
                        // label: Text(tools[index]!.name),
                        label: Text(freelancers[index]!.tools.isNotEmpty
                            ? freelancers[index]!.tools.first.name
                            : ""),
                        backgroundColor: secondaryColor,
                        labelStyle: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                      if (freelancers[index]!.tools.length > 1)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/portefolio',
                                arguments: {
                                  'portfolioID': freelancers[index]!.id
                                });
                          },
                          child: Chip(
                            label: Text("..."),
                            backgroundColor: secondaryColor,
                            labelStyle: TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        ),

                      // Chip(
                      //   label: Text('Node.js'),
                      //   backgroundColor: secondaryColor,
                      // ),
                    ],
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/portefolio',
                      arguments: {'portfolioID': freelancers[index]!.id});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Voir plus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
