import 'package:ahmini/screens/explore/components/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ahmini/services/constants.dart';

class TechnologiesSelectDropdown extends StatefulWidget {
  final Color primaryColor;
  final Function callBack;
  const TechnologiesSelectDropdown({
    super.key,
    required this.primaryColor,
    required this.callBack,
  });

  @override
  _TechnologiesSelectDropdownState createState() =>
      _TechnologiesSelectDropdownState();
}

class _TechnologiesSelectDropdownState
    extends State<TechnologiesSelectDropdown> {
  List<dynamic> _options = [];
  String? _selectedValue;
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    fetchOptions();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchOptions() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    final int pagination = _options.isEmpty ? 0 : _options.last['id'];
    final url = Uri.parse('$httpURL/api/technologies/?pagination=$pagination');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['technologies'].isNotEmpty) {
          for (var item in data['technologies']) {
            if (!_options.any((option) => option['id'] == item['id'])) {
              _options.add(item);
            }
          }
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      print('Error fetching options: $e');
    } finally {
      _isLoading = false;
      _updateDropdown();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      fetchOptions();
    }
  }

  void _updateDropdown() {
    _overlayEntry?.markNeedsBuild(); // Rebuilds dropdown without removing it
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showDropdownMenu();
    } else {
      _closeDropdown();
    }
  }

  void _showDropdownMenu() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width * 0.9,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _options.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _options.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: MovingLineIndicator(),
                      ),
                    );
                  }
                  final option = _options[index];
                  return ListTile(
                    title: Text(option['name']),
                    onTap: () {
                      setState(() {
                        _selectedValue = option['id'].toString();
                      });
                      widget.callBack(option);
                      _closeDropdown();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown, // Opens custom dropdown
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: widget.primaryColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedValue != null
                    ? _options.firstWhere(
                        (option) => option['id'].toString() == _selectedValue,
                        orElse: () => {'name': 'Select an option'})['name']
                    : 'Select an option',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
