import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController searchController;
  const MySearchBar({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher une conversation...'.tr,
            border: InputBorder.none,
            icon: Icon(
              Icons.search,
              color: primaryColor,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: primaryColor),
              onPressed: () {
                searchController.clear();
              },
            )
                : null,
          ),
          onChanged: (value) {
            // This will trigger the listener in MyStreamBuilder
          },
        ),
      ),
    );
  }
}

