import 'dart:async';

import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final bool isEntreprise, isDark;
  final listKey;
  const ExploreSearchBar({
    super.key,
    required this.isEntreprise,
    required this.searchController,
    required this.listKey,
    required this.isDark,
  });

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  bool isSearchFocused = false;
  Timer? _debounceTimer;
  late final Color primaryColorTheme;

  @override
  void initState() {
    super.initState();
    primaryColorTheme = widget.isDark ? darkPrimaryColor : primaryColor;
  }

  void _handleContactTap(text) {
    _debounceTimer?.cancel();
    if (widget.isEntreprise) {
      widget.listKey.currentState?.fetchFreeLancers(search: text);
    } else {
      widget.listKey.currentState?.fetchCompanies(search: text);
    }
    widget.listKey.currentState?.currentSearch = text;

    setState(() => isSearchFocused = false);
  }

  void _onSearchChanged(String text) {
    // Cancel the previous timer if user types again
    _debounceTimer?.cancel();
    // Start a new timer
    _debounceTimer = Timer(Duration(milliseconds: 1200), () {
      _handleContactTap(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: widget.isDark
            ? darkSecondaryColor.withOpacity(0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSearchFocused
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : [],
      ),
      child:
       TextField(
        controller: widget.searchController,
        onTap: () => setState(() => isSearchFocused = true),
        onSubmitted: (text) => _handleContactTap(text),
        onChanged: (text) => _onSearchChanged(text),
        decoration: InputDecoration(
          hintText: 'Rechercher un profil...'.tr,
          hintStyle: TextStyle(
            color: widget.isDark ? Colors.white70 : Colors.black54,
          ),
          prefixIcon: Icon(Icons.search, color: primaryColorTheme),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () {
                    _handleContactTap("");
                    widget.searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(
          color: widget.isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
