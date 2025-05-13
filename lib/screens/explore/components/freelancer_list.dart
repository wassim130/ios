import 'dart:convert';

import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/freelancer.dart';
import 'package:http/http.dart' as http;

import '../../../services/constants.dart';
import 'freelancer_card.dart';
import 'progress_indicator.dart';

class FreeLancerList extends StatefulWidget {
  const FreeLancerList({super.key});

  @override
  State<FreeLancerList> createState() => FreelancerListState();
}

class FreelancerListState extends State<FreeLancerList> {
  final ScrollController _scrollController = ScrollController();
  List<FreelancerModel?> freelancers = [];
  String currentSearch = "";
  int currentFilter = 0;
  bool fetching = false;
  bool isLoading = true;
  bool limitReached = false;

  @override
  void initState() {
    super.initState();
    fetchFreeLancers();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !fetching &&
          !limitReached) {
        fetching = true;
        await fetchFreeLancers(
            pagination: freelancers.last!.id, clearOldList: false);
        fetching = false;
      }
    });
  }

  Future<void> fetchFreeLancers(
      {filter, search, pagination, bool clearOldList = true}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      if (filter == null) {
        filter = currentFilter;
      } else {
        currentFilter = filter;
      }
      if (search == null) {
        search = currentSearch;
      } else {
        currentSearch = search;
      }
      if (clearOldList) {
        freelancers = [];
      }
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      final response = await http.get(
        Uri.parse('$httpURL/api/portfolio/freelancers/')
            .replace(queryParameters: {
          if (filter != null) "filter": filter.toString(),
          if (pagination != null) "pagination": pagination.toString(),
          if (search != null) "search": search.toString(),
        }),
        headers: {
          'Cookie': "sessionid=$sessionCookie",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)['portfolios'];
        if (jsonResponse.isEmpty) {
          limitReached = true;
        }
        for (var item in jsonResponse) {
          final freelancer = FreelancerModel.fromMap(item);
          freelancers.add(freelancer);
        }
      }
    } catch (e) {
      print('exception lors de la recuperation des freelancers: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        limitReached = false;
        fetchFreeLancers(filter: currentFilter, search: currentSearch);
      },
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(15),
            itemCount: freelancers.length,
            itemBuilder: (context, index) {
              return FreelancerCard(
                freelancer: freelancers[index]!,
                backgroundColor: backgroundColor,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
              );
            },
          ),
          if (fetching || isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MovingLineIndicator(),
            ),
        ],
      ),
    );
  }
}
